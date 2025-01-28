/*
  # Fix order deletion functionality

  1. Changes
    - Add cascade delete for order relationships
    - Update order deletion policies
    - Add missing indexes for performance

  2. Security
    - Maintain RLS policies for proper access control
    - Ensure proper cascading behavior
*/

-- Add cascade delete for any potential foreign key relationships
ALTER TABLE orders
DROP CONSTRAINT IF EXISTS orders_driver_id_fkey,
ADD CONSTRAINT orders_driver_id_fkey 
  FOREIGN KEY (driver_id) 
  REFERENCES drivers(id) 
  ON DELETE CASCADE;

ALTER TABLE orders
DROP CONSTRAINT IF EXISTS orders_vehicle_id_fkey,
ADD CONSTRAINT orders_vehicle_id_fkey 
  FOREIGN KEY (vehicle_id) 
  REFERENCES vehicles(id) 
  ON DELETE CASCADE;

-- Update RLS policies for better deletion handling
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

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_driver_id ON orders(driver_id);
CREATE INDEX IF NOT EXISTS idx_orders_vehicle_id ON orders(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';