/*
  # Fix drivers RLS policies

  1. Changes
    - Drop existing policies first
    - Create new policies with proper role checks
    - Allow users to create their initial profile
    - Fix role checking logic

  2. Security
    - Enable RLS
    - Add policies for admin, driver, and dispatcher roles
    - Ensure proper access control
*/

-- First drop all existing policies
DROP POLICY IF EXISTS "admin_full_access" ON drivers;
DROP POLICY IF EXISTS "driver_manage_own" ON drivers;
DROP POLICY IF EXISTS "dispatcher_view_all" ON drivers;

-- Create new policies with proper role checks
CREATE POLICY "drivers_admin_full_access"
ON drivers
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'admin'
  )
);

CREATE POLICY "drivers_create_initial_profile"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = id
  AND NOT EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
  )
);

CREATE POLICY "drivers_manage_own_profile"
ON drivers
FOR ALL
TO authenticated
USING (
  auth.uid() = id
  AND EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'driver'
  )
);

CREATE POLICY "drivers_dispatcher_view_all"
ON drivers
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'dispatcher'
  )
);