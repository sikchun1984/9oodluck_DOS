/*
  # Update drivers table schema

  1. Changes
    - Remove phone column from drivers table since we're using email
    - Add missing indexes and constraints
*/

-- Remove phone column if it exists
ALTER TABLE drivers 
DROP COLUMN IF EXISTS phone;

-- Add email constraint if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'drivers_email_key'
  ) THEN
    ALTER TABLE drivers
    ADD CONSTRAINT drivers_email_key UNIQUE (email);
  END IF;
END $$;

-- Add index on role if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_indexes
    WHERE tablename = 'drivers'
    AND indexname = 'idx_drivers_role'
  ) THEN
    CREATE INDEX idx_drivers_role ON drivers(role);
  END IF;
END $$;

-- Force schema cache refresh
SELECT pg_notify('pgrst', 'reload schema');