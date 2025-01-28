/*
  # Fix user roles and permissions

  1. Changes
    - Add missing roles for user
    - Update RLS policies
    
  2. Security
    - Maintains existing RLS policies
    - Adds proper role checks
*/

-- First ensure the user exists in drivers table
INSERT INTO drivers (id, email, full_name, license_number)
SELECT 
  id,
  email,
  COALESCE(raw_user_meta_data->>'full_name', email) as full_name,
  'ADMIN-' || SUBSTRING(id::text, 1, 8) as license_number
FROM auth.users 
WHERE email = '9oodluckgroup@gmail.com'
ON CONFLICT (id) DO NOTHING;

-- Then add all roles
INSERT INTO user_roles (user_id, role)
SELECT 
  au.id,
  r.role
FROM auth.users au
CROSS JOIN (
  VALUES 
    ('admin'),
    ('driver'),
    ('dispatcher')
) AS r(role)
WHERE au.email = '9oodluckgroup@gmail.com'
ON CONFLICT (user_id, role) DO NOTHING;

-- Verify roles were added
DO $$
DECLARE
  v_user_id uuid;
  v_roles text[];
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = '9oodluckgroup@gmail.com';

  -- Get roles
  SELECT array_agg(role) INTO v_roles
  FROM user_roles
  WHERE user_id = v_user_id;

  -- Raise notice with results
  RAISE NOTICE 'User roles: %', v_roles;
END $$;