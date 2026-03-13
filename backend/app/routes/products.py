import logging

from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form, Request
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Product, Category
from ..schemas import ProductCreate, ProductResponse
from .admin import get_current_admin
from ..services.cloudinary_service import (
    delete_cloudinary_image,
    upload_product_image,
)
from ..services.image_utils import resolve_image_url
from ..services.tenant_context import get_current_restaurant


router = APIRouter()
logger = logging.getLogger("products")


@router.get("/products", response_model=list[ProductResponse])
def list_products(
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> list[Product]:
    products = db.query(Product).order_by(Product.id.asc()).all()
    return [
        {
            "id": product.id,
            "name": product.name,
            "description": product.description,
            "price": float(product.price),
            "image_url": resolve_image_url(product.image_url),
            "is_active": product.is_active,
            "category_id": product.category_id,
        }
        for product in products
    ]


@router.post("/products", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def create_product(
    name: str = Form(...),
    description: str = Form(""),
    price: float = Form(...),
    category_id: int = Form(...),
    is_active: bool = Form(True),
    image: UploadFile | None = File(None),
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> Product:
    category = db.query(Category).filter(Category.id == category_id).first()
    if not category:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Category not found")

    image_url = None
    if image and image.filename:
        restaurant = get_current_restaurant(db)
        restaurant_name = (
            (restaurant.slug or "").strip()
            if restaurant is not None
            else ""
        )
        if not restaurant_name:
            restaurant_name = (restaurant.name or "").strip() if restaurant else "default"
        image_url = upload_product_image(image, restaurant_name)

    product = Product(
        name=name,
        description=description or None,
        price=price,
        image_url=image_url,
        is_active=is_active,
        category_id=category_id,
    )
    db.add(product)
    db.commit()
    db.refresh(product)
    return {
        "id": product.id,
        "name": product.name,
        "description": product.description,
        "price": float(product.price),
        "image_url": resolve_image_url(product.image_url),
        "is_active": product.is_active,
        "category_id": product.category_id,
    }


@router.put("/products/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: int,
    request: Request,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> Product:
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")

    data: dict = {}
    file: UploadFile | None = None

    content_type = request.headers.get("content-type", "")
    if "multipart/form-data" in content_type:
        form = await request.form()
        data = {key: value for key, value in form.items() if key not in {"file", "image"}}
        file = form.get("file") or form.get("image")
    else:
        try:
            data = await request.json()
        except Exception:
            data = {}

    name = data.get("name")
    description = data.get("description")
    price = data.get("price")
    image_url = data.get("image_url")
    is_active = data.get("is_active")
    category_id = data.get("category_id")

    if category_id is not None:
        try:
            category_id_value = int(category_id)
        except (TypeError, ValueError):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Category not found")
        category = db.query(Category).filter(Category.id == category_id_value).first()
        if not category:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Category not found")
        product.category_id = category_id_value

    if name is not None:
        product.name = name
    if description is not None:
        product.description = description
    if price is not None:
        try:
            product.price = float(price)
        except (TypeError, ValueError):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid price")
    if is_active is not None:
        if isinstance(is_active, str):
            product.is_active = is_active.strip().lower() == "true"
        else:
            product.is_active = bool(is_active)

    if file and file.filename:
        if product.image_url and product.image_url.startswith("http"):
            try:
                delete_cloudinary_image(product.image_url)
            except Exception as exc:  # noqa: BLE001
                logger.warning("Falha ao remover imagem antiga.", exc_info=exc)
        restaurant = get_current_restaurant(db)
        restaurant_name = (restaurant.slug or "").strip() if restaurant is not None else ""
        if not restaurant_name:
            restaurant_name = (restaurant.name or "").strip() if restaurant else "default"
        try:
            product.image_url = upload_product_image(file, restaurant_name)
        except Exception as exc:  # noqa: BLE001
            logger.error("Erro ao enviar imagem ao Cloudinary.", exc_info=exc)
            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="Erro ao enviar imagem ao Cloudinary.",
            ) from exc
    elif "image_url" in data and isinstance(image_url, str):
        new_image_url = image_url.strip()
        if new_image_url and new_image_url.startswith("http"):
            if product.image_url and product.image_url.startswith("http"):
                if new_image_url != product.image_url:
                    try:
                        delete_cloudinary_image(product.image_url)
                    except Exception as exc:  # noqa: BLE001
                        logger.warning("Falha ao remover imagem antiga.", exc_info=exc)
            product.image_url = new_image_url

    db.commit()
    db.refresh(product)
    return {
        "id": product.id,
        "name": product.name,
        "description": product.description,
        "price": float(product.price),
        "image_url": resolve_image_url(product.image_url),
        "is_active": product.is_active,
        "category_id": product.category_id,
    }


@router.delete("/products/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(
    product_id: int,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> None:
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")

    if product.image_url and product.image_url.startswith("http"):
        try:
            delete_cloudinary_image(product.image_url)
        except Exception as exc:  # noqa: BLE001
            logger.warning("Falha ao remover imagem no Cloudinary.", exc_info=exc)

    db.delete(product)
    db.commit()
    return None
