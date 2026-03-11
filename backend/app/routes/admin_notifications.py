from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Notification
from ..schemas import (
    NotificationResponse,
    NotificationUnreadCountResponse,
)
from ..services.tenant_context import get_current_restaurant_id
from .admin import get_current_admin


router = APIRouter(tags=["Admin Notifications"])


@router.get("/admin/notifications", response_model=list[NotificationResponse])
def list_notifications(
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
) -> list[Notification]:
    restaurant_id = get_current_restaurant_id()
    return (
        db.query(Notification)
        .filter(Notification.restaurant_id == restaurant_id)
        .order_by(Notification.created_at.desc())
        .all()
    )


@router.get(
    "/admin/notifications/unread-count",
    response_model=NotificationUnreadCountResponse,
)
def unread_notifications_count(
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
) -> NotificationUnreadCountResponse:
    restaurant_id = get_current_restaurant_id()
    count = (
        db.query(Notification)
        .filter(
            Notification.restaurant_id == restaurant_id,
            Notification.is_read.is_(False),
        )
        .count()
    )
    return NotificationUnreadCountResponse(count=count)


@router.post(
    "/admin/notifications/{notification_id}/read",
    response_model=NotificationResponse,
)
def mark_notification_read(
    notification_id: int,
    db: Session = Depends(get_db),
    _=Depends(get_current_admin),
) -> Notification:
    restaurant_id = get_current_restaurant_id()
    notification = (
        db.query(Notification)
        .filter(
            Notification.id == notification_id,
            Notification.restaurant_id == restaurant_id,
        )
        .first()
    )
    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notificacao nao encontrada.",
        )

    notification.is_read = True
    db.commit()
    db.refresh(notification)
    return notification
