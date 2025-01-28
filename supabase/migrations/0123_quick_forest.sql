-- Drop existing order policies
DROP POLICY IF EXISTS "orders_admin" ON orders;
DROP POLICY IF EXISTS "orders_driver" ON orders;

-- Create new simplified order policies
CREATE POLICY "orders_crud"
ON orders
FOR ALL
TO authenticated
USING (
  -- Users can only see and manage their own orders
  driver_id = auth.uid()
);

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_orders_driver_id ON orders(driver_id);

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';