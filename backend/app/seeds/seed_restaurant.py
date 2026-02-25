from __future__ import annotations

import os

from sqlalchemy.orm import Session

from ..database import SessionLocal
from ..models import Restaurant


def seed_restaurant(db: Session) -> None:
    existing = db.query(Restaurant).filter(Restaurant.slug == "pizzaria-demo").first()
    if existing:
        return

    access_token = os.getenv("MERCADOPAGO_ACCESS_TOKEN", "")
    if not access_token:
        raise RuntimeError("MERCADOPAGO_ACCESS_TOKEN nao definido no ambiente.")

    restaurant = Restaurant(
        name="Pizzaria Demo",
        slug="pizzaria-demo",
        mercadopago_access_token=access_token,
    )
    db.add(restaurant)
    db.commit()


def main() -> None:
    db = SessionLocal()
    try:
        seed_restaurant(db)
        print("Seed de restaurante concluida.")
    finally:
        db.close()


if __name__ == "__main__":
    main()
