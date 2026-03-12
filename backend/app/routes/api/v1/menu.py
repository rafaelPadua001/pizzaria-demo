from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ....database import get_db
from ....models import Category, Product


router = APIRouter(tags=["api-v1"])


class MenuProductResponse(BaseModel):
    id: int
    name: str
    description: str | None = None
    price: float


class MenuCategoryResponse(BaseModel):
    id: int
    name: str
    products: list[MenuProductResponse]


class MenuResponse(BaseModel):
    categories: list[MenuCategoryResponse]


@router.get("/menu", response_model=MenuResponse)
def get_menu(db: Session = Depends(get_db)) -> dict:
    categories = (
        db.query(Category)
        .filter(Category.is_active.is_(True))
        .order_by(Category.order.asc(), Category.id.asc())
        .all()
    )

    products = (
        db.query(Product)
        .filter(Product.is_active.is_(True))
        .order_by(Product.id.asc())
        .all()
    )

    products_by_category: dict[int, list[dict]] = {}
    for product in products:
        products_by_category.setdefault(product.category_id, []).append(
            {
                "id": product.id,
                "name": product.name,
                "description": product.description,
                "price": float(product.price),
            }
        )

    response_categories: list[dict] = []
    for category in categories:
        response_categories.append(
            {
                "id": category.id,
                "name": category.name,
                "products": products_by_category.get(category.id, []),
            }
        )

    return {"categories": response_categories}
