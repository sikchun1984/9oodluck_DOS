-- Create materialized view for admin users
CREATE MATERIALIZED VIEW admin_users AS
SELECT DISTINCT user_id
FROM user_roles
WHERE role = 'admin';

-- Create unique index for better performance
CREATE UNIQUE INDEX admin_users_user_id_idx ON admin_users(user_id);

-- Create function to refresh admin users view
CREATE OR REPLACE FUNCTION refresh_admin_users()
RETURNS TRIGGER AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY admin_users;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to keep admin users view updated
CREATE TRIGGER refresh_admin_users_trigger
AFTER INSERT OR UPDATE OR DELETE ON user_roles
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_admin_users();

-- Drop existing policies
DROP POLICY IF EXISTS "user_roles_select" ON user_roles;
DROP POLICY IF EXISTS "user_roles_insert" ON user_roles;
DROP POLICY IF EXISTS "user_roles_delete" ON user_roles;

-- Create new simplified policies using materialized view
CREATE POLICY "user_roles_read_policy"
ON user_roles
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid() OR
  auth.uid() IN (SELECT user_id FROM admin_users)
);

CREATE POLICY "user_roles_write_policy"
ON user_roles
FOR ALL
TO authenticated
USING (
  auth.uid() IN (SELECT user_id FROM admin_users)
)
WITH CHECK (
  auth.uid() IN (SELECT user_id FROM admin_users)
);

-- Do initial refresh of materialized view
REFRESH MATERIALIZED VIEW admin_users;

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';