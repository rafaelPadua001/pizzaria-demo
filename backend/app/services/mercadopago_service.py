from __future__ import annotations

import logging
import os
from typing import Any, Tuple

import mercadopago
import json
from ..models import Order, Restaurant


logger = logging.getLogger("mercadopago.service")


def _normalize_items(order: Order) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for item in order.items:
        quantity = int(item.quantity)
        unit_price = float(item.unit_price)
        if quantity <= 0:
            raise RuntimeError("Quantidade de item invalida para preferencia.")
        items.append(
            {
                "title": item.product_name,
                "quantity": quantity,
                "unit_price": unit_price,
                "currency_id": "BRL",
            }
        )
    return items


def _extract_preference_payload(mp_response: Any) -> tuple[dict[str, Any] | None, str | None]:
    if not isinstance(mp_response, dict):
        return None, "Resposta invalida do Mercado Pago."

    status = mp_response.get("status")
    if status and status not in {200, 201}:
        message = mp_response.get("message") or mp_response.get("error") or "Erro Mercado Pago."
        return None, message

    if "response" in mp_response and isinstance(mp_response["response"], dict):
        return mp_response["response"], None

    if "body" in mp_response and isinstance(mp_response["body"], dict):
        return mp_response["body"], None

    if "init_point" in mp_response and "id" in mp_response:
        return mp_response, None

    message = mp_response.get("message") or mp_response.get("error")
    return None, message


def create_preference(
    order: Order,
    restaurant: Restaurant,
    notification_url: str | None = None,
    back_urls: dict | None = None,
) -> Tuple[str, str]:
    access_token = restaurant.mercadopago_access_token or os.getenv("MERCADOPAGO_ACCESS_TOKEN", "")
    if not access_token:
        raise RuntimeError("Mercado Pago access token nao configurado para o restaurante.")

    items = _normalize_items(order)
    if not items:
        raise RuntimeError("Pedido sem itens para criar preferencia.")

    sdk = mercadopago.SDK(access_token)

    preference_data: dict[str, Any] = {
        "items": items,
        "external_reference": str(order.id),
    }

    if back_urls:
        preference_data["back_urls"] = back_urls

    if notification_url:
        preference_data["notification_url"] = notification_url

    mp_response = sdk.preference().create(preference_data)
    logger.error("MP FULL RESPONSE: %s", json.dumps(mp_response, indent=2, ensure_ascii=False))

    preference, error_message = _extract_preference_payload(mp_response)
    if not preference:
        raise RuntimeError(error_message or "Resposta invalida do Mercado Pago.")

    if preference.get("error"):
        raise RuntimeError(str(preference.get("error")))

    if mp_response.get("status") not in {200, 201} and preference.get("message"):
        raise RuntimeError(str(preference.get("message")))

    preference_id = preference.get("id")
    checkout_url = preference.get("init_point") or preference.get("sandbox_init_point")

    if not preference_id or not checkout_url:
        raise RuntimeError("Preferencia criada sem dados de checkout.")

    return str(preference_id), str(checkout_url)


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
