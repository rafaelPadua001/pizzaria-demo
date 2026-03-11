from pathlib import Path

from fastapi import APIRouter, HTTPException, status
from fastapi.responses import FileResponse


router = APIRouter(tags=["tenant-pages"])

BASE_DIR = Path(__file__).resolve().parent.parent
PROJECT_DIR = BASE_DIR.parent.parent
PUBLIC_DIR = PROJECT_DIR / "frontend" / "public"
CATALOG_HTML = PUBLIC_DIR / "catalogo" / "catalogo.html"
CHECKOUT_HTML = PUBLIC_DIR / "catalogo" / "checkout.html"


@router.get("/menu")
def serve_menu() -> FileResponse:
    if not CATALOG_HTML.exists():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Menu nao encontrado",
        )
    return FileResponse(CATALOG_HTML)


@router.get("/checkout")
def serve_checkout() -> FileResponse:
    if not CHECKOUT_HTML.exists():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Checkout nao encontrado",
        )
    return FileResponse(CHECKOUT_HTML)
