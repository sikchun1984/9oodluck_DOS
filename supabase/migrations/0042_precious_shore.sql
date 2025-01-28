-- First drop the policies that depend on the materialized view
DROP POLICY IF EXISTS "Admin access" ON orders;
DROP POLICY IF EXISTS "Driver read own" ON orders;
DROP POLICY IF EXISTS "Driver update own" ON orders;
DROP POLICY IF EXISTS "Dispatcher read" ON orders;

-- Now we can safely drop the materialized view and its dependencies
DROP MATERIALIZED VIEW IF EXISTS user_roles CASCADE;
DROP TRIGGER IF EXISTS refresh_user_roles_trigger ON drivers;
DROP FUNCTION IF EXISTS refresh_user_roles();

-- Drop existing driver policies
DROP POLICY IF EXISTS "drivers_insert_profile" ON drivers;
DROP POLICY IF EXISTS "drivers_read_profile" ON drivers;
DROP POLICY IF EXISTS "drivers_update_profile" ON drivers;

-- Create new driver policies without recursion
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
  -- Admins and dispatchers can read all profiles
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role IN ('admin', 'dispatcher')
  )
);

CREATE POLICY "drivers_update"
ON drivers
FOR UPDATE
TO authenticated
USING (auth.uid() = id);

-- Recreate order policies without using the materialized view
CREATE POLICY "Admin access"
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

CREATE POLICY "Driver read own"
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

CREATE POLICY "Driver update own"
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

CREATE POLICY "Dispatcher read"
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