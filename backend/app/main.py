import os
from pathlib import Path

from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from sqlalchemy import text
from sqlalchemy.orm import Session

from .middleware.tenant_resolver import TenantResolverMiddleware

from .database import Base, engine, get_db
from .models import Admin, Category, Product, Order, OrderItem, PageSection, Page, Restaurant  # noqa
from .routes import admin, admins, auth, categories, products, orders, admin_content, content, catalog, checkout, webhook, payments, internal, tenant_config, tenant_pages, saas, admin_notifications, ws_admin_notifications
from .routes.api.v1 import categories as api_v1_categories, products as api_v1_products, menu as api_v1_menu
from .utils.time import get_current_time


app = FastAPI()

app.add_middleware(TenantResolverMiddleware)

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
     allow_origins=[
        "http://localhost:8001",
        "http://localhost:8000",
        "http://127.0.0.1:8001",
        "http://127.0.0.1:8000",
        "null",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===============================
# ROUTERS
# ===============================

app.include_router(auth.router)
app.include_router(admin.router)
app.include_router(admins.router)
app.include_router(categories.router)
app.include_router(products.router)
app.include_router(api_v1_categories.router)
app.include_router(api_v1_products.router)
app.include_router(api_v1_menu.router, prefix="/api/v1")
app.include_router(orders.router)
app.include_router(admin_content.router)
app.include_router(content.router)
app.include_router(catalog.router)
app.include_router(checkout.router)
app.include_router(webhook.router)
app.include_router(payments.router)
app.include_router(internal.router)
app.include_router(tenant_pages.router)
app.include_router(tenant_config.router)
app.include_router(saas.router)
app.include_router(admin_notifications.router)
app.include_router(admin_notifications.router, prefix="/{restaurant_slug}")
app.include_router(ws_admin_notifications.router)

for tenant_router in (
    categories.router,
    products.router,
    orders.router,
    admin_content.router,
    content.router,
    catalog.router,
    checkout.router,
    webhook.router,
    payments.router,
    tenant_pages.router,
    tenant_config.router,
):
    app.include_router(tenant_router, prefix="/{restaurant_slug}")

# DEBUG: lista rotas registradas no startup do app
for route in app.routes:
    print(route.path)

@app.get("/admin")
def serve_admin():
    return FileResponse(PUBLIC_DIR / "admin" / "admin.html")

@app.get("/{restaurant_slug}/admin")
def serve_admin_tenant(restaurant_slug: str):
    return FileResponse(PUBLIC_DIR / "admin" / "admin.html")

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/restaurants")
def list_restaurants(db: Session = Depends(get_db)):
    return db.query(Restaurant).all()

@app.get("/public/categories")
def public_categories(db: Session = Depends(get_db)):
    return db.query(Category).all()

@app.get("/public/products")
def public_products(db: Session = Depends(get_db)):
    return db.query(Product).all()

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

        # Renomeia section_id -> category_id se necessÃ¡rio
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
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS session_id VARCHAR(120)"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS total_amount DOUBLE PRECISION"))
        connection.execute(
            text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_fee DOUBLE PRECISION DEFAULT 0.0")
        )
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS restaurant_id INTEGER"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status VARCHAR(30) DEFAULT 'pending'"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_status VARCHAR(30) DEFAULT 'pending'"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS mercadopago_preference_id VARCHAR(255)"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS mercadopago_payment_id VARCHAR(255)"))
        connection.execute(text("ALTER TABLE orders ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'pending'"))
        connection.execute(text("ALTER TABLE orders ALTER COLUMN order_status SET DEFAULT 'pending'"))

        connection.execute(text("""
        DO $$
        DECLARE
          constraint_name text;
        BEGIN
          SELECT conname INTO constraint_name
          FROM pg_constraint c
          JOIN pg_class t ON t.oid = c.conrelid
          JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(c.conkey)
          WHERE t.relname = 'orders' AND a.attname = 'status' AND c.contype = 'c'
          LIMIT 1;

          IF constraint_name IS NOT NULL THEN
            EXECUTE format('ALTER TABLE orders DROP CONSTRAINT %I', constraint_name);
          END IF;
        END $$;
        """))

        connection.execute(text("""
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint WHERE conname = 'orders_status_check'
          ) THEN
            ALTER TABLE orders
            ADD CONSTRAINT orders_status_check
            CHECK (status IN (
              'pending', 'paid', 'preparing', 'ready', 'sent', 'cancelled',
              'confirmed', 'delivered', 'canceled'
            ));
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
            UPDATE orders
            SET total_amount = total
            WHERE total_amount IS NULL;
          END IF;
        END $$;
        """))

        connection.execute(text("""
        DO $$
        DECLARE
          data_type text;
          udt_name text;
        BEGIN
          SELECT c.data_type, c.udt_name INTO data_type, udt_name
          FROM information_schema.columns c
          WHERE c.table_name = 'orders' AND c.column_name = 'order_status';

          IF data_type = 'USER-DEFINED' AND udt_name = 'order_status_enum' THEN
            EXECUTE 'ALTER TABLE orders ALTER COLUMN order_status DROP DEFAULT';
            EXECUTE 'ALTER TABLE orders ALTER COLUMN order_status TYPE VARCHAR(30) USING order_status::text';
            EXECUTE 'DROP TYPE IF EXISTS order_status_enum';
            EXECUTE 'ALTER TABLE orders ALTER COLUMN order_status SET DEFAULT ''pending''';
          END IF;
        END $$;
        """))

        connection.execute(text("""
        DO $$
        BEGIN
          IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'orders' AND column_name = 'order_status'
          ) THEN
            UPDATE orders
            SET order_status = lower(order_status)
            WHERE order_status IS NOT NULL;

            UPDATE orders
            SET order_status = 'pending'
            WHERE order_status IS NULL
              OR order_status = ''
              OR order_status NOT IN (
                'pending','preparing','delivering','completed','cancelled'
              );
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

        # Cria FK correta se nÃ£o existir
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
        # Tenant restaurant isolation columns
        connection.execute(text("ALTER TABLE categories ADD COLUMN IF NOT EXISTS restaurant_id INTEGER"))
        connection.execute(text("ALTER TABLE products ADD COLUMN IF NOT EXISTS restaurant_id INTEGER"))
        connection.execute(text("ALTER TABLE order_items ADD COLUMN IF NOT EXISTS restaurant_id INTEGER"))

        connection.execute(text("""
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'categories_restaurant_id_fkey'
          ) THEN
            ALTER TABLE categories
            ADD CONSTRAINT categories_restaurant_id_fkey
            FOREIGN KEY (restaurant_id)
            REFERENCES restaurants(id)
            ON DELETE SET NULL;
          END IF;
        END $$;
        """))

        connection.execute(text("""
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'products_restaurant_id_fkey'
          ) THEN
            ALTER TABLE products
            ADD CONSTRAINT products_restaurant_id_fkey
            FOREIGN KEY (restaurant_id)
            REFERENCES restaurants(id)
            ON DELETE SET NULL;
          END IF;
        END $$;
        """))

        connection.execute(text("""
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'order_items_restaurant_id_fkey'
          ) THEN
            ALTER TABLE order_items
            ADD CONSTRAINT order_items_restaurant_id_fkey
            FOREIGN KEY (restaurant_id)
            REFERENCES restaurants(id)
            ON DELETE SET NULL;
          END IF;
        END $$;
        """))

        # SaaS restaurant metadata
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS slug VARCHAR(100)"))
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS logo_url VARCHAR(255)"))
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS primary_color VARCHAR(40)"))
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS whatsapp_number VARCHAR(30)"))
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS email VARCHAR(150)"))
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS address VARCHAR(255)"))
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS city VARCHAR(120)"))
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS state VARCHAR(60)"))
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS mercadopago_access_token VARCHAR(255)"))
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS mercadopago_public_key VARCHAR(255)"))
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS assistant_enabled BOOLEAN DEFAULT TRUE"))
        connection.execute(text("ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP"))

        connection.execute(text("""
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint WHERE conname = 'restaurants_slug_key'
          ) THEN
            IF (
              SELECT COUNT(*) FROM restaurants WHERE slug IS NOT NULL
            ) = (
              SELECT COUNT(DISTINCT slug) FROM restaurants WHERE slug IS NOT NULL
            ) THEN
              ALTER TABLE restaurants ADD CONSTRAINT restaurants_slug_key UNIQUE (slug);
            END IF;
          END IF;
        END $$;
        """))

        # Admin role/tenant linkage
        connection.execute(text("ALTER TABLE admins ADD COLUMN IF NOT EXISTS role VARCHAR(50)"))
        connection.execute(text("ALTER TABLE admins ADD COLUMN IF NOT EXISTS restaurant_id INTEGER"))

        connection.execute(text("""
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'admins_restaurant_id_fkey'
          ) THEN
            ALTER TABLE admins
            ADD CONSTRAINT admins_restaurant_id_fkey
            FOREIGN KEY (restaurant_id)
            REFERENCES restaurants(id)
            ON DELETE SET NULL;
          END IF;
        END $$;
        """))

        # SaaS tables
        connection.execute(text("""
        CREATE TABLE IF NOT EXISTS roles (
          id SERIAL PRIMARY KEY,
          name VARCHAR(50) UNIQUE NOT NULL,
          created_at TIMESTAMP NOT NULL DEFAULT NOW()
        );
        """))

        connection.execute(text("""
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          email VARCHAR(150) UNIQUE NOT NULL,
          password_hash VARCHAR(255) NOT NULL,
          role VARCHAR(50) NOT NULL,
          restaurant_id INTEGER,
          created_at TIMESTAMP NOT NULL DEFAULT NOW()
        );
        """))

        connection.execute(text("""
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM pg_constraint
            WHERE conname = 'users_restaurant_id_fkey'
          ) THEN
            ALTER TABLE users
            ADD CONSTRAINT users_restaurant_id_fkey
            FOREIGN KEY (restaurant_id)
            REFERENCES restaurants(id)
            ON DELETE SET NULL;
          END IF;
        END $$;
        """))

        connection.execute(text("CREATE INDEX IF NOT EXISTS users_restaurant_id_idx ON users (restaurant_id)"))

        # Performance indexes
        connection.execute(text("""
        CREATE INDEX IF NOT EXISTS orders_restaurant_created_at_idx
        ON orders (restaurant_id, created_at)
        """))

        connection.execute(text("""
        CREATE INDEX IF NOT EXISTS products_restaurant_category_idx
        ON products (restaurant_id, category_id)
        """))
    # Teste conexÃ£o
    with engine.connect() as connection:
        connection.execute(text("SELECT 1"))

# ===============================
# FRONTEND ROOT (deve ficar no final)
# ===============================

app.mount("/", StaticFiles(directory=PUBLIC_DIR, html=True), name="frontend")













