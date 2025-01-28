/*
  # Fix order table policies
  
  1. Changes
    - Simplify policies to avoid recursion
    - Fix role-based access
  
  2. Security
    - Enable RLS
    - Add role-based policies without circular references
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Admin full access" ON orders;
DROP POLICY IF EXISTS "Drivers can read own orders" ON orders;
DROP POLICY IF EXISTS "Dispatchers can read all orders" ON orders;

-- Create simplified policies
CREATE POLICY "Admin full access"
ON orders
FOR ALL 
TO authenticated
USING (
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'admin'
);

CREATE POLICY "Drivers can read own orders"
ON orders
FOR SELECT
TO authenticated
USING (
  driver_id = auth.uid() AND
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'driver'
);

CREATE POLICY "Dispatchers can read all orders"
ON orders
FOR SELECT
TO authenticated
USING (
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'dispatcher'
);

-- Create policy for drivers to update their own orders
CREATE POLICY "Drivers can update own orders"
ON orders
FOR UPDATE
TO authenticated
USING (
  driver_id = auth.uid() AND
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'driver'
)
WITH CHECK (
  driver_id = auth.uid() AND
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'driver'
);