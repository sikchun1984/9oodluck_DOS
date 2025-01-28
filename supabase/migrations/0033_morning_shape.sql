/*
  # Fix order policies to prevent recursion
  
  1. Changes
    - Remove nested role checks that cause recursion
    - Simplify policy conditions
    - Add efficient role-based access control
  
  2. Security
    - Maintain proper access control
    - Prevent infinite recursion
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Admin full access" ON orders;
DROP POLICY IF EXISTS "Drivers can read own orders" ON orders;
DROP POLICY IF EXISTS "Dispatchers can read all orders" ON orders;
DROP POLICY IF EXISTS "Drivers can update own orders" ON orders;

-- Create new simplified policies
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