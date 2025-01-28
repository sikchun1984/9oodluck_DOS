-- Drop all existing order policies first
DROP POLICY IF EXISTS "orders_driver_crud" ON orders;
DROP POLICY IF EXISTS "orders_admin_crud" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_read" ON orders;
DROP POLICY IF EXISTS "orders_driver_access" ON orders;
DROP POLICY IF EXISTS "orders_admin_access" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_access" ON orders;

-- Create role check function
CREATE OR REPLACE FUNCTION get_user_role(user_id uuid)
RETURNS text
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT role FROM drivers WHERE id = user_id;
$$;

-- Create simplified order policies with unique names
CREATE POLICY "orders_driver_management"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid()
  AND get_user_role(auth.uid()) = 'driver'
);

CREATE POLICY "orders_admin_management"
ON orders
FOR ALL
TO authenticated
USING (
  get_user_role(auth.uid()) = 'admin'
);

CREATE POLICY "orders_dispatcher_view"
ON orders
FOR SELECT
TO authenticated
USING (
  get_user_role(auth.uid()) = 'dispatcher'
);

-- Add index for role lookup
CREATE INDEX IF NOT EXISTS idx_drivers_role_lookup ON drivers(id, role);

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';