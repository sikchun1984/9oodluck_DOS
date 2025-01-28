/*
  # Update order table policies
  
  1. Changes
    - Add policies for admin access
    - Fix driver access policies
    - Add dispatcher access policies
  
  2. Security
    - Enable RLS
    - Add role-based policies
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Drivers can create orders" ON orders;
DROP POLICY IF EXISTS "Drivers can read own orders" ON orders;
DROP POLICY IF EXISTS "Drivers can update own orders" ON orders;
DROP POLICY IF EXISTS "Drivers can delete own orders" ON orders;

-- Create new comprehensive policies
CREATE POLICY "Admin full access"
ON orders
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role = 'admin'
  )
);

CREATE POLICY "Drivers can read own orders"
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

CREATE POLICY "Dispatchers can read all orders"
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