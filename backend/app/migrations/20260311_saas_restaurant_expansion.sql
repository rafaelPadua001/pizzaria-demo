-- SaaS restaurant metadata and admin/user tables

ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS slug VARCHAR(100);
ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS logo_url VARCHAR(255);
ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS primary_color VARCHAR(40);
ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS whatsapp_number VARCHAR(30);
ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS email VARCHAR(150);
ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS address VARCHAR(255);
ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS city VARCHAR(120);
ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS state VARCHAR(60);
ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS mercadopago_access_token VARCHAR(255);
ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS mercadopago_public_key VARCHAR(255);
ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS assistant_enabled BOOLEAN DEFAULT TRUE;
ALTER TABLE restaurants ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP;

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

ALTER TABLE admins ADD COLUMN IF NOT EXISTS role VARCHAR(50);
ALTER TABLE admins ADD COLUMN IF NOT EXISTS restaurant_id INTEGER;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'admins_restaurant_id_fkey'
  ) THEN
    ALTER TABLE admins
    ADD CONSTRAINT admins_restaurant_id_fkey
    FOREIGN KEY (restaurant_id)
    REFERENCES restaurants(id)
    ON DELETE SET NULL;
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(150) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  restaurant_id INTEGER,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'users_restaurant_id_fkey'
  ) THEN
    ALTER TABLE users
    ADD CONSTRAINT users_restaurant_id_fkey
    FOREIGN KEY (restaurant_id)
    REFERENCES restaurants(id)
    ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS users_restaurant_id_idx ON users (restaurant_id);

CREATE INDEX IF NOT EXISTS orders_restaurant_created_at_idx
ON orders (restaurant_id, created_at);

CREATE INDEX IF NOT EXISTS products_restaurant_category_idx
ON products (restaurant_id, category_id);
