/*
  # Add driver selection functionality

  1. Changes
    - Add driver relationship to orders table
    - Update RLS policies for driver access
    - Add indexes for performance

  2. Security
    - Maintain RLS policies for proper access control
    - Ensure proper cascading behavior
*/

-- Add driver relationship to orders table
ALTER TABLE orders
DROP CONSTRAINT IF EXISTS orders_driver_id_fkey,
ADD CONSTRAINT orders_driver_id_fkey 
  FOREIGN KEY (driver_id) 
  REFERENCES drivers(id) 
  ON DELETE CASCADE;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_driver_id ON orders(driver_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- Update RLS policies
DROP POLICY IF EXISTS "orders_admin_access" ON orders;
DROP POLICY IF EXISTS "orders_driver_access" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_access" ON orders;

-- Admin can do everything
CREATE POLICY "orders_admin_access"
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

-- Drivers can manage their own orders
CREATE POLICY "orders_driver_access"
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

-- Dispatchers can only read orders
CREATE POLICY "orders_dispatcher_access"
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
NOTIFY pgrst, 'reload schema';