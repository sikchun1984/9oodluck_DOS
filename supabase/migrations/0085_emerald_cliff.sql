-- Create session management functions
CREATE OR REPLACE FUNCTION auth.get_session_role()
RETURNS text AS $$
DECLARE
  v_role text;
BEGIN
  -- Get highest priority role for current session
  SELECT role INTO v_role
  FROM user_roles ur
  WHERE ur.user_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM auth.users u
    WHERE u.id = ur.user_id
  )
  ORDER BY 
    CASE role
      WHEN 'admin' THEN 1
      WHEN 'dispatcher' THEN 2
      WHEN 'driver' THEN 3
    END
  LIMIT 1;
  
  RETURN COALESCE(v_role, 'driver');
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Create role validation trigger
CREATE OR REPLACE FUNCTION auth.validate_user_role()
RETURNS trigger AS $$
BEGIN
  -- Ensure role is valid
  IF NOT (NEW.role = ANY(ARRAY['admin', 'driver', 'dispatcher'])) THEN
    RAISE EXCEPTION 'Invalid role: %', NEW.role;
  END IF;

  -- For DELETE operations
  IF TG_OP = 'DELETE' THEN
    -- Prevent removing admin role if it's the last one
    IF OLD.role = 'admin' THEN
      IF NOT EXISTS (
        SELECT 1 FROM user_roles
        WHERE role = 'admin'
        AND user_id != OLD.user_id
      ) THEN
        RAISE EXCEPTION 'Cannot remove last admin';
      END IF;
    END IF;
    RETURN OLD;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for role validation
DROP TRIGGER IF EXISTS validate_user_role_trigger ON user_roles;
CREATE TRIGGER validate_user_role_trigger
BEFORE INSERT OR UPDATE OR DELETE ON user_roles
FOR EACH ROW EXECUTE FUNCTION auth.validate_user_role();

-- Update policies to use session role
DROP POLICY IF EXISTS "drivers_select_policy" ON drivers;
DROP POLICY IF EXISTS "drivers_update_policy" ON drivers;
DROP POLICY IF EXISTS "orders_admin_policy" ON orders;
DROP POLICY IF EXISTS "orders_driver_policy" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_policy" ON orders;

-- Enhanced driver policies
CREATE POLICY "drivers_select_policy"
ON drivers
FOR SELECT
TO authenticated
USING (
  auth.uid() = id 
  OR auth.get_session_role() IN ('admin', 'dispatcher')
);

CREATE POLICY "drivers_update_policy"
ON drivers
FOR UPDATE
TO authenticated
USING (
  auth.uid() = id 
  OR auth.get_session_role() = 'admin'
);

-- Enhanced order policies
CREATE POLICY "orders_admin_policy"
ON orders
FOR ALL 
TO authenticated
USING (auth.get_session_role() = 'admin');

CREATE POLICY "orders_driver_policy"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid() 
  AND auth.get_session_role() = 'driver'
);

CREATE POLICY "orders_dispatcher_policy"
ON orders
FOR SELECT
TO authenticated
USING (auth.get_session_role() = 'dispatcher');

-- Ensure admin user is properly configured
DO $$
DECLARE
  v_user_id uuid;
  v_email text := '9oodluckgroup@gmail.com';
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = v_email;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Admin user not found: %', v_email;
  END IF;

  -- Ensure driver profile exists
  INSERT INTO drivers (id, email, full_name, license_number)
  VALUES (
    v_user_id,
    v_email,
    'Admin User',
    'ADMIN-' || encode(sha256(v_user_id::text::bytea), 'hex')
  )
  ON CONFLICT (id) DO UPDATE
  SET 
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name;

  -- Add missing roles without removing existing ones
  INSERT INTO user_roles (user_id, role)
  VALUES
    (v_user_id, 'admin'),
    (v_user_id, 'driver'),
    (v_user_id, 'dispatcher')
  ON CONFLICT (user_id, role) DO NOTHING;

  -- Update user metadata only
  UPDATE auth.users
  SET raw_user_meta_data = jsonb_build_object(
    'roles', ARRAY['admin', 'driver', 'dispatcher']
  )
  WHERE id = v_user_id;
END $$;