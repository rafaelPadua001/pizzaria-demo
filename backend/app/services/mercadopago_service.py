from __future__ import annotations

from typing import Tuple

import mercadopago

from ..models import Order, Restaurant


def create_preference(
    order: Order,
    restaurant: Restaurant,
    notification_url: str | None = None,
    back_urls: dict | None = None,
) -> Tuple[str, str]:
    access_token = restaurant.mercadopago_access_token
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
    preference = mp_response.get("response") if isinstance(mp_response, dict) else None
    if not preference:
        raise RuntimeError("Resposta invalida do Mercado Pago.")

    checkout_url = preference.get("init_point") or preference.get("sandbox_init_point")
    preference_id = preference.get("id")
    if not preference_id or not checkout_url:
        raise RuntimeError("Preferencia criada sem dados de checkout.")

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
