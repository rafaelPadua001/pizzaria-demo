from fastapi import APIRouter, HTTPException, status
from sqlalchemy.orm import Session
from fastapi import Depends

from ..database import get_db
from ..models import Page, PageSection
from ..schemas import PageResponse, PageSectionResponse


router = APIRouter(prefix="/content", tags=["content"])


@router.get("/sections", response_model=list[PageSectionResponse])
def list_public_sections(db: Session = Depends(get_db)) -> list[PageSection]:
    return db.query(PageSection).order_by(PageSection.order.asc(), PageSection.id.asc()).all()


@router.get("/pages/{slug}", response_model=PageResponse)
def get_page(slug: str, db: Session = Depends(get_db)) -> Page:
    page = db.query(Page).filter(Page.slug == slug).first()
    if not page:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Page not found")
    return page
