from fastapi import APIRouter, Depends, HTTPException, status
from datetime import datetime

from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Admin
from ..services.auth import hash_password
from .admin import get_current_admin

router = APIRouter(tags=["admins"])


class AdminCreate(BaseModel):
    nome: str = Field(min_length=2, max_length=120)
    email: EmailStr
    senha: str = Field(min_length=6, max_length=128)


class AdminUpdate(BaseModel):
    nome: str | None = Field(default=None, min_length=2, max_length=120)
    email: EmailStr | None = None
    senha: str | None = Field(default=None, min_length=6, max_length=128)


class AdminResponse(BaseModel):
    id: int
    nome: str
    email: EmailStr
    created_at: datetime

    model_config = {"from_attributes": True}


@router.get("/admins", response_model=list[AdminResponse])
async def list_admins(
    db: Session = Depends(get_db),
    current_admin: Admin = Depends(get_current_admin),
):
    return db.query(Admin).order_by(Admin.id).all()


@router.get("/admin/me", response_model=AdminResponse)
async def get_admin_me(
    current_admin: Admin = Depends(get_current_admin),
):
    return current_admin


@router.post("/admins", response_model=AdminResponse, status_code=status.HTTP_201_CREATED)
async def create_admin(
    payload: AdminCreate,
    db: Session = Depends(get_db),
    current_admin: Admin = Depends(get_current_admin),
):
    if db.query(Admin).filter(Admin.email == payload.email).first():
        raise HTTPException(status_code=409, detail="Email ja cadastrado")

    admin = Admin(
        nome=payload.nome,
        email=payload.email,
        senha_hash=hash_password(payload.senha),
    )
    db.add(admin)
    db.commit()
    db.refresh(admin)
    return admin


@router.post(
    "/admins/bootstrap",
    response_model=AdminResponse,
    status_code=status.HTTP_201_CREATED,
)
async def bootstrap_admin(
    payload: AdminCreate,
    db: Session = Depends(get_db),
):
    existing_admin = db.query(Admin).first()
    if existing_admin:
        raise HTTPException(status_code=403, detail="Bootstrap ja executado")

    admin = Admin(
        nome=payload.nome,
        email=payload.email,
        senha_hash=hash_password(payload.senha),
    )

    db.add(admin)
    db.commit()
    db.refresh(admin)
    return admin


@router.put("/admins/{admin_id}", response_model=AdminResponse)
async def update_admin(
    admin_id: int,
    payload: AdminUpdate,
    db: Session = Depends(get_db),
    current_admin: Admin = Depends(get_current_admin),
):
    admin = db.query(Admin).filter(Admin.id == admin_id).first()
    if not admin:
        raise HTTPException(status_code=404, detail="Admin nao encontrado")

    if payload.email and payload.email != admin.email:
        if db.query(Admin).filter(Admin.email == payload.email).first():
            raise HTTPException(status_code=409, detail="Email ja cadastrado")
        admin.email = payload.email
    if payload.nome:
        admin.nome = payload.nome
    if payload.senha:
        admin.senha_hash = hash_password(payload.senha)

    db.commit()
    db.refresh(admin)
    return admin


@router.delete("/admins/{admin_id}", response_model=AdminResponse)
async def delete_admin(
    admin_id: int,
    db: Session = Depends(get_db),
    current_admin: Admin = Depends(get_current_admin),
):
    admin = db.query(Admin).filter(Admin.id == admin_id).first()
    if not admin:
        raise HTTPException(status_code=404, detail="Admin nao encontrado")

    db.delete(admin)
    db.commit()
    return admin
