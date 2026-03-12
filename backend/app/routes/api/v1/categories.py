from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ....database import get_db
from ....models import Category, Product


router = APIRouter(prefix="/api/v1", tags=["api-v1"])


class CategoryV1Response(BaseModel):
    id: int
    name: str


class CategoryProductResponse(BaseModel):
    id: int
    name: str
    price: float


class CategoryProductsResponse(BaseModel):
    category: str
    products: list[CategoryProductResponse]


@router.get("/categories", response_model=list[CategoryV1Response])
def list_categories_v1(db: Session = Depends(get_db)) -> list[dict]:
    categories = (
        db.query(Category)
        .filter(Category.is_active.is_(True))
        .order_by(Category.order.asc(), Category.id.asc())
        .all()
    )
    return [{"id": category.id, "name": category.name} for category in categories]


@router.get("/categories/{category_id}/products", response_model=CategoryProductsResponse)
def list_products_by_category_v1(
    category_id: int,
    db: Session = Depends(get_db),
) -> dict:
    category = (
        db.query(Category)
        .filter(Category.id == category_id, Category.is_active.is_(True))
        .first()
    )
    if not category:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Category not found")

    products = (
        db.query(Product)
        .filter(Product.category_id == category.id, Product.is_active.is_(True))
        .order_by(Product.id.asc())
        .all()
    )
    category_label = category.title or category.name
    return {
        "category": category_label,
        "products": [
            {"id": product.id, "name": product.name, "price": float(product.price)}
            for product in products
        ],
    }

