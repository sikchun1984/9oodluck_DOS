/*
  # Fix RLS Policies to Prevent Recursion

  1. Changes
    - Create a secure function to check roles without triggering RLS
    - Update policies to use the new function
    - Ensure no circular dependencies in policy definitions
    
  2. Security
    - Maintain role-based access control
    - Prevent infinite recursion
    - Ensure proper authentication checks
*/

-- Create a secure function to check roles
CREATE OR REPLACE FUNCTION get_user_role(user_id uuid)
RETURNS text
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT role FROM drivers WHERE id = user_id;
$$;

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_insert" ON drivers;
DROP POLICY IF EXISTS "drivers_select" ON drivers;
DROP POLICY IF EXISTS "drivers_update" ON drivers;
DROP POLICY IF EXISTS "orders_admin" ON orders;
DROP POLICY IF EXISTS "orders_driver" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_read" ON orders;

-- Create driver policies using the secure function
CREATE POLICY "drivers_insert"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

CREATE POLICY "drivers_select"
ON drivers
FOR SELECT
TO authenticated
USING (
  -- Users can always read their own profile
  auth.uid() = id
  OR
  -- Admins and dispatchers can read other profiles
  get_user_role(auth.uid()) IN ('admin', 'dispatcher')
);

CREATE POLICY "drivers_update"
ON drivers
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Create order policies using the secure function
CREATE POLICY "orders_admin"
ON orders
FOR ALL 
TO authenticated
USING (get_user_role(auth.uid()) = 'admin');

CREATE POLICY "orders_driver"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid()
  AND get_user_role(auth.uid()) = 'driver'
);

CREATE POLICY "orders_dispatcher_read"
ON orders
FOR SELECT
TO authenticated
USING (get_user_role(auth.uid()) = 'dispatcher');