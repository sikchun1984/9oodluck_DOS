-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS auth.get_user_roles(uuid);
DROP FUNCTION IF EXISTS auth.has_role(text);

-- Create function to get user roles
CREATE OR REPLACE FUNCTION auth.get_user_roles(user_uuid uuid)
RETURNS text[] AS $$
BEGIN
  RETURN ARRAY(
    SELECT role 
    FROM user_roles 
    WHERE user_id = user_uuid
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to check if user has role
CREATE OR REPLACE FUNCTION auth.has_role(required_role text)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM user_roles 
    WHERE user_id = auth.uid() 
    AND role = required_role
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update drivers policies to use role functions
DROP POLICY IF EXISTS "drivers_select_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_update_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_insert_policy" ON drivers;

CREATE POLICY "drivers_select_policy"
ON drivers
FOR SELECT
TO authenticated
USING (
  id = auth.uid()
  OR auth.has_role('admin') 
  OR auth.has_role('dispatcher')
);

CREATE POLICY "drivers_update_policy"
ON drivers
FOR UPDATE
TO authenticated
USING (
  id = auth.uid()
  OR auth.has_role('admin')
);

CREATE POLICY "drivers_insert_policy"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_roles_user_role ON user_roles(user_id, role);
CREATE INDEX IF NOT EXISTS idx_drivers_id ON drivers(id);

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';