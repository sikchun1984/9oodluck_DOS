-- Drop existing policies
DROP POLICY IF EXISTS "orders_crud" ON orders;
DROP POLICY IF EXISTS "drivers_select" ON drivers;
DROP POLICY IF EXISTS "drivers_update" ON drivers;
DROP POLICY IF EXISTS "drivers_insert" ON drivers;

-- Create strict driver policies
CREATE POLICY "drivers_own_access"
ON drivers
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Create strict order policy
CREATE POLICY "orders_own_access"
ON orders
FOR ALL
TO authenticated
USING (driver_id = auth.uid())
WITH CHECK (driver_id = auth.uid());

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_driver_id ON orders(driver_id);
CREATE INDEX IF NOT EXISTS idx_drivers_id ON drivers(id);

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';