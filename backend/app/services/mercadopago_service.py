from __future__ import annotations

import logging
import os
from typing import Any, Tuple

import requests

from ..models import Order, Restaurant


logger = logging.getLogger("mercadopago.service")

MP_PREFERENCE_URL = "https://api.mercadopago.com/checkout/preferences"
MP_PAYMENT_URL = "https://api.mercadopago.com/v1/payments/{payment_id}"
MP_MERCHANT_ORDER_URL = "https://api.mercadopago.com/merchant_orders/{merchant_order_id}"
REQUIRED_BACK_URL_KEYS = ("success", "failure", "pending")


def _get_access_token(restaurant: Restaurant | None = None) -> str:
    access_token = None
    if restaurant and restaurant.mercadopago_access_token:
        access_token = str(restaurant.mercadopago_access_token).strip()
    if restaurant and not access_token:
        raise RuntimeError("Mercado Pago access token nao configurado para o restaurante.")
    if not access_token:
        access_token = (
            os.getenv("MERCADO_PAGO_ACCESS_TOKEN")
            or os.getenv("MERCADOPAGO_ACCESS_TOKEN")
            or ""
        ).strip()
    if not access_token:
        raise RuntimeError(
            "Mercado Pago access token nao configurado. Defina MERCADO_PAGO_ACCESS_TOKEN no .env."
        )
    return access_token


def _is_sandbox(access_token: str) -> bool:
    return access_token.startswith("TEST-")


def _normalize_item(title: Any, quantity: Any, unit_price: Any) -> dict[str, Any]:
    normalized_title = str(title or "").strip()
    if not normalized_title:
        raise ValueError("Item sem titulo para preferencia.")

    try:
        normalized_quantity = int(quantity)
    except (TypeError, ValueError) as exc:
        raise ValueError("Quantidade invalida para preferencia.") from exc
    if normalized_quantity <= 0:
        raise ValueError("Quantidade invalida para preferencia.")

    try:
        normalized_unit_price = float(unit_price)
    except (TypeError, ValueError) as exc:
        raise ValueError("Preco invalido para preferencia.") from exc
    if normalized_unit_price <= 0:
        raise ValueError("Preco invalido para preferencia.")

    return {
        "title": normalized_title,
        "quantity": normalized_quantity,
        "currency_id": "BRL",
        "unit_price": normalized_unit_price,
    }


def _build_items(order: Order) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for item in order.items:
        title = getattr(item, "name", None) or getattr(item, "product_name", None)
        unit_price = getattr(item, "price", None) or getattr(item, "unit_price", None)
        quantity = getattr(item, "quantity", None)
        items.append(_normalize_item(title, quantity, unit_price))
    return items


def _build_back_urls(back_urls: dict[str, Any] | None) -> dict[str, str]:
    sanitized: dict[str, str] = {}

    if back_urls:
        for key in REQUIRED_BACK_URL_KEYS:
            value = back_urls.get(key)
            if isinstance(value, str) and value.strip():
                sanitized[key] = value.strip()

    frontend_url = (os.getenv("FRONTEND_BASE_URL") or "").strip().rstrip("/")
    if frontend_url:
        sanitized = {
            "success": f"{frontend_url}/payment/success",
            "failure": f"{frontend_url}/payment/failure",
            "pending": f"{frontend_url}/payment/pending",
        }

    missing = [key for key in REQUIRED_BACK_URL_KEYS if not sanitized.get(key)]
    if missing:
        raise RuntimeError(
            "Back URLs do Mercado Pago incompletas. Configure success, failure e pending."
        )

    return sanitized


def _has_valid_url(value: str | None) -> bool:
    if not isinstance(value, str):
        return False
    normalized = value.strip().lower()
    if not (normalized.startswith("http://") or normalized.startswith("https://")):
        return False
    return not (
        "localhost" in normalized
        or "127.0.0.1" in normalized
        or "0.0.0.0" in normalized
    )


