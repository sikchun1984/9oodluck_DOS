-- Drop existing policies
DROP POLICY IF EXISTS "user_roles_admin_access" ON user_roles;
DROP POLICY IF EXISTS "user_roles_self_read" ON user_roles;

-- Create simplified policies
CREATE POLICY "user_roles_select"
ON user_roles
FOR SELECT
TO authenticated
USING (
  -- Users can read their own roles
  user_id = auth.uid()
  OR
  -- Admins can read all roles
  EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'admin'
    AND ur.user_id != user_roles.user_id
  )
);

CREATE POLICY "user_roles_insert"
ON user_roles
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'admin'
  )
);

CREATE POLICY "user_roles_delete"
ON user_roles
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'admin'
  )
  AND
  -- Prevent deleting last admin
  (
    user_roles.role != 'admin'
    OR
    EXISTS (
      SELECT 1 FROM user_roles ur2
      WHERE ur2.role = 'admin'
      AND ur2.user_id != user_roles.user_id
    )
  )
);

-- Add index to improve policy performance
CREATE INDEX IF NOT EXISTS idx_user_roles_admin
ON user_roles(user_id) 
WHERE role = 'admin';

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';