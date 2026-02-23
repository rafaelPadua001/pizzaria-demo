from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Order, OrderItem
from ..schemas import OrderCreate, OrderResponse
from .admin import get_current_admin


router = APIRouter()


def _create_order_from_payload(payload: OrderCreate, db: Session) -> Order:
    if not payload.items:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Items required")

    computed_total = 0.0
    order_items: list[OrderItem] = []

    for item in payload.items:
        quantity = max(int(item.quantity), 1)
        unit_price = float(item.unit_price)
        computed_total += unit_price * quantity

        order_items.append(
            OrderItem(
                product_id=item.product_id,
                product_name=item.product_name,
                quantity=quantity,
                unit_price=unit_price,
            )
        )

    total = float(payload.total_amount) if payload.total_amount is not None else computed_total

    order = Order(
        customer_name=payload.customer_name,
        customer_phone=payload.customer_phone,
        total_amount=total,
        status="pending",
    )
    db.add(order)
    db.flush()

    for order_item in order_items:
        order_item.order_id = order.id
        db.add(order_item)

    db.commit()
    db.refresh(order)
    return order


@router.get("/orders", response_model=list[OrderResponse])
def list_orders(
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> list[Order]:
    return db.query(Order).order_by(Order.created_at.desc()).all()


@router.get("/orders/{order_id}", response_model=OrderResponse)
def get_order(
    order_id: int,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> Order:
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")
    return order


@router.post("/orders", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order(
    payload: OrderCreate,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> Order:
    return _create_order_from_payload(payload, db)


@router.post("/orders/public", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order_public(
    payload: OrderCreate,
    db: Session = Depends(get_db),
) -> Order:
    return _create_order_from_payload(payload, db)
