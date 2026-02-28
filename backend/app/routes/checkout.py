from __future__ import annotations

import os
import secrets

from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Order, OrderItem, Restaurant
from ..schemas import CheckoutRequest, CheckoutResponse, OrderCreatedResponse
from ..services.mercadopago_service import create_preference


router = APIRouter(prefix="/api/orders", tags=["Checkout"])


def require_api_key(x_api_key: str | None = Header(default=None, alias="X-API-KEY")) -> None:
    expected = os.getenv("INTERNAL_API_KEY", "")
    if not expected:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="INTERNAL_API_KEY nao configurada.",
        )
    if not x_api_key or not secrets.compare_digest(x_api_key, expected):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="API key invalida.")


def _get_base_url() -> str:
    return os.getenv("BASE_URL", "http://127.0.0.1:8000").rstrip("/")


@router.post("/checkout", response_model=CheckoutResponse, status_code=status.HTTP_201_CREATED)
def create_order_checkout(
    payload: CheckoutRequest,
    db: Session = Depends(get_db),
    _=Depends(require_api_key),
) -> CheckoutResponse:
    restaurant = (
        db.query(Restaurant).filter(Restaurant.slug == payload.restaurant_slug).first()
    )
    if not restaurant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Restaurante nao encontrado."
        )

    if not payload.items:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Items required")

    delivery_fee = float(payload.delivery_fee or 0.0)

    order = Order(
        restaurant_id=restaurant.id,
        customer_name=payload.customer_name,
        customer_phone=payload.customer_phone,
        total_amount=0.0,
        delivery_fee=delivery_fee,
        status="pending",
        payment_status="pending",
    )
    db.add(order)
    db.flush()

    order_items: list[OrderItem] = []
    total = 0.0
    for item in payload.items:
        quantity = max(int(item.quantity), 1)
        unit_price = float(item.unit_price)
        total += unit_price * quantity

        order_item = OrderItem(
            order_id=order.id,
            product_id=item.product_id,
            product_name=item.product_name,
            quantity=quantity,
            unit_price=unit_price,
        )
        order_items.append(order_item)
        db.add(order_item)

    order.total_amount = total + delivery_fee
    order.items = order_items

    base_url = _get_base_url()
    notification_url = os.getenv(
        "MERCADOPAGO_NOTIFICATION_URL",
        f"{base_url}/webhook/mercadopago",
    )
    back_urls = {
        "success": f"{base_url}/payment.html",
        "failure": f"{base_url}/payment.html",
        "pending": f"{base_url}/payment.html",
    }

    try:
        preference_id, checkout_url = create_preference(
            order,
            restaurant,
            notification_url=notification_url,
            back_urls=back_urls,
        )
    except Exception as exc:  # noqa: BLE001
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=str(exc),
        ) from exc

    order.mercadopago_preference_id = preference_id
    db.commit()
    db.refresh(order)

    return CheckoutResponse(order_id=order.id, checkout_url=checkout_url)


@router.post("/precheckout", response_model=OrderCreatedResponse, status_code=status.HTTP_201_CREATED)
def create_order_precheckout(
    payload: CheckoutRequest,
    db: Session = Depends(get_db),
    _=Depends(require_api_key),
) -> OrderCreatedResponse:
    restaurant = (
        db.query(Restaurant).filter(Restaurant.slug == payload.restaurant_slug).first()
    )
    if not restaurant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Restaurante nao encontrado."
        )

    if not payload.items:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Items required")

    delivery_fee = float(payload.delivery_fee or 0.0)

    order = Order(
        restaurant_id=restaurant.id,
        customer_name=payload.customer_name,
        customer_phone=payload.customer_phone,
        total_amount=0.0,
        delivery_fee=delivery_fee,
        status="pending",
        payment_status="pending",
    )
    db.add(order)
    db.flush()

    order_items: list[OrderItem] = []
    total = 0.0
    for item in payload.items:
        quantity = max(int(item.quantity), 1)
        unit_price = float(item.unit_price)
        total += unit_price * quantity

        order_item = OrderItem(
            order_id=order.id,
            product_id=item.product_id,
            product_name=item.product_name,
            quantity=quantity,
            unit_price=unit_price,
        )
        order_items.append(order_item)
        db.add(order_item)

    order.total_amount = total + delivery_fee
    order.items = order_items

    db.commit()
    db.refresh(order)

    return OrderCreatedResponse(order_id=order.id)


@router.post(
    "/checkout/{order_id}",
    response_model=CheckoutResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_checkout_for_order(
    order_id: int,
    db: Session = Depends(get_db),
    _=Depends(require_api_key),
) -> CheckoutResponse:
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pedido nao encontrado.")

    if not order.items:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Items required")

    restaurant = db.query(Restaurant).filter(Restaurant.id == order.restaurant_id).first()
    if not restaurant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Restaurante nao encontrado."
        )

    base_url = _get_base_url()
    notification_url = os.getenv(
        "MERCADOPAGO_NOTIFICATION_URL",
        f"{base_url}/webhook/mercadopago",
    )
    back_urls = {
        "success": f"{base_url}/payment.html",
        "failure": f"{base_url}/payment.html",
        "pending": f"{base_url}/payment.html",
    }


    try:
        preference_id, checkout_url = create_preference(
            order,
            restaurant,
            notification_url=notification_url,
            back_urls=back_urls,
        )
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=str(exc),
        ) from exc

    order.mercadopago_preference_id = preference_id
    db.commit()
    db.refresh(order)

    return CheckoutResponse(order_id=order.id, checkout_url=checkout_url)
