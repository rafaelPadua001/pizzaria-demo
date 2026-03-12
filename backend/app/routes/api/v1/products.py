from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ....database import get_db
from ....models import Product


router = APIRouter(prefix="/api/v1", tags=["api-v1"])


class ProductV1Response(BaseModel):
    id: int
    name: str
    description: str | None = None
    price: float
    category_id: int


@router.get("/products", response_model=list[ProductV1Response])
def list_products_v1(db: Session = Depends(get_db)) -> list[dict]:
    products = (
        db.query(Product)
        .filter(Product.is_active.is_(True))
        .order_by(Product.id.asc())
        .all()
    )
    return [
        {
            "id": product.id,
            "name": product.name,
            "description": product.description,
            "price": float(product.price),
            "category_id": product.category_id,
        }
        for product in products
    ]

