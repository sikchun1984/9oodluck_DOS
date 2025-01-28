-- Drop existing policies
DROP POLICY IF EXISTS "drivers_select_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_update_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_insert_policy" ON drivers;
DROP POLICY IF EXISTS "orders_admin_policy" ON orders;
DROP POLICY IF EXISTS "orders_driver_policy" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_policy" ON orders;

-- Create non-recursive policies for drivers
CREATE POLICY "drivers_select"
ON drivers
FOR SELECT
TO authenticated
USING (
  -- Users can always read their own profile
  id = auth.uid()
  OR
  -- Check role directly without recursion
  (
    SELECT role FROM drivers WHERE id = auth.uid()
  ) IN ('admin', 'dispatcher')
);

CREATE POLICY "drivers_update"
ON drivers
FOR UPDATE
TO authenticated
USING (
  -- Users can update their own profile
  id = auth.uid()
  OR
  -- Admins can update any profile
  (
    SELECT role FROM drivers WHERE id = auth.uid()
  ) = 'admin'
);

CREATE POLICY "drivers_insert"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Create non-recursive policies for orders
CREATE POLICY "orders_admin"
ON orders
FOR ALL 
TO authenticated
USING (
  (
    SELECT role FROM drivers WHERE id = auth.uid()
  ) = 'admin'
);

CREATE POLICY "orders_driver"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid()
  AND (
    SELECT role FROM drivers WHERE id = auth.uid()
  ) = 'driver'
);

CREATE POLICY "orders_dispatcher"
ON orders
FOR SELECT
TO authenticated
USING (
  (
    SELECT role FROM drivers WHERE id = auth.uid()
  ) = 'dispatcher'
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_drivers_role ON drivers(role);
CREATE INDEX IF NOT EXISTS idx_orders_driver_id ON orders(driver_id);

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';