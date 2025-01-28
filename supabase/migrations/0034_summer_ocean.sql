/*
  # Fix order policies to prevent recursion
  
  1. Changes
    - Create materialized role view for efficient role checks
    - Simplify policy conditions using the materialized view
    - Remove nested queries that cause recursion
  
  2. Security
    - Maintain proper access control
    - Prevent infinite recursion
*/

-- Create materialized view for role checks
CREATE MATERIALIZED VIEW user_roles AS
SELECT id, role FROM drivers;

-- Create index for efficient lookups
CREATE UNIQUE INDEX user_roles_id_idx ON user_roles (id);

-- Create function to refresh user roles
CREATE OR REPLACE FUNCTION refresh_user_roles()
RETURNS TRIGGER AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY user_roles;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to refresh roles on changes
CREATE TRIGGER refresh_user_roles_trigger
AFTER INSERT OR UPDATE OR DELETE ON drivers
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_user_roles();

-- Drop existing policies
DROP POLICY IF EXISTS "Admin access" ON orders;
DROP POLICY IF EXISTS "Driver read own" ON orders;
DROP POLICY IF EXISTS "Driver update own" ON orders;
DROP POLICY IF EXISTS "Dispatcher read" ON orders;

-- Create new simplified policies using materialized view
CREATE POLICY "Admin access"
ON orders
FOR ALL 
TO authenticated
USING (
  (SELECT role FROM user_roles WHERE id = auth.uid()) = 'admin'
);

CREATE POLICY "Driver read own"
ON orders
FOR SELECT
TO authenticated
USING (
  driver_id = auth.uid() AND
  (SELECT role FROM user_roles WHERE id = auth.uid()) = 'driver'
);

CREATE POLICY "Driver update own"
ON orders
FOR UPDATE
TO authenticated
USING (
  driver_id = auth.uid() AND
  (SELECT role FROM user_roles WHERE id = auth.uid()) = 'driver'
);

CREATE POLICY "Dispatcher read"
ON orders
FOR SELECT
TO authenticated
USING (
  (SELECT role FROM user_roles WHERE id = auth.uid()) = 'dispatcher'
);