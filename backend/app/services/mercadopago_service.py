from __future__ import annotations

import logging
import os
from typing import Tuple

import mercadopago

from ..models import Order, Restaurant


logger = logging.getLogger("mercadopago.service")


def create_preference(
    order: Order,
    restaurant: Restaurant,
    notification_url: str | None = None,
    back_urls: dict | None = None,
) -> Tuple[str, str]:
    access_token = restaurant.mercadopago_access_token or os.getenv("MERCADOPAGO_ACCESS_TOKEN", "")
    if not access_token:
        raise RuntimeError("Mercado Pago access token nao configurado para o restaurante.")

    sdk = mercadopago.SDK(access_token)

    preference_data = {
        "items": [
            {
                "title": item.product_name,
                "quantity": item.quantity,
                "unit_price": float(item.unit_price),
                "currency_id": "BRL",
            }
            for item in order.items
        ],
        "external_reference": str(order.id),
    }

    if back_urls:
        preference_data["back_urls"] = back_urls

    if notification_url:
        preference_data["notification_url"] = notification_url

    mp_response = sdk.preference().create(preference_data)
    if os.getenv("MERCADOPAGO_DEBUG") == "1":
        safe_log = {}
        if isinstance(mp_response, dict):
            safe_log = {
                "status": mp_response.get("status"),
                "message": mp_response.get("message"),
                "error": mp_response.get("error"),
            }
        logger.info("MP preference response (safe): %s", safe_log)
    preference = None
    if isinstance(mp_response, dict):
        preference = mp_response.get("response") or mp_response.get("body")
        if not preference and "init_point" in mp_response:
            preference = mp_response
    if not preference:
        logger.error("Resposta MP invalida: %s", mp_response if isinstance(mp_response, dict) else type(mp_response))
        raise RuntimeError("Resposta invalida do Mercado Pago.")

    checkout_url = preference.get("init_point") or preference.get("sandbox_init_point")
    preference_id = preference.get("id")
    if not preference_id or not checkout_url:
        error_message = None
        if isinstance(preference, dict):
            error_message = preference.get("message") or preference.get("error")
        logger.error(
            "Preferencia incompleta (id=%s, init_point=%s).",
            preference.get("id") if isinstance(preference, dict) else None,
            preference.get("init_point") if isinstance(preference, dict) else None,
        )
        raise RuntimeError(error_message or "Preferencia criada sem dados de checkout.")

    return preference_id, checkout_url


def create_checkout(
    order: Order,
    restaurant: Restaurant,
    notification_url: str | None = None,
    back_urls: dict | None = None,
) -> Tuple[str, str]:
    return create_preference(
        order,
        restaurant,
        notification_url=notification_url,
        back_urls=back_urls,
    )


def get_payment(payment_id: str, access_token: str) -> dict:
    sdk = mercadopago.SDK(access_token)
    result = sdk.payment().get(payment_id)
    payment = result.get("response") if isinstance(result, dict) else None
    if not payment:
        raise RuntimeError("Falha ao consultar pagamento no Mercado Pago.")
    return payment
