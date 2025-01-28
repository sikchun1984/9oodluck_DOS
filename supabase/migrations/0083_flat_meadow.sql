/*
  # Fix permissions and roles

  1. Changes
    - Add function to check user roles
    - Update RLS policies to use new role check
    - Ensure admin user has correct roles and metadata
*/

-- Create function to check user roles
CREATE OR REPLACE FUNCTION auth.user_has_role(role text)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = role
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_insert_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_select_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_update_policy" ON drivers;
DROP POLICY IF EXISTS "orders_admin_policy" ON orders;
DROP POLICY IF EXISTS "orders_driver_policy" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_policy" ON orders;

-- Create new driver policies
CREATE POLICY "drivers_insert_policy"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

CREATE POLICY "drivers_select_policy"
ON drivers
FOR SELECT
TO authenticated
USING (
  auth.uid() = id OR
  auth.user_has_role('admin') OR
  auth.user_has_role('dispatcher')
);

CREATE POLICY "drivers_update_policy"
ON drivers
FOR UPDATE
TO authenticated
USING (
  auth.uid() = id OR
  auth.user_has_role('admin')
);

-- Create new order policies
CREATE POLICY "orders_admin_policy"
ON orders
FOR ALL 
TO authenticated
USING (auth.user_has_role('admin'));

CREATE POLICY "orders_driver_policy"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid() AND
  auth.user_has_role('driver')
);

CREATE POLICY "orders_dispatcher_policy"
ON orders
FOR SELECT
TO authenticated
USING (auth.user_has_role('dispatcher'));

-- Reset and ensure admin user has correct roles
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

  -- Delete existing roles for this user
  DELETE FROM user_roles WHERE user_id = v_user_id;

  -- Insert all roles
  INSERT INTO user_roles (user_id, role)
  VALUES
    (v_user_id, 'admin'),
    (v_user_id, 'driver'),
    (v_user_id, 'dispatcher');

  -- Update user metadata
  UPDATE auth.users
  SET raw_user_meta_data = jsonb_build_object(
    'roles', ARRAY['admin', 'driver', 'dispatcher']
  )
  WHERE id = v_user_id;

  -- Ensure driver profile exists
  INSERT INTO drivers (id, email, full_name, license_number)
  VALUES (
    v_user_id,
    '9oodluckgroup@gmail.com',
    'Admin User',
    'ADMIN-' || SUBSTRING(v_user_id::text, 1, 8)
  )
  ON CONFLICT (id) DO UPDATE
  SET email = EXCLUDED.email,
      full_name = EXCLUDED.full_name;
END $$;