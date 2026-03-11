-- Notification table for realtime order alerts

CREATE TABLE IF NOT EXISTS notifications (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER NOT NULL,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(150) NOT NULL,
  message TEXT NOT NULL,
  order_id INTEGER,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'notifications_restaurant_id_fkey'
  ) THEN
    ALTER TABLE notifications
    ADD CONSTRAINT notifications_restaurant_id_fkey
    FOREIGN KEY (restaurant_id)
    REFERENCES restaurants(id)
    ON DELETE CASCADE;
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'notifications_order_id_fkey'
  ) THEN
    ALTER TABLE notifications
    ADD CONSTRAINT notifications_order_id_fkey
    FOREIGN KEY (order_id)
    REFERENCES orders(id)
    ON DELETE SET NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS notifications_restaurant_id_idx
  ON notifications (restaurant_id);
CREATE INDEX IF NOT EXISTS notifications_created_at_idx
  ON notifications (created_at);
CREATE INDEX IF NOT EXISTS notifications_is_read_idx
  ON notifications (is_read);
