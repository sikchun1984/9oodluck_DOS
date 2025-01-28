-- Drop policies that depend on role functions
DROP POLICY IF EXISTS "orders_admin_policy" ON orders;
DROP POLICY IF EXISTS "orders_driver_policy" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_policy" ON orders;
DROP POLICY IF EXISTS "drivers_select_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_update_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_insert_policy" ON drivers;

-- Drop role-related functions
DROP FUNCTION IF EXISTS auth.get_user_roles(uuid) CASCADE;
DROP FUNCTION IF EXISTS auth.has_role(text) CASCADE;
DROP FUNCTION IF EXISTS auth.get_session_role() CASCADE;
DROP FUNCTION IF EXISTS auth.validate_user_role() CASCADE;
DROP FUNCTION IF EXISTS refresh_admin_users() CASCADE;

-- Drop triggers
DROP TRIGGER IF EXISTS refresh_admin_users_trigger ON user_roles;
DROP TRIGGER IF EXISTS refresh_user_roles_trigger ON drivers;

-- Drop materialized views
DROP MATERIALIZED VIEW IF EXISTS admin_users CASCADE;

-- Drop table (this will cascade to dependent objects)
DROP TABLE IF EXISTS user_roles CASCADE;

-- Create simple ownership-based policies for drivers
CREATE POLICY "drivers_select_own"
ON drivers
FOR SELECT
TO authenticated
USING (id = auth.uid());

CREATE POLICY "drivers_update_own"
ON drivers
FOR UPDATE
TO authenticated
USING (id = auth.uid());

CREATE POLICY "drivers_insert_own"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Create simple ownership-based policies for orders
CREATE POLICY "orders_access_own"
ON orders
FOR ALL
TO authenticated
USING (driver_id = auth.uid());

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';