-- Create role check function that doesn't cause recursion
CREATE OR REPLACE FUNCTION auth.get_role()
RETURNS text
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT COALESCE(
    (SELECT role FROM drivers WHERE id = auth.uid()),
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

-- Create simplified driver policies
CREATE POLICY "drivers_select"
ON drivers
FOR SELECT
TO authenticated
USING (
  id = auth.uid() OR
  auth.get_role() IN ('admin', 'dispatcher')
);

CREATE POLICY "drivers_update"
ON drivers
FOR UPDATE
TO authenticated
USING (
  id = auth.uid() OR
  auth.get_role() = 'admin'
);

CREATE POLICY "drivers_insert"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Create simplified order policies
CREATE POLICY "orders_admin"
ON orders
FOR ALL 
TO authenticated
USING (auth.get_role() = 'admin');

CREATE POLICY "orders_driver"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid() AND
  auth.get_role() = 'driver'
);

CREATE POLICY "orders_dispatcher"
ON orders
FOR SELECT
TO authenticated
USING (auth.get_role() = 'dispatcher');

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_drivers_role ON drivers(role);
CREATE INDEX IF NOT EXISTS idx_orders_driver_id ON orders(driver_id);

-- Ensure admin user exists with correct role
DO $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = '9oodluckgroup@gmail.com';

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Admin user not found';
  END IF;

  -- Ensure driver profile exists with admin role
  INSERT INTO drivers (id, email, full_name, role, license_number)
  VALUES (
    v_user_id,
    '9oodluckgroup@gmail.com',
    'System Admin',
    'admin',
    'ADMIN-' || encode(sha256(v_user_id::text::bytea), 'hex')
  )
  ON CONFLICT (id) DO UPDATE
  SET 
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    role = 'admin';
END $$;