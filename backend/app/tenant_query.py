from __future__ import annotations

from sqlalchemy import event, or_, true
from sqlalchemy.orm import Session, with_loader_criteria

from .config.tenant import RESTAURANT_ID
from .models.mixins import RestaurantMixin
from .services.tenant_context import get_current_restaurant_id


def _tenant_clause(cls):
    tenant_id = get_current_restaurant_id()
    if tenant_id is None:
        return true()
    if RESTAURANT_ID == 1 and tenant_id == RESTAURANT_ID:
        return or_(cls.restaurant_id == tenant_id, cls.restaurant_id.is_(None))
    return cls.restaurant_id == tenant_id


def _apply_dml_tenant(statement):
    table = getattr(statement, "table", None)
    if table is None or "restaurant_id" not in table.c:
        return statement

    tenant_id = get_current_restaurant_id()
    if tenant_id is None:
        return statement
    if RESTAURANT_ID == 1 and tenant_id == RESTAURANT_ID:
        condition = or_(table.c.restaurant_id == tenant_id, table.c.restaurant_id.is_(None))
    else:
        condition = table.c.restaurant_id == tenant_id

    return statement.where(condition)


@event.listens_for(Session, "do_orm_execute")
def _add_tenant_criteria(execute_state):
    if execute_state.execution_options.get("skip_tenant", False):
        return
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
    if getattr(target, "restaurant_id", None) is None:
        target.restaurant_id = get_current_restaurant_id()
