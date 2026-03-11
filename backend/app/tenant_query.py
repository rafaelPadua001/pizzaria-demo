from __future__ import annotations

from sqlalchemy import event, or_
from sqlalchemy.orm import Session, with_loader_criteria

from .config.tenant import RESTAURANT_ID
from .models.mixins import RestaurantMixin


def _tenant_clause(cls):
    if RESTAURANT_ID == 1:
        return or_(cls.restaurant_id == RESTAURANT_ID, cls.restaurant_id.is_(None))
    return cls.restaurant_id == RESTAURANT_ID


def _apply_dml_tenant(statement):
    table = getattr(statement, "table", None)
    if table is None or "restaurant_id" not in table.c:
        return statement

    if RESTAURANT_ID == 1:
        condition = or_(table.c.restaurant_id == RESTAURANT_ID, table.c.restaurant_id.is_(None))
    else:
        condition = table.c.restaurant_id == RESTAURANT_ID

    return statement.where(condition)


@event.listens_for(Session, "do_orm_execute")
def _add_tenant_criteria(execute_state):
    if execute_state.is_select:
        execute_state.statement = execute_state.statement.options(
            with_loader_criteria(
                RestaurantMixin,
                lambda cls: _tenant_clause(cls),
                include_aliases=True,
            )
        )
        return

    if execute_state.is_update or execute_state.is_delete:
        execute_state.statement = _apply_dml_tenant(execute_state.statement)


@event.listens_for(RestaurantMixin, "before_insert", propagate=True)
def _set_restaurant_id(mapper, connection, target):
    target.restaurant_id = RESTAURANT_ID
