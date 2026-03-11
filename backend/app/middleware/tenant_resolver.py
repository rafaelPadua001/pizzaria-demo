from __future__ import annotations

from typing import Iterable

from fastapi import Request
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware

from ..config.tenant import RESTAURANT_ID
from ..database import SessionLocal
from ..models import Restaurant
from ..services.tenant_context import reset_current_restaurant, set_current_restaurant


RESERVED_PREFIXES = {
    "admin",
    "admins",
    "auth",
    "categories",
    "checkout",
    "config",
    "content",
    "debug",
    "health",
    "internal",
    "menu",
    "orders",
    "payments",
    "products",
    "static",
    "uploads",
    "webhook",
    "catalogo",
}

SLUG_PATH_MARKERS = {
    "admin",
    "categories",
    "checkout",
    "config",
    "content",
    "menu",
    "orders",
    "payments",
    "products",
    "webhook",
    "catalogo",
}


class TenantResolverMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        slug = _extract_slug_from_subdomain(request)
        if not slug:
            slug = _extract_slug_from_path(request.url.path)

        restaurant = None
        restaurant_id = None

        if slug:
            with SessionLocal() as db:
                restaurant = db.query(Restaurant).filter(Restaurant.slug == slug).first()
            if not restaurant:
                return JSONResponse(
                    status_code=404,
                    content={"detail": "Restaurant not found"},
                )
            restaurant_id = restaurant.id
        else:
            restaurant_id = RESTAURANT_ID
            if restaurant_id:
                with SessionLocal() as db:
                    restaurant = (
                        db.query(Restaurant)
                        .filter(Restaurant.id == restaurant_id)
                        .first()
                    )

        request.state.restaurant = restaurant
        request.state.restaurant_id = restaurant_id

        tokens = set_current_restaurant(restaurant)
        try:
            return await call_next(request)
        finally:
            reset_current_restaurant(tokens)


def _extract_slug_from_path(path: str) -> str | None:
    parts = [segment for segment in path.split("/") if segment]
    if not parts:
        return None
    if parts[0] in RESERVED_PREFIXES:
        return None
    if len(parts) < 2:
        return None
    if parts[1] not in SLUG_PATH_MARKERS:
        return None
    return parts[0]


def _extract_slug_from_subdomain(request: Request) -> str | None:
    host = request.headers.get("host", "")
    if not host:
        return None

    host = host.split(":", 1)[0].strip().lower()
    if not host or host.replace(".", "").isdigit():
        return None

    parts = host.split(".")
    if len(parts) < 3:
        return None

    subdomain = parts[0].strip()
    return subdomain or None
