from __future__ import annotations

import logging
import os

import requests
from urllib.parse import quote

from ..database import SessionLocal
from ..models import Order

OPERATIONAL_STATUSES = (
    "pending",
    "preparing",
    "delivering",
    "completed",
    "cancelled",
)

PAYMENT_STATUSES = (
    "pending",
    "paid",
    "canceled",
    "cancelled",
)

logger = logging.getLogger("order.service")


def _normalize_status(value: str) -> str:
    return value.strip().lower()


def _assistant_notify_url() -> str:
    return os.getenv("ASSISTANT_NOTIFY_URL", "").strip()


def _send_assistant_notification(session_id: str, message: str) -> None:
    assistant_url = _assistant_notify_url()
    if not assistant_url:
        return

    payload = {"session_id": session_id, "message": message}
    try:
        response = requests.post(assistant_url, json=payload, timeout=5)
    except Exception as exc:  # noqa: BLE001
        logger.error("Falha ao notificar assistant.", exc_info=exc)
        return

    if response.status_code != 200:
        logger.error(
            "Erro ao notificar assistant (status=%s): %s",
            response.status_code,
            response.text,
        )


def notify_order_status_change(order: Order) -> None:
    if not order.session_id:
        return

    status_raw = getattr(order, "order_status", None) or ""
    status_value = str(status_raw).upper()
    message = f"Pedido #{order.id}\\nStatus atualizado: {status_value}"
    _send_assistant_notification(order.session_id, message)


def generate_whatsapp_link(phone: str, status: str) -> str:
    # Remove tudo que não for número
    phone_digits = "".join(ch for ch in str(phone) if ch.isdigit())

    if not phone_digits:
        raise ValueError("Customer phone is invalid.")

    # Adiciona código do país 55 se não estiver presente
    if not phone_digits.startswith("55"):
        phone_digits = "55" + phone_digits

    # Cria a mensagem codificada
    message = f"Olá! Seu pedido foi atualizado para: {status}"
    message_encoded = quote(message)

    # Retorna o link pronto para WhatsApp
    return f"https://wa.me/{phone_digits}?text={message_encoded}"

def update_payment_status(order_id: int, payment_status: str) -> None:
    print(payment_status)
    normalized = _normalize_status(payment_status or "")
    if not normalized:
        raise ValueError("Payment status invalido.")
    if normalized not in PAYMENT_STATUSES:
        raise ValueError(f"Payment status invalido: {normalized}.")

    with SessionLocal() as db:
        order = db.query(Order).filter(Order.id == order_id).first()
        if not order:
            raise LookupError("Order not found.")

        order.status = normalized
        db.commit()
        logger.info(
            "Pedido %s atualizado para payment_status=%s.",
            order.id,
            normalized,
        )
    return {
            "order_id": order.id,
            "status": order.status,
            "customer_phone": order.customer_phone,
            #"whatsapp_link": whatsapp_link,
        }


def update_order_status(order_id: int, new_status: str) -> dict:
    normalized = _normalize_status(new_status or "")
    if not normalized:
        raise ValueError("Status invalido.")
    if normalized not in OPERATIONAL_STATUSES:
        raise ValueError(f"Status invalido: {normalized}.")

    with SessionLocal() as db:
        order = db.query(Order).filter(Order.id == order_id).first()
        if not order:
            raise LookupError("Order not found.")
        if not order.customer_phone or not str(order.customer_phone).strip():
            raise ValueError("Customer phone is required.")

        order.order_status = normalized
        db.commit()
        db.refresh(order)
        logger.info(
            "Pedido %s atualizado para order_status=%s.",
            order.id,
            order.order_status,
        )

        whatsapp_link = generate_whatsapp_link(order.customer_phone, normalized)

        return {
            "order_id": order.id,
            "order_status": order.order_status,
            "customer_phone": order.customer_phone,
            "whatsapp_link": whatsapp_link,
        }