def create_preference(
    order: Order,
    restaurant: Restaurant | None = None,
    notification_url: str | None = None,
    back_urls: dict | None = None,
) -> Tuple[str, str]:
    access_token = _get_access_token(restaurant)
    is_sandbox = _is_sandbox(access_token)

    if not order.total_amount or order.total_amount <= 0:
        raise ValueError("Order total invalido para pagamento.")

    items: list[dict[str, Any]] = []
    if order.items:
        try:
            items = _build_items(order)
        except ValueError:
            items = []
    if not items:
        items = [_normalize_item(f"Pedido #{order.id}", 1, order.total_amount)]

    normalized_back_urls = _build_back_urls(back_urls)
    preference_data: dict[str, Any] = {
        "items": items,
        "external_reference": str(order.id),
        "back_urls": normalized_back_urls,
    }

    if _has_valid_url(normalized_back_urls.get("success")):
        preference_data["auto_return"] = "approved"

    notification_url = notification_url or os.getenv("MERCADOPAGO_NOTIFICATION_URL")
    if notification_url:
        preference_data["notification_url"] = notification_url
    else:
        logger.warning("Webhook nao configurado. Pedido pode ficar pending.")

    email = getattr(order, "customer_email", None)
    if email and str(email).strip():
        preference_data["payer"] = {"email": str(email).strip()}

    logger.info(
        "mp_preference_create",
        extra={
            "order_id": order.id,
            "sandbox": is_sandbox,
            "has_email": bool(email and str(email).strip()),
            "total": order.total_amount,
        },
    )

    try:
        response = requests.post(
            MP_PREFERENCE_URL,
            json=preference_data,
            headers={
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json",
            },
            timeout=10,
        )
    except requests.RequestException:
        logger.exception("mp_request_failure")
        raise

    try:
        response_payload = response.json()
    except ValueError:
        logger.error(
            "mp_preference_error",
            extra={"order_id": order.id, "response": response.text},
        )
        raise RuntimeError("Resposta invalida do Mercado Pago.")

    if response.status_code not in {200, 201}:
        response_text = response.text
        logger.error(
            "mp_preference_error",
            extra={
                "order_id": order.id,
                "payload": preference_data,
                "status_code": response.status_code,
                "response_text": response_text,
                "response": response_payload,
            },
        )
        raise RuntimeError(
            "Falha ao criar preferencia no Mercado Pago. "
            f"status={response.status_code} response={response_text}"
        )

    preference_id = response_payload.get("id")
    checkout_url = (
        response_payload.get("sandbox_init_point")
        if is_sandbox
        else response_payload.get("init_point")
    )

    if not checkout_url:
        raise RuntimeError("Mercado Pago nao retornou URL de checkout.")
    if not preference_id:
        raise RuntimeError("Mercado Pago nao retornou preference_id.")

    return str(preference_id), str(checkout_url)


def create_checkout(
    order: Order,
    restaurant: Restaurant | None = None,
    notification_url: str | None = None,
    back_urls: dict | None = None,
) -> Tuple[str, str]:
    return create_preference(
        order,
        restaurant,
        notification_url=notification_url,
        back_urls=back_urls,
    )


def check_payment_status(
    payment_id: str,
    access_token: str | None = None,
    restaurant: Restaurant | None = None,
) -> dict:
    access_token_value = access_token or _get_access_token(restaurant)
    try:
        response = requests.get(
            MP_PAYMENT_URL.format(payment_id=payment_id),
            headers={"Authorization": f"Bearer {access_token_value}"},
            timeout=10,
        )
        response.raise_for_status()
    except requests.RequestException:
        logger.exception("mp_request_failure")
        raise

    payload = response.json()
    if not isinstance(payload, dict):
        raise RuntimeError("Resposta invalida do Mercado Pago.")
    return payload


def get_payment(payment_id: str, access_token: str) -> dict:
    try:
        response = requests.get(
            MP_PAYMENT_URL.format(payment_id=payment_id),
            headers={"Authorization": f"Bearer {access_token}"},
            timeout=10,
        )
        response.raise_for_status()
    except requests.RequestException:
        logger.exception("mp_request_failure")
        raise RuntimeError("Falha ao consultar pagamento no Mercado Pago.")

    payload = response.json()
    if not isinstance(payload, dict):
        raise RuntimeError("Resposta invalida do Mercado Pago.")
    return payload

def get_merchant_order(merchant_order_id: str, access_token: str) -> dict:
    try:
        response = requests.get(
            MP_MERCHANT_ORDER_URL.format(merchant_order_id=merchant_order_id),
            headers={"Authorization": f"Bearer {access_token}"},
            timeout=10,
        )
        response.raise_for_status()
    except requests.RequestException:
        logger.exception("mp_request_failure")
        raise RuntimeError("Falha ao consultar merchant_order no Mercado Pago.")

    payload = response.json()
    if not isinstance(payload, dict):
        raise RuntimeError("Falha ao consultar merchant_order no Mercado Pago.")
    return payload


