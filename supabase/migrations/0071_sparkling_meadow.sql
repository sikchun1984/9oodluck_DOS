/*
  # Add driver relationship to orders

  1. Changes
    - Add foreign key relationship between orders and drivers
    - Add index for better join performance
    - Update RLS policies to include driver relationship

  2. Security
    - Maintain existing RLS policies
    - Add proper constraints for data integrity
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

-- Update RLS policies to handle driver relationship
DROP POLICY IF EXISTS "orders_admin" ON orders;
DROP POLICY IF EXISTS "orders_driver" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_read" ON orders;

CREATE POLICY "orders_admin"
ON orders
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'admin'
  )
);

CREATE POLICY "orders_driver"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'driver'
  )
);

CREATE POLICY "orders_dispatcher_read"
ON orders
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'dispatcher'
  )
);

-- Force schema cache refresh
SELECT pg_notify('pgrst', 'reload schema');