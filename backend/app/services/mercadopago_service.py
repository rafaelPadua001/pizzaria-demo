from __future__ import annotations

import os
from typing import Tuple

import mercadopago
from fastapi import HTTPException

from ..models import Order, Restaurant


def create_checkout(
    order: Order,
    restaurant: Restaurant,
    notification_url: str | None = None,
) -> Tuple[str, str]:
    access_token = os.getenv("MERCADOPAGO_ACCESS_TOKEN")
    if not access_token:
        raise HTTPException(
            status_code=500,
            detail="MERCADOPAGO_ACCESS_TOKEN nao configurado.",
        )

    sdk = mercadopago.SDK(access_token)

    preference_data = {
        "items": [
            {
                "title": item.product_name,
                "quantity": item.quantity,
                "unit_price": float(item.unit_price),
            }
            for item in order.items
        ],
        "back_urls": {
            "success": "http://localhost:8000/payment/success",
            "failure": "http://localhost:8000/payment/failure",
            "pending": "http://localhost:8000/payment/pending",
        },
    }

   # if notification_url:
   #     preference_data["notification_url"] = notification_url

    mp_response = sdk.preference().create(preference_data)
    print("MP RAW RESPONSE:", mp_response)

    if "response" not in mp_response:
        raise HTTPException(
            status_code=502,
            detail="Resposta invalida do Mercado Pago.",
        )

    preference = mp_response["response"]
    print(preference)
    checkout_url = preference.get("sandbox_init_point") or preference.get("init_point")

    if not checkout_url:
        raise HTTPException(
            status_code=502,
            detail="Preferencia criada sem dados de checkout.",
        )

    # salvar preference_id no pedido
    order.mercadopago_preference_id = preference.get("id")

    preference_id = preference.get("id")
    if not preference_id:
        raise HTTPException(
            status_code=502,
            detail="Preferencia criada sem id.",
        )

    return preference_id, checkout_url


def get_payment(payment_id: str, access_token: str) -> dict:
    sdk = mercadopago.SDK(access_token)
    result = sdk.payment().get(payment_id)
    payment = result.get("response") if isinstance(result, dict) else None
    if not payment:
        raise RuntimeError("Falha ao consultar pagamento no Mercado Pago.")
    return payment
