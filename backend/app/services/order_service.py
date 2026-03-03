from __future__ import annotations

import json
import logging
import os
from urllib import error as url_error
from urllib import request as url_request

from ..database import SessionLocal
from ..models import Order
from ..models.order import ORDER_STATUSES


logger = logging.getLogger("order.service")

STATUS_LABELS = {
    "pending": "Aguardando pagamento",
    "paid": "Pagamento confirmado",
    "preparing": "Em preparo \U0001F355",
    "ready": "Pronto para entrega",
    "sent": "Saiu para entrega \U0001F697",
    "cancelled": "Pedido cancelado",
    "confirmed": "Pagamento confirmado",
    "delivered": "Pedido entregue",
    "canceled": "Pedido cancelado",
}


def _normalize_status(value: str) -> str:
    return value.strip().lower()


def _assistant_notify_url() -> str:
    return os.getenv("ASSISTANT_NOTIFY_URL", "").strip()


def _send_assistant_notification(session_id: str, message: str) -> None:
    notify_url = _assistant_notify_url()
    if not notify_url:
        logger.warning(
            "ASSISTANT_NOTIFY_URL nao configurada. Notificacao nao enviada para session_id=%s.",
            session_id,
        )
        return

    payload = json.dumps({"session_id": session_id, "message": message}).encode("utf-8")
    request = url_request.Request(notify_url, data=payload, method="POST")
    request.add_header("Content-Type", "application/json")

    try:
        with url_request.urlopen(request, timeout=5) as response:
            response_body = response.read().decode("utf-8")
            logger.info(
                "Notificacao enviada (status=%s) session_id=%s response=%s",
                response.status,
                session_id,
                response_body,
            )
    except url_error.HTTPError as exc:
        response_body = exc.read().decode("utf-8") if exc.fp else ""
        logger.error(
            "Erro HTTP ao notificar assistant (status=%s): %s",
            exc.code,
            response_body,
        )
    except url_error.URLError as exc:
        logger.error("Falha de conexao ao notificar assistant: %s", exc.reason)
    except Exception:
        logger.exception("Erro inesperado ao notificar assistant.")


def notify_order_status_change(order: Order) -> None:
    status_label = STATUS_LABELS.get(order.status, order.status)
    message = f"Pedido #{order.id}\nStatus atual: {status_label}"

    if not order.session_id:
        logger.warning(
            "Pedido %s sem session_id. Notificacao nao enviada.",
            order.id,
        )
        return

    _send_assistant_notification(order.session_id, message)


def update_order_status(order_id: int, new_status: str) -> Order:
    normalized = _normalize_status(new_status)
    if not normalized:
        raise ValueError("Status invalido.")
    if normalized not in ORDER_STATUSES:
        raise ValueError(f"Status invalido: {normalized}.")

    with SessionLocal() as db:
        order = db.query(Order).filter(Order.id == order_id).first()
        if not order:
            raise LookupError("Order not found.")

        if order.status == normalized:
            return order

        order.status = normalized
        db.commit()
        db.refresh(order)
        notify_order_status_change(order)
        return order
