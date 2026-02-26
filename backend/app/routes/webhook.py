from __future__ import annotations

import logging
import os
from typing import Any

from fastapi import APIRouter, BackgroundTasks, HTTPException, Request, status
from sqlalchemy.orm import Session

from ..database import SessionLocal
from ..models import Order, Restaurant
from ..services.mercadopago_service import get_payment


logger = logging.getLogger("mercadopago.webhook")

router = APIRouter(prefix="/webhook", tags=["Webhook"])


def _extract_payment_id(payload: dict[str, Any], request: Request) -> str | None:
    data = payload.get("data") if isinstance(payload, dict) else None
    if isinstance(data, dict):
        payment_id = data.get("id") or data.get("payment_id")
        if payment_id:
            return str(payment_id)

    payment_id = payload.get("payment_id") or payload.get("id")
    if payment_id:
        return str(payment_id)

    query = request.query_params
    return query.get("data.id") or query.get("id")


def _safe_log_payload(payload: dict[str, Any]) -> dict[str, Any]:
    if not isinstance(payload, dict):
        return {"payload": "invalid"}
    data = payload.get("data")
    return {
        "type": payload.get("type") or payload.get("topic"),
        "action": payload.get("action"),
        "data_id": data.get("id") if isinstance(data, dict) else payload.get("id"),
    }


def _get_tokens(db: Session, preferred: str | None = None) -> list[str]:
    tokens: list[str] = []
    if preferred:
        tokens.append(preferred)

    env_token = os.getenv("MERCADOPAGO_ACCESS_TOKEN", "")
    if env_token and env_token not in tokens:
        tokens.append(env_token)

    if not tokens:
        tokens = [
            restaurant.mercadopago_access_token
            for restaurant in db.query(Restaurant).all()
            if restaurant.mercadopago_access_token
        ]

    return tokens


def _process_payment(payment_id: str | None, payload: dict[str, Any]) -> None:
    if not payment_id:
        logger.warning("Webhook recebido sem payment_id.")
        return

    logger.info("Processando webhook Mercado Pago: payment_id=%s", payment_id)

    with SessionLocal() as db:
        preference_id = None
        data = payload.get("data") if isinstance(payload, dict) else None
        if isinstance(data, dict):
            preference_id = data.get("preference_id")
        preference_id = preference_id or payload.get("preference_id")

        order: Order | None = None
        preferred_token = None

        if preference_id:
            order = (
                db.query(Order)
                .filter(Order.mercadopago_preference_id == str(preference_id))
                .first()
            )
            if order and order.restaurant_id:
                restaurant = (
                    db.query(Restaurant)
                    .filter(Restaurant.id == order.restaurant_id)
                    .first()
                )
                if restaurant:
                    preferred_token = restaurant.mercadopago_access_token

        payment = None
        for token in _get_tokens(db, preferred=preferred_token):
            if not token:
                continue
            try:
                payment = get_payment(payment_id, token)
                break
            except Exception as exc:  # noqa: BLE001
                logger.warning("Falha ao consultar pagamento com token.", exc_info=exc)

        if not payment:
            logger.error("Nao foi possivel obter dados do pagamento %s.", payment_id)
            return

        preference_id = payment.get("preference_id") or preference_id
        external_ref = payment.get("external_reference")

        if not order and preference_id:
            order = (
                db.query(Order)
                .filter(Order.mercadopago_preference_id == str(preference_id))
                .first()
            )

        if not order and external_ref:
            try:
                order_id = int(str(external_ref))
                order = db.query(Order).filter(Order.id == order_id).first()
            except ValueError:
                order = None

        if not order:
            logger.warning("Pedido nao encontrado para payment_id=%s.", payment_id)
            return

        status_value = str(payment.get("status", "")).lower()
        order.mercadopago_payment_id = str(payment_id)
        if preference_id:
            order.mercadopago_preference_id = str(preference_id)

        if status_value in {"approved", "authorized"}:
            order.payment_status = "approved"
            order.status = "confirmed"
        elif status_value in {"rejected", "cancelled", "refunded", "charged_back"}:
            order.payment_status = "rejected"
        elif status_value:
            order.payment_status = status_value

        db.commit()
        logger.info(
            "Pedido %s atualizado para payment_status=%s.",
            order.id,
            order.payment_status,
        )


@router.post("/mercadopago", status_code=status.HTTP_200_OK)
async def mercadopago_webhook(
    request: Request,
    background_tasks: BackgroundTasks,
) -> dict[str, str]:
    try:
        payload = await request.json()
    except Exception:  # noqa: BLE001
        payload = {}

    payment_id = _extract_payment_id(payload, request)
    logger.info("Webhook Mercado Pago recebido: %s", _safe_log_payload(payload))

    background_tasks.add_task(_process_payment, payment_id, payload)
    return {"status": "ok"}
