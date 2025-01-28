/*
  # Fix user roles and permissions

  1. Changes
    - Update user roles
    - Add missing roles
    - Fix RLS policies
*/

-- First ensure the user exists in drivers table with correct email
UPDATE drivers 
SET email = '9oodluckgroup@gmail.com'
WHERE id IN (
  SELECT id 
  FROM auth.users 
  WHERE email = '9oodluckgroup@gmail.com'
);

-- Remove any existing roles for the user to avoid duplicates
DELETE FROM user_roles
WHERE user_id IN (
  SELECT id 
  FROM auth.users 
  WHERE email = '9oodluckgroup@gmail.com'
);

-- Add all roles for the user
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
WHERE au.email = '9oodluckgroup@gmail.com';

-- Update user metadata in auth.users
UPDATE auth.users
SET raw_user_meta_data = jsonb_build_object(
  'roles', (
    SELECT array_agg(role)
    FROM user_roles
    WHERE user_id = auth.users.id
  )
)
WHERE email = '9oodluckgroup@gmail.com';

-- Verify roles were added correctly
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