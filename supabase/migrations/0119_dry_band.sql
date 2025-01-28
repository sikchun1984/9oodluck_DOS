-- Create function to ensure driver profile exists
CREATE OR REPLACE FUNCTION ensure_driver_profile()
RETURNS trigger AS $$
BEGIN
  -- Create driver profile if it doesn't exist
  INSERT INTO drivers (id, email, full_name, role, license_number)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    'driver',
    'PENDING'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to create driver profile on user creation
DROP TRIGGER IF EXISTS ensure_driver_profile_trigger ON auth.users;
CREATE TRIGGER ensure_driver_profile_trigger
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION ensure_driver_profile();

-- Update get_user_role function to handle missing profiles better
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

-- Add index for role lookups
CREATE INDEX IF NOT EXISTS idx_drivers_role_lookup 
ON drivers(id, role) 
WHERE role IS NOT NULL;