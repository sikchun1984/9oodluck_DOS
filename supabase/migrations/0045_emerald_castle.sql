/*
  # Simplify Database Policies

  This migration fixes the infinite recursion issue by:
  1. Using simpler role checks
  2. Removing circular dependencies
  3. Separating concerns between drivers and orders
*/

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_create_profile" ON drivers;
DROP POLICY IF EXISTS "drivers_read_profile" ON drivers;
DROP POLICY IF EXISTS "drivers_update_profile" ON drivers;
DROP POLICY IF EXISTS "orders_admin_access" ON orders;
DROP POLICY IF EXISTS "orders_driver_access" ON orders;
DROP POLICY IF EXISTS "orders_driver_update" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_access" ON orders;

-- Create base driver policies
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
  -- Allow reading own profile
  auth.uid() = id
  OR 
  -- Allow admins and dispatchers to read all profiles
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role IN ('admin', 'dispatcher')
    AND d.id != drivers.id
  )
);

CREATE POLICY "drivers_update"
ON drivers
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Create order policies
CREATE POLICY "orders_admin"
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

CREATE POLICY "orders_driver_select"
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
  )
);

CREATE POLICY "orders_dispatcher_select"
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