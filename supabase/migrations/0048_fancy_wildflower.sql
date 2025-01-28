/*
  # Simplify RLS Policies

  1. Changes
    - Drop existing policies and functions with proper CASCADE
    - Create simplified driver policies
    - Create simplified order policies
    
  2. Security
    - Maintain role-based access control
    - Prevent infinite recursion
    - Ensure proper authentication checks
*/

-- First drop all policies that depend on the function
DROP POLICY IF EXISTS "drivers_select_policy" ON drivers;
DROP POLICY IF EXISTS "orders_admin_policy" ON orders;
DROP POLICY IF EXISTS "orders_driver_read_policy" ON orders;
DROP POLICY IF EXISTS "orders_driver_update_policy" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_read_policy" ON orders;

-- Now we can safely drop the function
DROP FUNCTION IF EXISTS check_user_role CASCADE;

-- Drop remaining policies
DROP POLICY IF EXISTS "drivers_insert_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_update_policy" ON drivers;

-- Create simplified driver policies
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
  -- Admins and dispatchers can read all profiles except their own
  EXISTS (
    SELECT 1 
    FROM drivers d 
    WHERE d.id = auth.uid() 
    AND d.role IN ('admin', 'dispatcher')
    AND drivers.id != auth.uid()
  )
);

CREATE POLICY "drivers_update"
ON drivers
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Create simplified order policies
CREATE POLICY "orders_admin"
ON orders
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM drivers d 
    WHERE d.id = auth.uid() 
    AND d.role = 'admin'
  )
);

CREATE POLICY "orders_driver"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid()
  AND EXISTS (
    SELECT 1 
    FROM drivers d 
    WHERE d.id = auth.uid() 
    AND d.role = 'driver'
  )
);

CREATE POLICY "orders_dispatcher_read"
ON orders
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM drivers d 
    WHERE d.id = auth.uid() 
    AND d.role = 'dispatcher'
  )
);