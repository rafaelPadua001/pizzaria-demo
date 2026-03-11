from sqlalchemy import Column, ForeignKey, Integer


class RestaurantMixin:
    restaurant_id = Column(
        Integer,
        ForeignKey("restaurants.id"),
        index=True,
        nullable=False,
    )
