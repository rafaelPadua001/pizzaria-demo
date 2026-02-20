from pathlib import Path
from uuid import uuid4

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Page, PageSection
from ..schemas import (
    PageCreate,
    PageResponse,
    PageSectionCreate,
    PageSectionResponse,
    PageSectionUpdate,
    PageUpdate,
)
from .admin import get_current_admin


router = APIRouter(prefix="/admin", tags=["admin-content"])

BASE_DIR = Path(__file__).resolve().parent.parent
UPLOAD_DIR = BASE_DIR / "static" / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


@router.get("/sections", response_model=list[PageSectionResponse])
def list_page_sections(
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> list[PageSection]:
    return db.query(PageSection).order_by(PageSection.order.asc(), PageSection.id.asc()).all()


@router.post("/sections", response_model=PageSectionResponse, status_code=status.HTTP_201_CREATED)
def create_page_section(
    payload: PageSectionCreate,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> PageSection:
    exists = db.query(PageSection).filter(PageSection.name == payload.name).first()
    if exists:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Section name already exists")
    section = PageSection(
        name=payload.name,
        title=payload.title,
        subtitle=payload.subtitle,
        content=payload.content,
        image_url=payload.image_url,
        link=payload.link,
        order=payload.order,
    )
    db.add(section)
    db.commit()
    db.refresh(section)
    return section


@router.put("/sections/{section_id}", response_model=PageSectionResponse)
def update_page_section(
    section_id: int,
    payload: PageSectionUpdate,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> PageSection:
    section = db.query(PageSection).filter(PageSection.id == section_id).first()
    if not section:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Section not found")

    if payload.name is not None:
        section.name = payload.name
    if payload.title is not None:
        section.title = payload.title
    if payload.subtitle is not None:
        section.subtitle = payload.subtitle
    if payload.content is not None:
        section.content = payload.content
    if payload.image_url is not None:
        section.image_url = payload.image_url
    if payload.link is not None:
        section.link = payload.link
    if payload.order is not None:
        section.order = payload.order

    db.commit()
    db.refresh(section)
    return section


@router.delete("/sections/{section_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_page_section(
    section_id: int,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> None:
    section = db.query(PageSection).filter(PageSection.id == section_id).first()
    if not section:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Section not found")
    db.delete(section)
    db.commit()
    return None


@router.get("/pages", response_model=list[PageResponse])
def list_pages(
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> list[Page]:
    return db.query(Page).order_by(Page.id.asc()).all()


@router.post("/pages", response_model=PageResponse, status_code=status.HTTP_201_CREATED)
def create_page(
    payload: PageCreate,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> Page:
    exists = db.query(Page).filter(Page.slug == payload.slug).first()
    if exists:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Slug already exists")
    page = Page(slug=payload.slug, title=payload.title, content=payload.content)
    db.add(page)
    db.commit()
    db.refresh(page)
    return page


@router.put("/pages/{page_id}", response_model=PageResponse)
def update_page(
    page_id: int,
    payload: PageUpdate,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> Page:
    page = db.query(Page).filter(Page.id == page_id).first()
    if not page:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Page not found")

    if payload.slug is not None:
        page.slug = payload.slug
    if payload.title is not None:
        page.title = payload.title
    if payload.content is not None:
        page.content = payload.content

    db.commit()
    db.refresh(page)
    return page


@router.delete("/pages/{page_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_page(
    page_id: int,
    db: Session = Depends(get_db),
    _admin=Depends(get_current_admin),
) -> None:
    page = db.query(Page).filter(Page.id == page_id).first()
    if not page:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Page not found")
    db.delete(page)
    db.commit()
    return None


@router.post("/upload")
def upload_file(
    file: UploadFile = File(...),
    _admin=Depends(get_current_admin),
) -> dict:
    suffix = Path(file.filename).suffix.lower()
    name = f"{uuid4().hex}{suffix}"
    target = UPLOAD_DIR / name
    with target.open("wb") as buffer:
        buffer.write(file.file.read())
    return {"url": f"/static/uploads/{name}"}
