from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import RestaurantConfigResponse
from ..services.tenant_context import get_current_restaurant


router = APIRouter(tags=["tenant-config"])


@router.get("/config", response_model=RestaurantConfigResponse)
def get_restaurant_config(db: Session = Depends(get_db)) -> dict:
    restaurant = get_current_restaurant(db)
    if not restaurant:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Restaurante nao encontrado.",
        )

    return {
        "name": restaurant.name,
        "logo": restaurant.logo_url,
        "primary_color": restaurant.primary_color,
        "whatsapp": restaurant.whatsapp_number,
    }
