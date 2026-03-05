import os

from fastapi import APIRouter, Depends, Header, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Admin, Restaurant
from ..services.auth import hash_password

router = APIRouter(prefix="/internal", tags=["internal"])


def require_api_key(
    x_api_key: str | None = Header(default=None, alias="X-API-KEY"),
) -> None:
    expected = os.getenv("INTERNAL_API_KEY", "")
    if not expected:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="INTERNAL_API_KEY nao configurada.",
        )
    if not x_api_key or x_api_key != expected:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="API key invalida."
        )


class AdminSyncCreate(BaseModel):
    nome: str | None = Field(default=None, max_length=120)
    email: EmailStr | None = None
    senha: str = Field(min_length=6, max_length=128)
    username: str | None = Field(default=None, max_length=120)


@router.post("/admins", status_code=status.HTTP_201_CREATED)
def create_admin_internal(
    payload: AdminSyncCreate,
    db: Session = Depends(get_db),
    _: None = Depends(require_api_key),
):
    username = payload.username or payload.email or payload.nome
    if not username:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="username/email/nome obrigatorio.",
        )

    existing = db.query(Admin).filter(Admin.username == username).first()
    if existing:
        return {"id": existing.id, "username": existing.username}

    admin = Admin(
        username=username,
        password_hash=hash_password(payload.senha),
    )
    db.add(admin)
    db.commit()
    db.refresh(admin)
    return {"id": admin.id, "username": admin.username}


class RestaurantSyncCreate(BaseModel):
    name: str = Field(min_length=2, max_length=150)
    slug: str = Field(min_length=2, max_length=100)
    mercadopago_access_token: str = Field(min_length=10, max_length=255)


@router.post("/restaurants", status_code=status.HTTP_201_CREATED)
def create_restaurant_internal(
    payload: RestaurantSyncCreate,
    db: Session = Depends(get_db),
    _: None = Depends(require_api_key),
):
    existing = db.query(Restaurant).filter(Restaurant.slug == payload.slug).first()
    if existing:
        existing.name = payload.name
        existing.mercadopago_access_token = payload.mercadopago_access_token
        db.commit()
        db.refresh(existing)
        return existing

    restaurant = Restaurant(
        name=payload.name,
        slug=payload.slug,
        mercadopago_access_token=payload.mercadopago_access_token,
    )
    db.add(restaurant)
    db.commit()
    db.refresh(restaurant)
    return restaurant
