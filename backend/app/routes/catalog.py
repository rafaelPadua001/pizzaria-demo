from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from .. import models
from ..database import get_db


router = APIRouter(prefix="/catalogo", tags=["Catalogo"])
PROJECT_DIR = Path(__file__).resolve().parents[3]
PUBLIC_DIR = PROJECT_DIR / "frontend" / "public"
CATALOG_HTML = PUBLIC_DIR / "catalogo" / "catalogo.html"
CHECKOUT_HTML = PUBLIC_DIR / "catalogo" / "checkout.html"


@router.get("/{slug}")
def get_catalog_by_slug(slug: str, request: Request, db: Session = Depends(get_db)):
    accepts = request.headers.get("accept", "")
    wants_json = "application/json" in accepts

    if slug in {"checkout", "checkout.html"}:
        if CHECKOUT_HTML.exists():
            return FileResponse(CHECKOUT_HTML)
        raise HTTPException(status_code=404, detail="Checkout nao encontrado")

    if not wants_json:
        if CATALOG_HTML.exists():
            return FileResponse(CATALOG_HTML)
        raise HTTPException(status_code=404, detail="Catalogo nao encontrado")

    category = (
        db.query(models.Category)
        .filter(models.Category.slug == slug, models.Category.is_active.is_(True))
        .first()
    )

    if not category:
        raise HTTPException(status_code=404, detail="Categoria não encontrada")

    products = (
        db.query(models.Product)
        .filter(
            models.Product.category_id == category.id,
            models.Product.is_active.is_(True),
        )
        .all()
    )

    return {
        "category": {
            "id": category.id,
            "name": category.name,
            "title": category.title,
            "description": category.description,
            "slug": category.slug,
        },
        "products": [
            {
                "id": product.id,
                "name": product.name,
                "description": product.description,
                "price": float(product.price),
                "image_url": f"/uploads/products/{product.image_url}" if product.image_url else None,
                "is_active": product.is_active,
                "category_id": product.category_id,
            }
            for product in products
        ],
    }
