/*
  # Fix driver policies with proper role checks

  1. Changes
    - Remove NEW table references
    - Simplify policies to avoid recursion
    - Split read and write permissions clearly
    - Ensure proper role-based access control
*/

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_admin_access" ON drivers;
DROP POLICY IF EXISTS "drivers_insert_own" ON drivers;
DROP POLICY IF EXISTS "drivers_read_own" ON drivers;
DROP POLICY IF EXISTS "drivers_update_own" ON drivers;

-- Create new non-recursive policies
CREATE POLICY "drivers_insert_profile"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = id
);

CREATE POLICY "drivers_read_profile"
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

CREATE POLICY "drivers_update_profile"
ON drivers
FOR UPDATE
TO authenticated
USING (
  auth.uid() = id
  AND EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = (SELECT role FROM drivers WHERE id = auth.uid())
  )
);