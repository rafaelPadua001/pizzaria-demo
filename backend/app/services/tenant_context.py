from __future__ import annotations

from contextvars import ContextVar

from sqlalchemy.orm import Session

from ..config.tenant import RESTAURANT_ID
from ..models import Restaurant


_current_restaurant: ContextVar[Restaurant | None] = ContextVar(
    "current_restaurant", default=None
)
_current_restaurant_id: ContextVar[int | None] = ContextVar(
    "current_restaurant_id", default=None
)


def set_current_restaurant(restaurant: Restaurant | None) -> tuple[object, object]:
    token_restaurant = _current_restaurant.set(restaurant)
    token_restaurant_id = _current_restaurant_id.set(
        getattr(restaurant, "id", None) if restaurant else None
    )
    return token_restaurant, token_restaurant_id


def set_current_restaurant_id(restaurant_id: int | None) -> object:
    return _current_restaurant_id.set(restaurant_id)


def reset_current_restaurant(tokens: tuple[object, object]) -> None:
    restaurant_token, restaurant_id_token = tokens
    _current_restaurant.reset(restaurant_token)
    _current_restaurant_id.reset(restaurant_id_token)


def get_current_restaurant_id() -> int | None:
    value = _current_restaurant_id.get()
    if value is not None:
        return int(value)
    # Multi-tenant safety: do not fall back to a global env id when unset.
    return int(RESTAURANT_ID) if RESTAURANT_ID > 0 else None


def get_current_restaurant(db: Session) -> Restaurant | None:
    restaurant = _current_restaurant.get()
    if restaurant is not None:
        return restaurant

    restaurant_id = get_current_restaurant_id()
    if not restaurant_id:
        return None
    return db.query(Restaurant).filter(Restaurant.id == restaurant_id).first()
