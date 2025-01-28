/*
  # Fix user roles and permissions

  1. Changes
    - Update user metadata
    - Fix role assignments
    - Add missing roles
*/

-- First ensure the user exists in drivers table
DO $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = '9oodluckgroup@gmail.com';

  -- Create driver profile if not exists
  INSERT INTO drivers (id, email, full_name, license_number)
  VALUES (
    v_user_id,
    '9oodluckgroup@gmail.com',
    'Admin User',
    'ADMIN-' || SUBSTRING(v_user_id::text, 1, 8)
  )
  ON CONFLICT (id) DO UPDATE
  SET email = EXCLUDED.email;

  -- Remove existing roles
  DELETE FROM user_roles WHERE user_id = v_user_id;

  -- Add all roles
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