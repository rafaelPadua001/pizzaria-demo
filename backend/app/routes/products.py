from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Product, Category
from ..schemas import ProductCreate, ProductResponse, ProductUpdate
from .admin import get_current_admin
from ..services.cloudinary_service import upload_product_image
from ..services.image_utils import resolve_image_url
from ..services.tenant_context import get_current_restaurant


router = APIRouter()


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
def update_product(
    product_id: int,
    payload: ProductUpdate,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> Product:
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")

    if payload.category_id is not None:
        category = db.query(Category).filter(Category.id == payload.category_id).first()
        if not category:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Category not found")
        product.category_id = payload.category_id

    if payload.name is not None:
        product.name = payload.name
    if payload.description is not None:
        product.description = payload.description
    if payload.price is not None:
        product.price = payload.price
    if payload.image_url is not None:
        product.image_url = payload.image_url
    if payload.is_active is not None:
        product.is_active = payload.is_active

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

    db.delete(product)
    db.commit()
    return None
