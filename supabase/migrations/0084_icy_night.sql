/*
  # Enhance permissions and role management

  1. Changes
    - Add role validation function
    - Add function to get current user role
    - Update policies with stricter checks
    - Ensure admin user setup
*/

-- Create role validation function
CREATE OR REPLACE FUNCTION auth.validate_role(role text)
RETURNS boolean AS $$
BEGIN
  RETURN role IN ('admin', 'driver', 'dispatcher');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create function to get current user role
CREATE OR REPLACE FUNCTION auth.current_role()
RETURNS text AS $$
DECLARE
  v_role text;
BEGIN
  SELECT role INTO v_role
  FROM user_roles
  WHERE user_id = auth.uid()
  ORDER BY 
    CASE role
      WHEN 'admin' THEN 1
      WHEN 'dispatcher' THEN 2
      WHEN 'driver' THEN 3
    END
  LIMIT 1;
  
  RETURN v_role;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_insert_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_select_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_update_policy" ON drivers;
DROP POLICY IF EXISTS "orders_admin_policy" ON orders;
DROP POLICY IF EXISTS "orders_driver_policy" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_policy" ON orders;

-- Create enhanced driver policies
CREATE POLICY "drivers_insert_policy"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = id AND
  EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid())
);

CREATE POLICY "drivers_select_policy"
ON drivers
FOR SELECT
TO authenticated
USING (
  auth.uid() = id OR
  auth.current_role() IN ('admin', 'dispatcher')
);

CREATE POLICY "drivers_update_policy"
ON drivers
FOR UPDATE
TO authenticated
USING (
  auth.uid() = id OR
  auth.current_role() = 'admin'
);

-- Create enhanced order policies
CREATE POLICY "orders_admin_policy"
ON orders
FOR ALL 
TO authenticated
USING (auth.current_role() = 'admin');

CREATE POLICY "orders_driver_policy"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid() AND
  auth.current_role() = 'driver'
);

CREATE POLICY "orders_dispatcher_policy"
ON orders
FOR SELECT
TO authenticated
USING (auth.current_role() = 'dispatcher');

-- Ensure admin user setup
DO $$
DECLARE
  v_user_id uuid;
  v_email text := '9oodluckgroup@gmail.com';
BEGIN
  -- Get or create user ID
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = v_email;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Admin user not found: %', v_email;
  END IF;

  -- Ensure driver profile exists
  INSERT INTO drivers (id, email, full_name, license_number)
  VALUES (
    v_user_id,
    v_email,
    'Admin User',
    'ADMIN-' || encode(sha256(v_user_id::text::bytea), 'hex')
  )
  ON CONFLICT (id) DO UPDATE
  SET 
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name;

  -- Reset and set roles
  DELETE FROM user_roles WHERE user_id = v_user_id;
  
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
END $$;