/*
  # Fix Policy Recursion with Role Check Function
  
  This migration:
  1. Creates a dedicated function for role checks
  2. Simplifies policies to avoid recursion
  3. Uses the function for all role-based checks
*/

-- Create role check function
CREATE OR REPLACE FUNCTION check_user_role(user_id uuid, required_roles text[])
RETURNS boolean AS $$
DECLARE
  user_role text;
BEGIN
  -- Direct query to get role without policy checks
  SELECT role INTO user_role
  FROM drivers
  WHERE id = user_id;
  
  RETURN user_role = ANY(required_roles);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_insert_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_select_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_update_policy" ON drivers;
DROP POLICY IF EXISTS "orders_admin_policy" ON orders;
DROP POLICY IF EXISTS "orders_driver_read_policy" ON orders;
DROP POLICY IF EXISTS "orders_driver_update_policy" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_read_policy" ON orders;

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
  OR check_user_role(auth.uid(), ARRAY['admin', 'dispatcher'])
);

CREATE POLICY "drivers_update_policy"
ON drivers
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Create simplified order policies
CREATE POLICY "orders_admin_policy"
ON orders
FOR ALL 
TO authenticated
USING (check_user_role(auth.uid(), ARRAY['admin']));

CREATE POLICY "orders_driver_read_policy"
ON orders
FOR SELECT
TO authenticated
USING (
  driver_id = auth.uid()
  AND check_user_role(auth.uid(), ARRAY['driver'])
);

CREATE POLICY "orders_driver_update_policy"
ON orders
FOR UPDATE
TO authenticated
USING (
  driver_id = auth.uid()
  AND check_user_role(auth.uid(), ARRAY['driver'])
);

CREATE POLICY "orders_dispatcher_read_policy"
ON orders
FOR SELECT
TO authenticated
USING (check_user_role(auth.uid(), ARRAY['dispatcher']));