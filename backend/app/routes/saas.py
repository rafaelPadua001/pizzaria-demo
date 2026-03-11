from __future__ import annotations

import os
import secrets

from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Admin, Category, Product, Restaurant, Role, User
from ..schemas import SaaSRestaurantCreate, SaaSRestaurantResponse
from ..services.auth import hash_password
from ..services.tenant_context import reset_current_restaurant, set_current_restaurant


router = APIRouter(prefix="/saas", tags=["saas"])

DEFAULT_CATEGORIES = [
    {
        "name": "pizzas",
        "title": "Pizzas",
        "description": "Classicas e especiais com massa artesanal.",
        "icon": "??",
        "slug": "pizzas",
        "order": 1,
        "is_active": True,
    },
    {
        "name": "lanches",
        "title": "Lanches",
        "description": "Combos completos para matar a fome.",
        "icon": "??",
        "slug": "lanches",
        "order": 2,
        "is_active": True,
    },
    {
        "name": "bebidas",
        "title": "Bebidas",
        "description": "Refrigerantes, sucos e aguas geladas.",
        "icon": "??",
        "slug": "bebidas",
        "order": 3,
        "is_active": True,
    },
]

DEFAULT_PRODUCTS = [
    {
        "category": "pizzas",
        "name": "Pizza Margherita",
        "description": "Molho de tomate, mussarela e manjericao.",
        "price": 39.9,
    },
    {
        "category": "lanches",
        "name": "Combo Classico",
        "description": "Hamburguer, batata e refrigerante.",
        "price": 29.9,
    },
    {
        "category": "bebidas",
        "name": "Refrigerante Lata",
        "description": "Lata 350ml gelada.",
        "price": 6.5,
    },
]


def _require_api_key(x_api_key: str | None = Header(default=None, alias="X-API-KEY")) -> None:
    expected = os.getenv("INTERNAL_API_KEY", "")
    if not expected:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="INTERNAL_API_KEY nao configurada.",
        )
    if not x_api_key or not secrets.compare_digest(x_api_key, expected):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="API key invalida.")


def _slug_with_restaurant(restaurant_slug: str, slug: str) -> str:
    return f"{restaurant_slug}-{slug}"


def _seed_default_data(db: Session, restaurant: Restaurant) -> None:
    tokens = set_current_restaurant(restaurant)
    try:
        category_map: dict[str, Category] = {}
        for payload in DEFAULT_CATEGORIES:
            category = Category(
                name=payload["name"],
                title=payload["title"],
                description=payload["description"],
                icon=payload["icon"],
                slug=_slug_with_restaurant(restaurant.slug, payload["slug"]),
                order=payload["order"],
                is_active=payload["is_active"],
            )
            db.add(category)
            db.flush()
            category_map[payload["slug"]] = category

        for payload in DEFAULT_PRODUCTS:
            category = category_map.get(payload["category"])
            if not category:
                continue
            db.add(
                Product(
                    name=payload["name"],
                    description=payload["description"],
                    price=payload["price"],
                    is_active=True,
                    category_id=category.id,
                )
            )
    finally:
        reset_current_restaurant(tokens)


@router.post("/restaurants", response_model=SaaSRestaurantResponse, status_code=status.HTTP_201_CREATED)
def create_restaurant_saas(
    payload: SaaSRestaurantCreate,
    db: Session = Depends(get_db),
    _=Depends(_require_api_key),
) -> SaaSRestaurantResponse:
    if db.query(Restaurant).filter(Restaurant.slug == payload.slug).first():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Slug ja cadastrado.")

    if db.query(User).filter(User.email == payload.admin_email).first():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email ja cadastrado.")

    if db.query(Admin).filter(Admin.username == payload.admin_email).first():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Admin ja cadastrado.")

    access_token = (
        payload.mercadopago_access_token
        or os.getenv("MERCADOPAGO_ACCESS_TOKEN")
        or os.getenv("MERCADO_PAGO_ACCESS_TOKEN")
    )
    if not access_token:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Mercado Pago access token nao configurado.",
        )

    restaurant = Restaurant(
        name=payload.name,
        slug=payload.slug,
        logo_url=payload.logo_url,
        primary_color=payload.primary_color,
        whatsapp_number=payload.whatsapp_number,
        email=payload.email,
        address=payload.address,
        city=payload.city,
        state=payload.state,
        mercadopago_access_token=access_token,
        mercadopago_public_key=payload.mercadopago_public_key,
        assistant_enabled=True,
    )
    db.add(restaurant)
    db.flush()

    for role_name in ("super_admin", "restaurant_admin"):
        if not db.query(Role).filter(Role.name == role_name).first():
            db.add(Role(name=role_name))

    password_hash = hash_password(payload.admin_password)

    admin = Admin(
        username=payload.admin_email,
        password_hash=password_hash,
        role="restaurant_admin",
        restaurant_id=restaurant.id,
    )
    db.add(admin)

    user = User(
        email=payload.admin_email,
        password_hash=password_hash,
        role="restaurant_admin",
        restaurant_id=restaurant.id,
    )
    db.add(user)

    _seed_default_data(db, restaurant)

    db.commit()

    return SaaSRestaurantResponse(
        restaurant_id=restaurant.id,
        slug=restaurant.slug,
        admin_username=admin.username,
    )
