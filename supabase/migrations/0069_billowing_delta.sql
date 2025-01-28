/*
  # Integrate drivers with auth.users tables

  1. Changes
    - Add email column to drivers table
    - Update constraints and indexes
    - Sync data with auth.users
    - Add role management

  2. Security
    - Maintain RLS policies
    - Add email uniqueness constraint
*/

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

-- Update email data from auth.users
UPDATE drivers d
SET email = u.email
FROM auth.users u
WHERE d.id = u.id;

-- Make email required and unique
ALTER TABLE drivers
ALTER COLUMN email SET NOT NULL,
ADD CONSTRAINT drivers_email_key UNIQUE (email);

-- Add role column if it doesn't exist with proper validation
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'drivers' 
    AND column_name = 'role'
  ) THEN
    ALTER TABLE drivers 
    ADD COLUMN role text NOT NULL DEFAULT 'driver'
    CHECK (role IN ('admin', 'driver', 'dispatcher'));
  END IF;
END $$;

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_drivers_email ON drivers(email);
CREATE INDEX IF NOT EXISTS idx_drivers_role ON drivers(role);

-- Force schema cache refresh
SELECT pg_notify('pgrst', 'reload schema');