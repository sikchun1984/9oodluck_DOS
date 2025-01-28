-- Drop existing policies
DROP POLICY IF EXISTS "drivers_select" ON drivers;
DROP POLICY IF EXISTS "drivers_update" ON drivers;
DROP POLICY IF EXISTS "drivers_insert" ON drivers;
DROP POLICY IF EXISTS "orders_crud" ON orders;

-- Create simplified driver policies
CREATE POLICY "drivers_select"
ON drivers
FOR SELECT
TO authenticated
USING (
  -- Users can only see their own profile
  id = auth.uid()
);

CREATE POLICY "drivers_update"
ON drivers
FOR UPDATE
TO authenticated
USING (
  -- Users can only update their own profile
  id = auth.uid()
);

CREATE POLICY "drivers_insert"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Create simplified order policy
CREATE POLICY "orders_crud"
ON orders
FOR ALL
TO authenticated
USING (
  -- Users can only access their own orders
  driver_id = auth.uid()
);

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_orders_driver_id ON orders(driver_id);

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';