-- Create function to ensure driver profile exists with proper role
CREATE OR REPLACE FUNCTION ensure_driver_profile()
RETURNS trigger AS $$
BEGIN
  -- Create driver profile if it doesn't exist
  INSERT INTO drivers (id, email, full_name, role, license_number)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'role', 'driver'),
    'PENDING-' || substring(NEW.id::text, 1, 8)
  )
  ON CONFLICT (id) DO UPDATE
  SET 
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, drivers.full_name);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to ensure driver profile exists
DROP TRIGGER IF EXISTS ensure_driver_profile_trigger ON auth.users;
CREATE TRIGGER ensure_driver_profile_trigger
AFTER INSERT OR UPDATE ON auth.users
FOR EACH ROW
EXECUTE FUNCTION ensure_driver_profile();

-- Create optimized role check function
CREATE OR REPLACE FUNCTION get_user_role(user_id uuid)
RETURNS text
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT COALESCE(
    (
      SELECT role 
      FROM drivers 
      WHERE id = user_id 
      AND role IS NOT NULL
      LIMIT 1
    ),
    'driver'
  );
$$;

-- Add optimized index for role lookups
DROP INDEX IF EXISTS idx_drivers_role_lookup;
CREATE INDEX idx_drivers_role_lookup 
ON drivers(id, role) 
WHERE role IS NOT NULL;

-- Ensure all existing users have driver profiles
INSERT INTO drivers (id, email, full_name, role, license_number)
SELECT 
  id,
  email,
  COALESCE(raw_user_meta_data->>'full_name', email),
  COALESCE(raw_user_meta_data->>'role', 'driver'),
  'PENDING-' || substring(id::text, 1, 8)
FROM auth.users
WHERE NOT EXISTS (
  SELECT 1 FROM drivers WHERE drivers.id = auth.users.id
);