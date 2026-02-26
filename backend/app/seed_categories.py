from dotenv import load_dotenv

from .database import SessionLocal
from .models import Category


def main() -> None:
    load_dotenv()

    seed_data = [
        {
            "name": "pizzas",
            "title": "Pizzas",
            "description": "Clássicas e especiais com massa artesanal.",
            "icon": "🍕",
            "slug": "pizzas",
            "order": 1,
            "is_active": True,
        },
        {
            "name": "lanches",
            "title": "Lanches",
            "description": "Combos completos para matar a fome.",
            "icon": "🍔",
            "slug": "lanches",
            "order": 2,
            "is_active": True,
        },
        {
            "name": "bebidas",
            "title": "Bebidas",
            "description": "Refrigerantes, sucos e águas geladas.",
            "icon": "🥤",
            "slug": "bebidas",
            "order": 3,
            "is_active": True,
        },
    ]

    db = SessionLocal()
    try:
        for payload in seed_data:
            existing = db.query(Category).filter(Category.slug == payload["slug"]).first()
            if existing:
                existing.name = payload["name"]
                existing.title = payload["title"]
                existing.description = payload["description"]
                existing.icon = payload["icon"]
                existing.order = payload["order"]
                existing.is_active = payload["is_active"]
                continue
            db.add(Category(**payload))
        db.commit()
    finally:
        db.close()


if __name__ == "__main__":
    main()
