/*
  # Fix driver policies and role handling

  1. Changes
    - Drop existing problematic policies
    - Create new simplified policies without recursion
    - Add role-based access function
    - Update existing policies to use the new function

  2. Security
    - Maintain proper access control
    - Prevent infinite recursion
    - Ensure proper role checks
*/

-- Create function to check user role
CREATE OR REPLACE FUNCTION auth.user_role()
RETURNS text AS $$
BEGIN
  RETURN COALESCE(
    current_setting('request.jwt.claims', true)::json->>'role',
    'driver'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing policies
DROP POLICY IF EXISTS "Admin full access" ON drivers;
DROP POLICY IF EXISTS "Driver manage own" ON drivers;
DROP POLICY IF EXISTS "Dispatcher view all" ON drivers;

-- Create new simplified policies
CREATE POLICY "admin_full_access"
ON drivers
FOR ALL
TO authenticated
USING (auth.user_role() = 'admin');

CREATE POLICY "driver_manage_own"
ON drivers
FOR ALL
TO authenticated
USING (
  auth.uid() = id 
  AND auth.user_role() = 'driver'
);

CREATE POLICY "dispatcher_view_all"
ON drivers
FOR SELECT
TO authenticated
USING (auth.user_role() = 'dispatcher');