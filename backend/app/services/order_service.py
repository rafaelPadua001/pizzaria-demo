from __future__ import annotations

import logging
import os

import requests

from ..database import SessionLocal
from ..models import Order
OPERATIONAL_STATUSES = (
    "pending",
    "preparing",
    "delivering",
    "completed",
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
        print("ASSISTANT_NOTIFY_URL nao configurada")
        return

    payload = {"session_id": session_id, "message": message}
    try:
        response = requests.post(assistant_url, json=payload, timeout=5)
    except Exception as exc:  # noqa: BLE001
        logger.error("Falha ao notificar assistant.", exc_info=exc)
        return

    if response.status_code != 200:
        print(
            f"Erro ao notificar assistant (status={response.status_code}): {response.text}"
        )
    else:
        print("Notificacao enviada com sucesso.")


def notify_order_status_change(order: Order) -> None:
    if not order.session_id:
        print(f"Pedido {order.id} sem session_id. Notificacao nao enviada.")
        return

    status_raw = getattr(order, "order_status", None) or ""
    status_value = str(status_raw).upper()
    message = f"🍕 Pedido #{order.id}\nStatus atualizado: {status_value}"
    _send_assistant_notification(order.session_id, message)


def update_order_status(order_id: int, new_status: str) -> Order:
    normalized = _normalize_status(new_status)
    if not normalized:
        raise ValueError("Status invalido.")
    if normalized not in OPERATIONAL_STATUSES:
        raise ValueError(f"Status invalido: {normalized}.")

    with SessionLocal() as db:
        order = db.query(Order).filter(Order.id == order_id).first()
        if not order:
            raise LookupError("Order not found.")

        if order.order_status == normalized:
            return order

        order.order_status = normalized
        db.commit()
        db.refresh(order)
        notify_order_status_change(order)
        return order
