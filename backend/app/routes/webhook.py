from __future__ import annotations

import hashlib
import hmac
import logging
import os
from typing import Any

import httpx
from fastapi import APIRouter, HTTPException, Request, status
from sqlalchemy.orm import Session

from ..database import SessionLocal
from ..models import Order, Restaurant
from ..services.mercadopago_service import get_payment


logger = logging.getLogger("mercadopago.webhook")

router = APIRouter(prefix="/webhook", tags=["Webhook"])

MP_STATUS_MAP: dict[str, tuple[str, str | None]] = {
    "approved": ("paid", "confirmed"),
    "pending": ("pending", None),
    "in_process": ("pending", None),
    "rejected": ("failed", None),
    "cancelled": ("canceled", "canceled"),
    "canceled": ("canceled", "canceled"),
    "charged_back": ("canceled", "canceled"),
    "refunded": ("canceled", "canceled"),
}


async def notify_assistant(order_id: int, session_id: str | None, status_value: str) -> None:
    session_id_value = str(session_id or "").strip()
    if not session_id_value:
        logger.warning(
            "Pedido %s sem session_id. Notificacao do assistant ignorada.",
            order_id,
        )
        return

    notify_url = os.getenv(
        "ASSISTANT_NOTIFY_URL",
        "https://assistant-restaurant.onrender.com/assistant/notify",
    )
    payload = {
        "type": "payment_update",
        "order_id": order_id,
        "status": status_value,
        "session_id": session_id_value,
        "message": f"Pedido #{order_id} status atualizado: {str(status_value).upper()}",
    }

    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.post(notify_url, json=payload)
            response.raise_for_status()
    except Exception as exc:  # noqa: BLE001
        logger.error(
            "Falha ao enviar notificacao do pedido %s para assistant.",
            order_id,
            exc_info=exc,
        )


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
    topic = request.query_params.get("type") or request.query_params.get("topic")
    if topic:
        return str(topic)
    if isinstance(payload, dict):
        raw = payload.get("type") or payload.get("topic")
        if raw:
            return str(raw)
    return None


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


def _get_tokens(db: Session) -> list[str]:
    tokens: list[str] = []

    env_token = os.getenv("MERCADOPAGO_ACCESS_TOKEN", "")
    if env_token:
        tokens.append(env_token)

    if not tokens:
        tokens = [
            restaurant.mercadopago_access_token
            for restaurant in db.query(Restaurant).all()
            if restaurant.mercadopago_access_token
        ]

    return tokens


def _find_order(db: Session, external_ref: str | None, preference_id: str | None) -> Order | None:
    if external_ref:
        try:
            order_id = int(str(external_ref))
            order = db.query(Order).filter(Order.id == order_id).first()
            if order:
                return order
        except ValueError:
            pass

    if preference_id:
        return (
            db.query(Order)
            .filter(Order.mercadopago_preference_id == str(preference_id))
            .first()
        )
    return None


@router.post("/mercadopago", status_code=status.HTTP_200_OK)
async def mercadopago_webhook(request: Request) -> dict[str, str]:
    raw_body = await request.body()
    try:
        payload = await request.json()
    except Exception:  # noqa: BLE001
        payload = {}

    logger.info("Webhook Mercado Pago recebido: %s", _safe_log_payload(payload))

    topic = _extract_topic(payload, request)
    if topic != "payment":
        return {"status": "ignored"}

    secret = os.getenv("MERCADOPAGO_WEBHOOK_SECRET", "")
    signature = request.headers.get("X-Signature") or request.headers.get(
        "X-Webhook-Signature"
    )
    if secret and signature:
        if not _is_valid_signature(raw_body, signature, secret):
            logger.warning("Webhook com assinatura invalida.")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Assinatura invalida."
            )
    elif secret:
        logger.warning("Webhook recebido sem assinatura configurada.")

    payment_id = _extract_payment_id(payload, request)
    if not payment_id:
        logger.warning("Webhook recebido sem payment_id")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="payment_id ausente"
        )

    logger.info("Webhook payment_id=%s", payment_id)

    with SessionLocal() as db:
        payment = None
        for token in _get_tokens(db):
            if not token:
                continue
            try:
                payment = get_payment(payment_id, token)
                break
            except Exception as exc:  # noqa: BLE001
                logger.warning("Falha ao consultar pagamento com token.", exc_info=exc)

        if not payment:
            logger.warning(
                "Pagamento %s nao encontrado no MercadoPago. Ignorando webhook.",
                payment_id,
            )
            return {"status": "ignored"}

        status_value = str(payment.get("status", "")).lower()
        mapped = MP_STATUS_MAP.get(status_value)
        logger.info(
            "Pagamento %s status=%s mapped_status=%s",
            payment_id,
            status_value,
            mapped,
        )

        if not mapped:
            logger.warning("Status do MercadoPago desconhecido: %s", status_value)
            return {"status": "ignored"}

        payment_status, order_status = mapped

        preference_id = payment.get("preference_id")
        external_ref = payment.get("external_reference")
        order = _find_order(db, external_ref, preference_id)
        if not order:
            logger.warning(
                "Pedido nao encontrado. payment_id=%s external_reference=%s preference_id=%s",
                payment_id,
                external_ref,
                preference_id,
            )
            return {"status": "ignored"}

        logger.info("Pedido encontrado: order_id=%s", order.id)

        order.payment_status = payment_status
        order.mercadopago_payment_id = str(payment_id)
        if preference_id:
            order.mercadopago_preference_id = str(preference_id)
        order.status = payment_status

        try:
            db.commit()
            logger.info(
                "Pedido %s atualizado payment_status=%s order_status=%s",
                order.id,
                payment_status,
                order_status,
            )
            await notify_assistant(order.id, order.session_id, payment_status)
        except Exception as exc:  # noqa: BLE001
            db.rollback()
            logger.error("Erro ao salvar pedido %s", order.id, exc_info=exc)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Erro ao atualizar pedido.",
            ) from exc

    return {"status": "ok"}
