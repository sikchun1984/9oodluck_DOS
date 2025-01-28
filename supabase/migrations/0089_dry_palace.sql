-- Drop existing policies on user_roles
DROP POLICY IF EXISTS "Admins can manage roles" ON user_roles;
DROP POLICY IF EXISTS "Users can view own roles" ON user_roles;

-- Create new non-recursive policies
CREATE POLICY "user_roles_admin_access"
ON user_roles
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.id IN (
      SELECT ur.user_id 
      FROM user_roles ur 
      WHERE ur.role = 'admin'
      AND ur.user_id != user_roles.user_id  -- Prevent recursion
    )
  )
);

CREATE POLICY "user_roles_self_read"
ON user_roles
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';