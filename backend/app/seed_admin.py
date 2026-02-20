import os

from dotenv import load_dotenv

from .database import SessionLocal
from .models import Admin
from .services.auth import hash_password, normalize_password


def main() -> None:
    load_dotenv()

    username = os.getenv("ADMIN_USERNAME")
    password = os.getenv("ADMIN_PASSWORD")

    if not username or not password:
        raise RuntimeError(
            "ADMIN_USERNAME e ADMIN_PASSWORD devem estar definidos no .env"
        )

    password = normalize_password(password)
    if not password:
        raise RuntimeError("ADMIN_PASSWORD invalida apos normalizacao")

    db = SessionLocal()
    try:
        existing = db.query(Admin).filter(Admin.username == username).first()
        if existing:
            return

        admin = Admin(username=username, password_hash=hash_password(password))
        db.add(admin)
        db.commit()
    finally:
        db.close()


if __name__ == "__main__":
    main()
