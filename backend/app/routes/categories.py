from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Category, Product
from ..schemas import (
    CategoryCreate,
    CategoryDetailResponse,
    CategoryPublicResponse,
    CategoryResponse,
    CategoryUpdate,
)
from .admin import get_current_admin


router = APIRouter()


@router.get("/categories", response_model=list[CategoryPublicResponse])
def list_categories_public(db: Session = Depends(get_db)) -> list[Category]:
    return (
        db.query(Category)
        .filter(Category.is_active.is_(True))
        .order_by(Category.order.asc(), Category.id.asc())
        .all()
    )


@router.get("/categories/{slug}", response_model=CategoryDetailResponse)
def get_category_by_slug(slug: str, db: Session = Depends(get_db)) -> dict:
    category = (
        db.query(Category)
        .filter(Category.slug == slug, Category.is_active.is_(True))
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

    return {
        "id": category.id,
        "title": category.title,
        "description": category.description,
        "slug": category.slug,
        "products": products,
    }


@router.get("/admin/categories", response_model=list[CategoryResponse])
def list_categories_admin(
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> list[Category]:
    return db.query(Category).order_by(Category.order.asc(), Category.id.asc()).all()


@router.post("/admin/categories", response_model=CategoryResponse, status_code=status.HTTP_201_CREATED)
def create_category(
    payload: CategoryCreate,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> Category:
    exists = db.query(Category).filter(Category.slug == payload.slug).first()
    if exists:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Slug already exists")
    category = Category(
        name=payload.name,
        title=payload.title,
        description=payload.description,
        icon=payload.icon,
        image_url=payload.image_url,
        slug=payload.slug,
        order=payload.order,
        is_active=payload.is_active,
    )
    db.add(category)
    db.commit()
    db.refresh(category)
    return category


@router.put("/admin/categories/{category_id}", response_model=CategoryResponse)
def update_category(
    category_id: int,
    payload: CategoryUpdate,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> Category:
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Category not found")

    if payload.name is not None:
        category.name = payload.name
    if payload.title is not None:
        category.title = payload.title
    if payload.description is not None:
        category.description = payload.description
    if payload.icon is not None:
        category.icon = payload.icon
    if payload.image_url is not None:
        category.image_url = payload.image_url
    if payload.slug is not None:
        category.slug = payload.slug
    if payload.order is not None:
        category.order = payload.order
    if payload.is_active is not None:
        category.is_active = payload.is_active

    db.commit()
    db.refresh(category)
    return category


@router.delete("/admin/categories/{category_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_category(
    category_id: int,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> None:
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Category not found")

    db.delete(category)
    db.commit()
    return None
