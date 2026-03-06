from __future__ import annotations

import hashlib
import hmac
import logging
import os
from typing import Any

from fastapi import APIRouter, BackgroundTasks, HTTPException, Request, status
from sqlalchemy.orm import Session

from ..database import SessionLocal
from ..models import Order, Restaurant
from ..services.mercadopago_service import get_payment, get_merchant_order
from ..services.order_service import update_order_status, update_payment_status


logger = logging.getLogger("mercadopago.webhook")

router = APIRouter(prefix="/webhook", tags=["Webhook"])

MP_STATUS_MAP = {
    "approved": "paid",
    "pending": "pending",
    "in_process": "pending",
    "rejected": "canceled",
    "cancelled": "canceled",
    "canceled": "canceled",
    "charged_back": "canceled",
    "refunded": "canceled",
}


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


def _extract_topic(payload: dict[str, Any], request: Request) -> str | None:
    if isinstance(payload, dict):
        topic = payload.get("topic") or payload.get("type")
        if topic:
            return str(topic)
    query = request.query_params
    return query.get("topic") or query.get("type")


def _extract_merchant_order_id(payload: dict[str, Any], request: Request) -> str | None:
    data = payload.get("data") if isinstance(payload, dict) else None
    if isinstance(data, dict):
        merchant_id = data.get("id")
        if merchant_id:
            return str(merchant_id)
    merchant_id = payload.get("id") if isinstance(payload, dict) else None
    if merchant_id:
        return str(merchant_id)
    query = request.query_params
    return query.get("id") or query.get("data.id")


def _safe_log_payload(payload: dict[str, Any]) -> dict[str, Any]:
    if not isinstance(payload, dict):
        return {"payload": "invalid"}
    data = payload.get("data")
    return {
        "type": payload.get("type") or payload.get("topic"),
        "action": payload.get("action"),
        "data_id": data.get("id") if isinstance(data, dict) else payload.get("id"),
    }


def _is_valid_signature(raw_body: bytes, signature: str, secret: str) -> bool:
    digest = hmac.new(secret.encode("utf-8"), raw_body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(digest, signature)


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


def _resolve_payment_from_merchant_order(
    db: Session,
    merchant_order_id: str,
    preferred_token: str | None,
) -> str | None:
    for token in _get_tokens(db, preferred=preferred_token):
        if not token:
            continue
        try:
            merchant_order = get_merchant_order(merchant_order_id, token)
        except Exception as exc:  # noqa: BLE001
            logger.warning("Falha ao consultar merchant_order.", exc_info=exc)
            continue

        payments = merchant_order.get("payments") if isinstance(merchant_order, dict) else None
        if not payments:
            continue
        for payment in payments:
            if not isinstance(payment, dict):
                continue
            payment_id = payment.get("id") or payment.get("payment_id")
            if payment_id:
                return str(payment_id)
    return None


def _process_payment(
    payment_id: str | None,
    payload: dict[str, Any],
    topic: str | None,
    merchant_order_id: str | None,
) -> None:
    if not payment_id and topic != "merchant_order":
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

        if topic == "merchant_order" and merchant_order_id:
            payment_id = _resolve_payment_from_merchant_order(
                db, merchant_order_id, preferred_token
            )
            if not payment_id:
                logger.warning(
                    "merchant_order %s sem pagamentos associados.",
                    merchant_order_id,
                )
                return

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
            logger.info(
                "Webhook ignorado (pedido nao encontrado). payment_id=%s external_reference=%s",
                payment_id,
                payment.get("external_reference"),
            )
            return

        status_value = str(payment.get("status", "")).lower()
        order.mercadopago_payment_id = str(payment_id)
        if preference_id:
            order.mercadopago_preference_id = str(preference_id)

        db.commit()

        mapped_payment_status = MP_STATUS_MAP.get(status_value)
        if not mapped_payment_status and status_value:
            logger.warning("Status do MercadoPago desconhecido: %s", status_value)
        elif mapped_payment_status:
            try:
                update_payment_status(order.id, mapped_payment_status)
            except Exception as exc:  # noqa: BLE001
                logger.warning(
                    "Falha ao atualizar payment_status do pedido %s para %s.",
                    order.id,
                    mapped_payment_status,
                    exc_info=exc,
                )

        if mapped_payment_status == "paid":
            try:
                update_order_status(order.id, "pending")
            except Exception as exc:  # noqa: BLE001
                logger.warning(
                    "Falha ao atualizar order_status do pedido %s para pending.",
                    order.id,
                    exc_info=exc,
                )
        elif mapped_payment_status in {"canceled", "cancelled"}:
            try:
                update_order_status(order.id, "cancelled")
            except Exception as exc:  # noqa: BLE001
                logger.warning(
                    "Falha ao atualizar order_status do pedido %s para cancelled.",
                    order.id,
                    exc_info=exc,
                )


@router.post("/mercadopago", status_code=status.HTTP_200_OK)
async def mercadopago_webhook(
    request: Request,
    background_tasks: BackgroundTasks,
) -> dict[str, str]:
    raw_body = await request.body()
    try:
        payload = await request.json()
    except Exception:  # noqa: BLE001
        payload = {}

    topic = _extract_topic(payload, request)
    if topic != "payment":
        return {"status": "ignored"}

    secret = os.getenv("MERCADOPAGO_WEBHOOK_SECRET", "")
    signature = request.headers.get("X-Signature") or request.headers.get("X-Webhook-Signature")
    if secret and signature:
        if not _is_valid_signature(raw_body, signature, secret):
            logger.warning("Webhook com assinatura invalida.")
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Assinatura invalida.")
    elif secret:
        logger.warning("Webhook recebido sem assinatura configurada.")

    payment_id = _extract_payment_id(payload, request)
    logger.info("Webhook Mercado Pago recebido: %s", _safe_log_payload(payload))

    background_tasks.add_task(_process_payment, payment_id, payload, topic, None)
    return {"status": "ok"}
