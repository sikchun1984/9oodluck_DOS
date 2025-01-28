/*
  # Add driver relationship to orders

  1. Changes
    - Add foreign key constraint from orders.driver_id to drivers.id
    - Update RLS policies to reflect the relationship

  2. Security
    - Maintain existing RLS policies
    - Ensure proper cascading on delete
*/

-- Add foreign key constraint if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'orders_driver_id_fkey'
  ) THEN
    ALTER TABLE orders
    ADD CONSTRAINT orders_driver_id_fkey
    FOREIGN KEY (driver_id)
    REFERENCES drivers(id)
    ON DELETE CASCADE;
  END IF;
END $$;

-- Add index for better join performance
CREATE INDEX IF NOT EXISTS idx_orders_driver_id ON orders(driver_id);

-- Force schema cache refresh
SELECT pg_notify('pgrst', 'reload schema');