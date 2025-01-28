/*
  # Fix Role-Based Access Control Policies

  This migration fixes the role-based access control by:
  1. Dropping existing policies
  2. Creating new policies that use proper role checks
  3. Ensuring no recursive dependencies
*/

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_insert" ON drivers;
DROP POLICY IF EXISTS "drivers_select" ON drivers;
DROP POLICY IF EXISTS "drivers_update" ON drivers;
DROP POLICY IF EXISTS "Admin access" ON orders;
DROP POLICY IF EXISTS "Driver read own" ON orders;
DROP POLICY IF EXISTS "Driver update own" ON orders;
DROP POLICY IF EXISTS "Dispatcher read" ON orders;

-- Create simplified driver policies
CREATE POLICY "drivers_insert_policy"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

CREATE POLICY "drivers_select_policy"
ON drivers
FOR SELECT
TO authenticated
USING (
  auth.uid() = id 
  OR EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role IN ('admin', 'dispatcher')
  )
);

CREATE POLICY "drivers_update_policy"
ON drivers
FOR UPDATE
TO authenticated
USING (auth.uid() = id);

-- Create simplified order policies
CREATE POLICY "orders_admin_policy"
ON orders
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'admin'
  )
);

CREATE POLICY "orders_driver_read_policy"
ON orders
FOR SELECT
TO authenticated
USING (
  driver_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'driver'
  )
);

CREATE POLICY "orders_driver_update_policy"
ON orders
FOR UPDATE
TO authenticated
USING (
  driver_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'driver'
  )
);

CREATE POLICY "orders_dispatcher_read_policy"
ON orders
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'dispatcher'
  )
);