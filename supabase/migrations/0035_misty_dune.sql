/*
  # Fix drivers table policies

  1. Changes
    - Drop existing recursive policies
    - Create new simplified policies without recursion
    - Add proper role-based access control
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Admins have full access" ON drivers;
DROP POLICY IF EXISTS "Dispatchers can view all drivers" ON drivers;
DROP POLICY IF EXISTS "Drivers can manage own profile" ON drivers;

-- Create new simplified policies
CREATE POLICY "Admin full access"
ON drivers
FOR ALL
TO authenticated
USING (
  current_setting('request.jwt.claims')::json->>'role' = 'admin'
);

CREATE POLICY "Driver manage own"
ON drivers
FOR ALL
TO authenticated
USING (
  auth.uid() = id AND 
  current_setting('request.jwt.claims')::json->>'role' = 'driver'
);

CREATE POLICY "Dispatcher view all"
ON drivers
FOR SELECT
TO authenticated
USING (
  current_setting('request.jwt.claims')::json->>'role' = 'dispatcher'
);