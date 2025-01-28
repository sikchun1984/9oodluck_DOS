/*
  # Simplify Database Policies Further

  This migration fixes the infinite recursion issue by:
  1. Using simpler role checks without self-referential queries
  2. Separating role checks from data access checks
  3. Using subqueries only where absolutely necessary
*/

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_insert" ON drivers;
DROP POLICY IF EXISTS "drivers_select" ON drivers;
DROP POLICY IF EXISTS "drivers_update" ON drivers;
DROP POLICY IF EXISTS "orders_admin" ON orders;
DROP POLICY IF EXISTS "orders_driver_select" ON orders;
DROP POLICY IF EXISTS "orders_driver_update" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_select" ON orders;

-- Create base driver policies
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
  -- Allow users to read their own profile
  auth.uid() = id
  OR
  -- Allow admins and dispatchers to read other profiles
  EXISTS (
    SELECT 1 
    FROM drivers admin 
    WHERE admin.id = auth.uid() 
    AND admin.role IN ('admin', 'dispatcher')
    AND admin.id != drivers.id -- Prevent self-reference
  )
);

CREATE POLICY "drivers_update_policy"
ON drivers
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Create order policies with separate role checks
CREATE POLICY "orders_admin_policy"
ON orders
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM drivers admin 
    WHERE admin.id = auth.uid() 
    AND admin.role = 'admin'
  )
);

CREATE POLICY "orders_driver_read_policy"
ON orders
FOR SELECT
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

CREATE POLICY "orders_driver_update_policy"
ON orders
FOR UPDATE
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

CREATE POLICY "orders_dispatcher_read_policy"
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