/*
  # Fix permissions and policies

  1. Changes
    - Update RLS policies
    - Fix role checking logic
    - Ensure proper access control
*/

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_insert" ON drivers;
DROP POLICY IF EXISTS "drivers_select" ON drivers;
DROP POLICY IF EXISTS "drivers_update" ON drivers;
DROP POLICY IF EXISTS "orders_admin" ON orders;
DROP POLICY IF EXISTS "orders_driver" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_read" ON orders;

-- Create simplified driver policies
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
  -- Users can always read their own profile
  auth.uid() = id
  OR
  -- Users with admin or dispatcher role can read all profiles
  EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role IN ('admin', 'dispatcher')
  )
);

CREATE POLICY "drivers_update_policy"
ON drivers
FOR UPDATE
TO authenticated
USING (
  -- Users can update their own profile
  auth.uid() = id
  OR
  -- Admins can update any profile
  EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'admin'
  )
);

-- Create order policies
CREATE POLICY "orders_admin_policy"
ON orders
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'admin'
  )
);

CREATE POLICY "orders_driver_policy"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'driver'
  )
);

CREATE POLICY "orders_dispatcher_policy"
ON orders
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'dispatcher'
  )
);

-- Ensure admin user has all roles
DO $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = '9oodluckgroup@gmail.com';

  -- Ensure user has all roles
  INSERT INTO user_roles (user_id, role)
  VALUES
    (v_user_id, 'admin'),
    (v_user_id, 'driver'),
    (v_user_id, 'dispatcher')
  ON CONFLICT (user_id, role) DO NOTHING;

  -- Update user metadata
  UPDATE auth.users
  SET raw_user_meta_data = jsonb_build_object(
    'roles', ARRAY['admin', 'driver', 'dispatcher']
  )
  WHERE id = v_user_id;
END $$;