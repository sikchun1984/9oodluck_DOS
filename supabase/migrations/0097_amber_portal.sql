-- Add role column back to drivers table
ALTER TABLE drivers 
ADD COLUMN role text NOT NULL DEFAULT 'driver'
CHECK (role IN ('admin', 'driver', 'dispatcher'));

-- Create index for role column
CREATE INDEX IF NOT EXISTS idx_drivers_role ON drivers(role);

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_select" ON drivers;
DROP POLICY IF EXISTS "drivers_update" ON drivers;
DROP POLICY IF EXISTS "drivers_insert" ON drivers;
DROP POLICY IF EXISTS "orders_select" ON orders;
DROP POLICY IF EXISTS "orders_insert" ON orders;
DROP POLICY IF EXISTS "orders_update" ON orders;
DROP POLICY IF EXISTS "orders_delete" ON orders;

-- Create role-based policies for drivers
CREATE POLICY "drivers_select_policy"
ON drivers
FOR SELECT
TO authenticated
USING (
  id = auth.uid()
  OR EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role IN ('admin', 'dispatcher')
  )
);

CREATE POLICY "drivers_update_policy"
ON drivers
FOR UPDATE
TO authenticated
USING (
  id = auth.uid()
  OR EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'admin'
  )
);

CREATE POLICY "drivers_insert_policy"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Create role-based policies for orders
CREATE POLICY "orders_admin_policy"
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

CREATE POLICY "orders_driver_policy"
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

CREATE POLICY "orders_dispatcher_policy"
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

-- Set admin role for system admin
UPDATE drivers 
SET role = 'admin'
WHERE email = '9oodluckgroup@gmail.com';

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';