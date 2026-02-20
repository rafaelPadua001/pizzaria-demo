from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Admin
from ..schemas import AdminLoginRequest, TokenResponse
from ..services.auth import create_access_token, verify_password


router = APIRouter()


@router.post("/auth/login", response_model=TokenResponse)
def login(payload: AdminLoginRequest, db: Session = Depends(get_db)) -> TokenResponse:
    admin = db.query(Admin).filter(Admin.username == payload.username).first()
    if not admin or not verify_password(payload.password, admin.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais invalidas",
        )

    token = create_access_token({"sub": str(admin.id), "username": admin.username})
    return TokenResponse(access_token=token, token_type="bearer")
