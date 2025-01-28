-- Create improved function to ensure driver profile exists
CREATE OR REPLACE FUNCTION ensure_driver_profile()
RETURNS trigger AS $$
DECLARE
  v_role text;
BEGIN
  -- Get role from metadata or default to 'driver'
  v_role := COALESCE(
    NEW.raw_user_meta_data->>'role',
    CASE 
      WHEN NEW.email = '9oodluckgroup@gmail.com' THEN 'admin'
      ELSE 'driver'
    END
  );

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
      WHEN drivers.role = 'admin' THEN 'admin'  -- Preserve admin role
      ELSE v_role
    END;

  -- Update user metadata to include role
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

-- Recreate trigger with proper timing
DROP TRIGGER IF EXISTS ensure_driver_profile_trigger ON auth.users;
CREATE TRIGGER ensure_driver_profile_trigger
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION ensure_driver_profile();

-- Create function to handle role updates
CREATE OR REPLACE FUNCTION handle_role_update()
RETURNS trigger AS $$
BEGIN
  -- Update user metadata when role changes
  IF NEW.role IS DISTINCT FROM OLD.role THEN
    UPDATE auth.users
    SET raw_user_meta_data = 
      CASE 
        WHEN raw_user_meta_data IS NULL THEN 
          jsonb_build_object('role', NEW.role)
        ELSE 
          raw_user_meta_data || jsonb_build_object('role', NEW.role)
      END
    WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for role updates
DROP TRIGGER IF EXISTS handle_role_update_trigger ON drivers;
CREATE TRIGGER handle_role_update_trigger
AFTER UPDATE OF role ON drivers
FOR EACH ROW
EXECUTE FUNCTION handle_role_update();

-- Ensure existing users have proper profiles and metadata
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT * FROM auth.users LOOP
    INSERT INTO drivers (id, email, full_name, role, license_number)
    VALUES (
      r.id,
      r.email,
      COALESCE(r.raw_user_meta_data->>'full_name', r.email),
      COALESCE(r.raw_user_meta_data->>'role', 'driver'),
      'PENDING-' || substring(r.id::text, 1, 8)
    )
    ON CONFLICT (id) DO UPDATE
    SET 
      email = EXCLUDED.email,
      full_name = COALESCE(EXCLUDED.full_name, drivers.full_name);
  END LOOP;
END $$;