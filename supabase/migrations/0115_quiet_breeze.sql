-- Create improved role check function
CREATE OR REPLACE FUNCTION get_user_role(user_id uuid)
RETURNS text
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT COALESCE(
    (SELECT role FROM drivers WHERE id = user_id),
    'driver'
  );
$$;

-- Drop existing policies
DROP POLICY IF EXISTS "drivers_select" ON drivers;
DROP POLICY IF EXISTS "drivers_update" ON drivers;
DROP POLICY IF EXISTS "drivers_insert" ON drivers;

-- Create simplified driver policies
CREATE POLICY "drivers_select"
ON drivers
FOR SELECT
TO authenticated
USING (
  id = auth.uid() OR
  get_user_role(auth.uid()) IN ('admin', 'dispatcher')
);

CREATE POLICY "drivers_update"
ON drivers
FOR UPDATE
TO authenticated
USING (
  id = auth.uid() OR
  get_user_role(auth.uid()) = 'admin'
);

CREATE POLICY "drivers_insert"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';