-- First update all non-admin users to have driver role
UPDATE drivers
SET role = 'driver'
WHERE role = 'dispatcher';

-- Drop existing policies that reference dispatcher role
DROP POLICY IF EXISTS "drivers_select" ON drivers;
DROP POLICY IF EXISTS "drivers_update" ON drivers;
DROP POLICY IF EXISTS "drivers_insert" ON drivers;
DROP POLICY IF EXISTS "orders_admin" ON orders;
DROP POLICY IF EXISTS "orders_driver" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher" ON orders;

-- Create simplified driver policies
CREATE POLICY "drivers_select"
ON drivers
FOR SELECT
TO authenticated
USING (
  id = auth.uid() OR
  get_user_role(auth.uid()) = 'admin'
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

-- Create simplified order policies
CREATE POLICY "orders_admin"
ON orders
FOR ALL 
TO authenticated
USING (get_user_role(auth.uid()) = 'admin');

CREATE POLICY "orders_driver"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid() AND
  get_user_role(auth.uid()) = 'driver'
);

-- Update role check constraint
ALTER TABLE drivers
DROP CONSTRAINT IF EXISTS drivers_role_check,
ADD CONSTRAINT drivers_role_check 
CHECK (role IN ('admin', 'driver'));

-- Update ensure_driver_profile function
CREATE OR REPLACE FUNCTION ensure_driver_profile()
RETURNS trigger AS $$
DECLARE
  v_role text;
BEGIN
  -- Get role from metadata or default to 'driver'
  v_role := CASE 
    WHEN NEW.email = '9oodluckgroup@gmail.com' THEN 'admin'
    ELSE 'driver'
  END;

  -- Create or update driver profile
  INSERT INTO drivers (
    id,
    email,
    full_name,
    role,
    license_number
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    v_role,
    'PENDING-' || substring(NEW.id::text, 1, 8)
  )
  ON CONFLICT (id) DO UPDATE
  SET 
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, drivers.full_name),
    role = CASE
      WHEN drivers.role = 'admin' THEN 'admin'
      ELSE 'driver'
    END;

  -- Update user metadata
  UPDATE auth.users
  SET raw_user_meta_data = 
    CASE 
      WHEN raw_user_meta_data IS NULL THEN 
        jsonb_build_object('role', v_role)
      ELSE 
        raw_user_meta_data || jsonb_build_object('role', v_role)
    END
  WHERE id = NEW.id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';