-- Remove phone column if it exists
ALTER TABLE drivers 
DROP COLUMN IF EXISTS phone;

-- Add email column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'drivers' 
    AND column_name = 'email'
  ) THEN
    ALTER TABLE drivers ADD COLUMN email text;
  END IF;
END $$;

-- Add role column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'drivers' 
    AND column_name = 'role'
  ) THEN
    ALTER TABLE drivers ADD COLUMN role text NOT NULL DEFAULT 'driver';
  END IF;
END $$;

-- Drop existing constraints if they exist
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'drivers_email_key'
  ) THEN
    ALTER TABLE drivers DROP CONSTRAINT drivers_email_key;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'drivers_role_check'
  ) THEN
    ALTER TABLE drivers DROP CONSTRAINT drivers_role_check;
  END IF;
END $$;

-- Add constraints
ALTER TABLE drivers
ALTER COLUMN email SET NOT NULL,
ADD CONSTRAINT drivers_email_key UNIQUE (email),
ADD CONSTRAINT drivers_role_check CHECK (role IN ('admin', 'driver', 'dispatcher'));

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_drivers_role ON drivers(role);
CREATE INDEX IF NOT EXISTS idx_drivers_email ON drivers(email);

-- Force schema cache refresh
SELECT pg_notify('pgrst', 'reload schema');