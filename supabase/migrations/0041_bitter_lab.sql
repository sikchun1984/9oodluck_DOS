/*
  # Fix driver policies recursion
  
  1. Changes
    - Remove recursive role checks
    - Implement non-recursive policies
    - Maintain proper access control
    - Fix infinite recursion in policy definitions
*/

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_insert_profile" ON drivers;
DROP POLICY IF EXISTS "drivers_read_profile" ON drivers;
DROP POLICY IF EXISTS "drivers_update_profile" ON drivers;

-- Create materialized view for role lookups
CREATE MATERIALIZED VIEW IF NOT EXISTS user_roles AS
SELECT id, role FROM drivers;

CREATE UNIQUE INDEX IF NOT EXISTS user_roles_id_idx ON user_roles(id);

-- Create function to refresh roles
CREATE OR REPLACE FUNCTION refresh_user_roles()
RETURNS TRIGGER AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY user_roles;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to keep roles updated
DROP TRIGGER IF EXISTS refresh_user_roles_trigger ON drivers;
CREATE TRIGGER refresh_user_roles_trigger
AFTER INSERT OR UPDATE OR DELETE ON drivers
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_user_roles();

-- Create new non-recursive policies using materialized view
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
  OR (SELECT role FROM user_roles WHERE id = auth.uid()) IN ('admin', 'dispatcher')
);

CREATE POLICY "drivers_update_profile"
ON drivers
FOR UPDATE
TO authenticated
USING (
  auth.uid() = id
);