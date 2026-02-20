from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Order, OrderItem, Product
from ..schemas import OrderCreate, OrderResponse
from .admin import get_current_admin


router = APIRouter()


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
    if not payload.items:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Items required")

    total = 0.0
    order_items: list[OrderItem] = []

    for item in payload.items:
        product = db.query(Product).filter(Product.id == item.product_id).first()
        if not product:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Product {item.product_id} not found",
            )

        quantity = max(int(item.quantity), 1)
        unit_price = float(product.price)
        total += unit_price * quantity

        order_items.append(
            OrderItem(product_id=product.id, quantity=quantity, unit_price=unit_price)
        )

    order = Order(total=total)
    db.add(order)
    db.flush()

    for order_item in order_items:
        order_item.order_id = order.id
        db.add(order_item)

    db.commit()
    db.refresh(order)
    return order
