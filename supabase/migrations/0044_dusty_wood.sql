/*
  # Fix Recursive Policies

  This migration fixes the infinite recursion issue in RLS policies by:
  1. Creating a base policy for initial profile creation
  2. Using non-recursive role checks
  3. Simplifying policy logic
*/

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_insert_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_select_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_update_policy" ON drivers;
DROP POLICY IF EXISTS "orders_admin_policy" ON orders;
DROP POLICY IF EXISTS "orders_driver_read_policy" ON orders;
DROP POLICY IF EXISTS "orders_driver_update_policy" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_read_policy" ON orders;

-- Create base policy for initial profile creation
CREATE POLICY "drivers_create_profile"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = id
  AND NOT EXISTS (
    SELECT 1 FROM drivers WHERE id = auth.uid()
  )
);

-- Create policy for reading driver profiles
CREATE POLICY "drivers_read_profile"
ON drivers
FOR SELECT
TO authenticated
USING (
  -- Can always read own profile
  auth.uid() = id
  OR 
  -- Admins and dispatchers can read all profiles
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role IN ('admin', 'dispatcher')
    AND d.id != drivers.id  -- Prevent recursion
  )
);

-- Create policy for updating driver profiles
CREATE POLICY "drivers_update_profile"
ON drivers
FOR UPDATE
TO authenticated
USING (auth.uid() = id);

-- Create order policies with non-recursive role checks
CREATE POLICY "orders_admin_access"
ON orders
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'admin'
    AND d.id != orders.driver_id  -- Prevent recursion
  )
);

CREATE POLICY "orders_driver_access"
ON orders
FOR SELECT
TO authenticated
USING (
  driver_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'driver'
    AND d.id = orders.driver_id  -- Ensure proper ownership
  )
);

CREATE POLICY "orders_driver_update"
ON orders
FOR UPDATE
TO authenticated
USING (
  driver_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'driver'
    AND d.id = orders.driver_id  -- Ensure proper ownership
  )
);

CREATE POLICY "orders_dispatcher_access"
ON orders
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'dispatcher'
    AND d.id != orders.driver_id  -- Prevent recursion
  )
);