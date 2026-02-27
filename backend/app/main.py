import os
from pathlib import Path

from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from sqlalchemy import text
from sqlalchemy.orm import Session

from .database import Base, engine, get_db
from .models import Admin, Category, Product, Order, OrderItem, PageSection, Page, Restaurant  # noqa
from .routes import admin, auth, categories, products, orders, admin_content, content, catalog, checkout, webhook, payments
from .utils.time import get_current_time


app = FastAPI()

# ===============================
# PATHS
# ===============================

BASE_DIR = Path(__file__).resolve().parent
PROJECT_DIR = BASE_DIR.parent.parent
FRONTEND_DIR = PROJECT_DIR / "frontend"
PUBLIC_DIR = FRONTEND_DIR / "public"

STATIC_DIR = BASE_DIR / "static"
UPLOADS_DIR = BASE_DIR.parent / "uploads"
UPLOAD_PRODUCTS_DIR = UPLOADS_DIR / "products"
UPLOAD_PRODUCTS_DIR.mkdir(parents=True, exist_ok=True)

# ===============================
# STATIC FILES
# ===============================

app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")
app.mount("/uploads", StaticFiles(directory=UPLOADS_DIR), name="uploads")

# ===============================
# CORS
# ===============================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===============================
# ROUTERS
# ===============================

app.include_router(auth.router)
app.include_router(admin.router)
app.include_router(categories.router)
app.include_router(products.router)
app.include_router(orders.router)
app.include_router(admin_content.router)
app.include_router(content.router)
app.include_router(catalog.router)
app.include_router(checkout.router)
app.include_router(webhook.router)
app.include_router(payments.router)

@app.get("/admin")
def serve_admin():
    return FileResponse(PUBLIC_DIR / "admin" / "admin.html")

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/restaurants")
def list_restaurants(db: Session = Depends(get_db)):
    return db.query(Restaurant).all()

@app.get("/debug/time")
def debug_time():
    return {
        "fake_time_env": os.getenv("FAKE_TIME"),
        "current_time_used": str(get_current_time()),
    }

# ===============================
# STARTUP MIGRATION
# ===============================

@app.on_event("startup")
def startup_check():

    Base.metadata.create_all(bind=engine)

    with engine.begin() as connection:

        # Renomeia section_id -> category_id se necessário
        connection.execute(text("""
        DO $$
        BEGIN
          IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'products' AND column_name = 'section_id'
          )
          AND NOT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'products' AND column_name = 'category_id'
          ) THEN
            EXECUTE 'ALTER TABLE products RENAME COLUMN section_id TO category_id';
          END IF;
        END $$;
        """))

        # Order history: novas colunas e ajustes
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_name VARCHAR(120)"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_phone VARCHAR(20)"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS total_amount DOUBLE PRECISION"))
        connection.execute(
            text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_fee DOUBLE PRECISION DEFAULT 0.0")
        )
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS restaurant_id INTEGER"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status VARCHAR(30) DEFAULT 'pending'"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS mercadopago_preference_id VARCHAR(255)"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS mercadopago_payment_id VARCHAR(255)"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending'"))

        connection.execute(text("""
        DO $$
        BEGIN
          IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'orders' AND column_name = 'total'
          ) THEN
            UPDATE orders
            SET total_amount = total
            WHERE total_amount IS NULL;
          END IF;
        END $$;
        """))

        connection.execute(text("""
        DO $$
        BEGIN
          IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'order_items' AND column_name = 'order_id'
          ) THEN
            UPDATE orders AS o
            SET total_amount = totals.total
            FROM (
              SELECT order_id, SUM(quantity * unit_price) AS total
              FROM order_items
              GROUP BY order_id
            ) AS totals
            WHERE o.id = totals.order_id
              AND (o.total_amount IS NULL OR o.total_amount = 0);
          END IF;
        END $$;
        """))

        connection.execute(text("""
        DO $$
        BEGIN
          IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'orders' AND column_name = 'total'
          ) THEN
            ALTER TABLE orders ALTER COLUMN total DROP NOT NULL;
          END IF;
        END $$;
        """))

        connection.execute(text("ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_id INTEGER"))
        connection.execute(text("ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_name VARCHAR(150)"))

        connection.execute(text("""
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'orders_restaurant_id_fkey'
          ) THEN
            ALTER TABLE orders
            ADD CONSTRAINT orders_restaurant_id_fkey
            FOREIGN KEY (restaurant_id)
            REFERENCES restaurants(id)
            ON DELETE SET NULL;
          END IF;
        END $$;
        """))

        connection.execute(text("""
        DO $$
        BEGIN
          IF EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'order_items_product_id_fkey'
          ) THEN
            ALTER TABLE order_items DROP CONSTRAINT order_items_product_id_fkey;
          END IF;
        END $$;
        """))

        connection.execute(text("""
        DO $$
        BEGIN
          IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'order_items' AND column_name = 'product_id'
          ) THEN
            ALTER TABLE order_items ALTER COLUMN product_id DROP NOT NULL;
          END IF;
        END $$;
        """))

        connection.execute(text("ALTER TABLE products ADD COLUMN IF NOT EXISTS category_id INTEGER"))
        connection.execute(text("ALTER TABLE products ADD COLUMN IF NOT EXISTS image_url VARCHAR(255)"))
        connection.execute(text("ALTER TABLE products ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE"))

        # Remove FK antiga apontando para sections
        connection.execute(text("""
        DO $$
        BEGIN
          IF EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'products_section_id_fkey'
          ) THEN
            ALTER TABLE products DROP CONSTRAINT products_section_id_fkey;
          END IF;
        END $$;
        """))

        # Cria FK correta se não existir
        connection.execute(text("""
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'products_category_id_fkey'
          ) THEN
            ALTER TABLE products
            ADD CONSTRAINT products_category_id_fkey
            FOREIGN KEY (category_id)
            REFERENCES categories(id)
            ON DELETE CASCADE;
          END IF;
        END $$;
        """))

    # Teste conexão
    with engine.connect() as connection:
        connection.execute(text("SELECT 1"))

# ===============================
# FRONTEND ROOT (deve ficar no final)
# ===============================

app.mount("/", StaticFiles(directory=PUBLIC_DIR, html=True), name="frontend")
