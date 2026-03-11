-- Multi-tenant restaurant isolation migration

CREATE TABLE IF NOT EXISTS restaurants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    mercadopago_access_token VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE IF EXISTS orders ADD COLUMN IF NOT EXISTS restaurant_id INTEGER;
ALTER TABLE IF EXISTS order_items ADD COLUMN IF NOT EXISTS restaurant_id INTEGER;
ALTER TABLE IF EXISTS products ADD COLUMN IF NOT EXISTS restaurant_id INTEGER;
ALTER TABLE IF EXISTS categories ADD COLUMN IF NOT EXISTS restaurant_id INTEGER;
ALTER TABLE IF EXISTS customers ADD COLUMN IF NOT EXISTS restaurant_id INTEGER;
ALTER TABLE IF EXISTS payments ADD COLUMN IF NOT EXISTS restaurant_id INTEGER;
ALTER TABLE IF EXISTS messages ADD COLUMN IF NOT EXISTS restaurant_id INTEGER;
ALTER TABLE IF EXISTS cart ADD COLUMN IF NOT EXISTS restaurant_id INTEGER;
ALTER TABLE IF EXISTS sessions ADD COLUMN IF NOT EXISTS restaurant_id INTEGER;
ALTER TABLE IF EXISTS notifications ADD COLUMN IF NOT EXISTS restaurant_id INTEGER;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'orders' AND column_name = 'restaurant_id'
  ) AND NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'orders_restaurant_id_fkey'
  ) THEN
    ALTER TABLE orders
    ADD CONSTRAINT orders_restaurant_id_fkey
    FOREIGN KEY (restaurant_id)
    REFERENCES restaurants(id)
    ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'order_items' AND column_name = 'restaurant_id'
  ) AND NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'order_items_restaurant_id_fkey'
  ) THEN
    ALTER TABLE order_items
    ADD CONSTRAINT order_items_restaurant_id_fkey
    FOREIGN KEY (restaurant_id)
    REFERENCES restaurants(id)
    ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'products' AND column_name = 'restaurant_id'
  ) AND NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'products_restaurant_id_fkey'
  ) THEN
    ALTER TABLE products
    ADD CONSTRAINT products_restaurant_id_fkey
    FOREIGN KEY (restaurant_id)
    REFERENCES restaurants(id)
    ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'categories' AND column_name = 'restaurant_id'
  ) AND NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'categories_restaurant_id_fkey'
  ) THEN
    ALTER TABLE categories
    ADD CONSTRAINT categories_restaurant_id_fkey
    FOREIGN KEY (restaurant_id)
    REFERENCES restaurants(id)
    ON DELETE SET NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'orders' AND column_name = 'restaurant_id'
  ) THEN
    UPDATE orders SET restaurant_id = 1 WHERE restaurant_id IS NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'order_items' AND column_name = 'restaurant_id'
  ) THEN
    UPDATE order_items SET restaurant_id = 1 WHERE restaurant_id IS NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'products' AND column_name = 'restaurant_id'
  ) THEN
    UPDATE products SET restaurant_id = 1 WHERE restaurant_id IS NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'categories' AND column_name = 'restaurant_id'
  ) THEN
    UPDATE categories SET restaurant_id = 1 WHERE restaurant_id IS NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'orders' AND column_name = 'restaurant_id'
  ) THEN
    ALTER TABLE orders ALTER COLUMN restaurant_id SET NOT NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'order_items' AND column_name = 'restaurant_id'
  ) THEN
    ALTER TABLE order_items ALTER COLUMN restaurant_id SET NOT NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'products' AND column_name = 'restaurant_id'
  ) THEN
    ALTER TABLE products ALTER COLUMN restaurant_id SET NOT NULL;
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'categories' AND column_name = 'restaurant_id'
  ) THEN
    ALTER TABLE categories ALTER COLUMN restaurant_id SET NOT NULL;
  END IF;
END $$;
