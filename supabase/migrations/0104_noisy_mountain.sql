-- Drop existing policies
DROP POLICY IF EXISTS "orders_crud" ON orders;
DROP POLICY IF EXISTS "orders_read_admin_dispatcher" ON orders;

-- Create comprehensive order policies
CREATE POLICY "orders_driver_crud"
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

CREATE POLICY "orders_admin_crud"
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

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_driver_role ON orders(driver_id);
CREATE INDEX IF NOT EXISTS idx_drivers_role ON drivers(role);

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';