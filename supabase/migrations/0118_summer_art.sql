-- Create role check function with better error handling
CREATE OR REPLACE FUNCTION get_user_role(user_id uuid)
RETURNS text
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT COALESCE(
    (SELECT role FROM drivers WHERE id = user_id LIMIT 1),
    'driver'
  );
$$;

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_select" ON drivers;
DROP POLICY IF EXISTS "drivers_update" ON drivers;
DROP POLICY IF EXISTS "drivers_insert" ON drivers;
DROP POLICY IF EXISTS "orders_admin" ON orders;
DROP POLICY IF EXISTS "orders_driver" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher" ON orders;

-- Create driver policies
CREATE POLICY "drivers_select"
ON drivers
FOR SELECT
TO authenticated
USING (id = auth.uid() OR get_user_role(auth.uid()) IN ('admin', 'dispatcher'));

CREATE POLICY "drivers_update"
ON drivers
FOR UPDATE
TO authenticated
USING (id = auth.uid() OR get_user_role(auth.uid()) = 'admin');

CREATE POLICY "drivers_insert"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Create order policies
CREATE POLICY "orders_admin"
ON orders
FOR ALL 
TO authenticated
USING (get_user_role(auth.uid()) = 'admin');

CREATE POLICY "orders_driver"
ON orders
FOR ALL
TO authenticated
USING (driver_id = auth.uid() AND get_user_role(auth.uid()) = 'driver');

CREATE POLICY "orders_dispatcher"
ON orders
FOR SELECT
TO authenticated
USING (get_user_role(auth.uid()) = 'dispatcher');

-- Add index
CREATE INDEX IF NOT EXISTS idx_drivers_role ON drivers(role);