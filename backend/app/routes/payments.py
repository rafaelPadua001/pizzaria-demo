from __future__ import annotations

import logging
import os
import secrets

from fastapi import APIRouter, Depends, Header, HTTPException, status
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Order, Restaurant
from ..schemas import PaymentCreate, PaymentResponse
from ..services.mercadopago_service import create_preference


logger = logging.getLogger("payments")

router = APIRouter(tags=["Payments"])


def _get_base_url() -> str:
    return os.getenv("BASE_URL", "http://127.0.0.1:8000").rstrip("/")


def _require_api_key(x_api_key: str | None = Header(default=None, alias="X-API-KEY")) -> None:
    expected = os.getenv("INTERNAL_API_KEY", "")
    if not expected:
        return
    if not x_api_key or not secrets.compare_digest(x_api_key, expected):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="API key invalida.")


@router.post("/payments/create", response_model=PaymentResponse, status_code=status.HTTP_201_CREATED)
def create_payment(
    payload: PaymentCreate,
    db: Session = Depends(get_db),
    _=Depends(_require_api_key),
) -> PaymentResponse:
    order = db.query(Order).filter(Order.id == payload.order_id).first()
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pedido nao encontrado.")

    if not order.restaurant_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Pedido sem restaurante.")

    restaurant = (
        db.query(Restaurant).filter(Restaurant.id == order.restaurant_id).first()
    )
    if not restaurant:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Restaurante nao encontrado.")

    base_url = _get_base_url()
    back_urls = {
        "success": f"{base_url}/payment.html",
        "failure": f"{base_url}/payment.html",
        "pending": f"{base_url}/payment.html",
    }
    notification_url = os.getenv(
        "MERCADOPAGO_NOTIFICATION_URL",
        f"{base_url}/webhook/mercadopago",
    )

    try:
        preference_id, init_point = create_preference(
            order,
            restaurant,
            notification_url=notification_url,
            back_urls=back_urls,
        )
    except Exception as exc:  # noqa: BLE001
        logger.error("Erro ao criar preferencia Mercado Pago.", exc_info=exc)
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Falha ao criar preferencia de pagamento.",
        ) from exc

    order.mercadopago_preference_id = preference_id
    db.commit()
    db.refresh(order)

    return PaymentResponse(
        order_id=order.id,
        preference_id=preference_id,
        init_point=init_point,
    )

@router.get("/payment-status/{payment_id}")
def payment_status(payment_id: str, db: Session = Depends(get_db)):
    order = db.query(Order).filter(
        Order.mercadopago_payment_id == payment_id
    ).first()

    if not order:
        return {"payment_status": "not_found"}
    
    return {"payment_status": order.payment_status}


@router.get("/payment-status/{payment_id}")
def payment_status_api(payment_id: str, db: Session = Depends(get_db)):
    return payment_status(payment_id=payment_id, db=db)

#@router.get("/payment/success", response_class=HTMLResponse)
#def payment_success() -> str:
#    return "<h1>Pagamento aprovado</h1><p>sp>"
#
#
#@router.get("/payment/failure", response_class=HTMLResponse)
#def payment_failure() -> str:
#    return "<h1>Pagamento nao aprovado</h1><p>Voce pode tentar novamente.</p>"
#
#
#@router.get("/payment/pending", response_class=HTMLResponse)
#def payment_pending() -> str:
#    return "<h1>Pagamento pendente</h1><p>Estamos aguardando a confirmacao.</p>"
#
