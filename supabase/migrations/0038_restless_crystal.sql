/*
  # Fix drivers RLS policies

  1. Changes
    - Drop existing policies
    - Create new policies without recursive checks
    - Use auth.uid() and metadata for role checks
    - Allow initial profile creation

  2. Security
    - Enable RLS
    - Add policies for admin, driver, and dispatcher roles
    - Ensure proper access control
*/

-- First drop all existing policies
DROP POLICY IF EXISTS "drivers_admin_full_access" ON drivers;
DROP POLICY IF EXISTS "drivers_create_initial_profile" ON drivers;
DROP POLICY IF EXISTS "drivers_manage_own_profile" ON drivers;
DROP POLICY IF EXISTS "drivers_dispatcher_view_all" ON drivers;

-- Create function to get role from JWT claims
CREATE OR REPLACE FUNCTION auth.get_role()
RETURNS text AS $$
BEGIN
  RETURN COALESCE(
    current_setting('request.jwt.claims', true)::json->>'role',
    'driver'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create new policies using JWT claims for role checks
CREATE POLICY "drivers_admin_full_access"
ON drivers
FOR ALL
TO authenticated
USING (auth.get_role() = 'admin');

CREATE POLICY "drivers_create_initial_profile"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = id
  AND NOT EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
  )
);

CREATE POLICY "drivers_manage_own_profile"
ON drivers
FOR ALL
TO authenticated
USING (
  auth.uid() = id
  AND auth.get_role() = 'driver'
);

CREATE POLICY "drivers_dispatcher_view_all"
ON drivers
FOR SELECT
TO authenticated
USING (auth.get_role() = 'dispatcher');