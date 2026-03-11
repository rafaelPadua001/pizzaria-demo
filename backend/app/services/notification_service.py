from __future__ import annotations

import asyncio
import logging
from datetime import datetime, timezone
from typing import Iterable

import anyio
from sqlalchemy import event, inspect
from sqlalchemy.orm import Session

from ..models import Notification, Order
from ..realtime.connection_manager import manager


logger = logging.getLogger("notification.service")


def _build_event(notification: Notification) -> dict:
    timestamp = notification.created_at or datetime.now(timezone.utc)
    return {
        "event": "new_order",
        "order_id": notification.order_id,
        "title": notification.title,
        "message": notification.message,
        "timestamp": timestamp.isoformat(),
    }


def _broadcast_notification(restaurant_id: int, payload: dict) -> None:
    try:
        loop = asyncio.get_running_loop()
    except RuntimeError:
        try:
            anyio.from_thread.run(manager.broadcast, restaurant_id, payload)
        except RuntimeError:
            logger.warning("Sem event loop para broadcast de notificacao.")
        return

    loop.create_task(manager.broadcast(restaurant_id, payload))


def create_notification(
    db: Session,
    restaurant_id: int,
    title: str,
    message: str,
    order_id: int | None = None,
    type: str = "system",
) -> Notification:
    notification = Notification(
        restaurant_id=restaurant_id,
        type=type,
        title=title,
        message=message,
        order_id=order_id,
        is_read=False,
    )
    db.add(notification)
    try:
        db.commit()
        db.refresh(notification)
    except Exception:
        db.rollback()
        raise

    _broadcast_notification(restaurant_id, _build_event(notification))
    return notification


def _transitioned_to_paid(order: Order, attribute_name: str) -> bool:
    state = inspect(order)
    history = state.attrs[attribute_name].history
    if not history.has_changes():
        return False
    new_value = str(getattr(order, attribute_name, "") or "").lower()
    if new_value != "paid":
        return False
    return not any(str(old or "").lower() == "paid" for old in history.deleted)


def _iter_paid_orders(objects: Iterable[object]) -> list[Order]:
    paid_orders: list[Order] = []
    for obj in objects:
        if not isinstance(obj, Order):
            continue
        if _transitioned_to_paid(obj, "payment_status") or _transitioned_to_paid(
            obj,
            "status",
        ):
            paid_orders.append(obj)
    return paid_orders


@event.listens_for(Session, "before_flush")
def _queue_paid_order_notifications(
    session: Session,
    flush_context,  # noqa: ANN001
    instances,  # noqa: ANN001
) -> None:
    paid_orders = _iter_paid_orders(session.dirty)
    if not paid_orders:
        return

    pending = session.info.setdefault("pending_notifications", [])
    for order in paid_orders:
        if not order.restaurant_id:
            continue
        notification = Notification(
            restaurant_id=order.restaurant_id,
            type="order_paid",
            title="Novo pedido recebido",
            message=f"Pedido #{order.id} foi pago",
            order_id=order.id,
            is_read=False,
        )
        session.add(notification)
        pending.append(notification)


@event.listens_for(Session, "after_commit")
def _broadcast_after_commit(session: Session) -> None:
    pending = session.info.pop("pending_notifications", [])
    for notification in pending:
        if not getattr(notification, "restaurant_id", None):
            continue
        payload = _build_event(notification)
        _broadcast_notification(notification.restaurant_id, payload)


@event.listens_for(Session, "after_rollback")
def _clear_pending_notifications(session: Session) -> None:
    session.info.pop("pending_notifications", None)
