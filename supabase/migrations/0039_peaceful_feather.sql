/*
  # Fix driver profile policies

  1. Changes
    - Drop existing policies and functions
    - Create new simplified policies that handle new user registration
    - Add proper role-based access control
*/

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_admin_full_access" ON drivers;
DROP POLICY IF EXISTS "drivers_create_initial_profile" ON drivers;
DROP POLICY IF EXISTS "drivers_manage_own_profile" ON drivers;
DROP POLICY IF EXISTS "drivers_dispatcher_view_all" ON drivers;

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS auth.get_role();

-- Create new policies with proper role checks
CREATE POLICY "drivers_admin_access"
ON drivers
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'admin'
  )
);

CREATE POLICY "drivers_insert_own"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = id
);

CREATE POLICY "drivers_read_own"
ON drivers
FOR SELECT
TO authenticated
USING (
  auth.uid() = id
  OR EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND (d.role = 'admin' OR d.role = 'dispatcher')
  )
);

CREATE POLICY "drivers_update_own"
ON drivers
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);