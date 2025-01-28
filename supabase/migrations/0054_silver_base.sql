/*
  # Fix vehicle schema and constraints

  1. Changes
    - Ensure vehicle table has correct structure
    - Add proper constraints and indexes
    - Clean up any remaining model/capacity references
*/

-- First ensure any existing model/capacity references are removed
DO $$ 
BEGIN
  -- Remove model column if it exists
  IF EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'vehicles' 
    AND column_name = 'model'
  ) THEN
    ALTER TABLE vehicles DROP COLUMN model;
  END IF;

  -- Remove capacity column if it exists
  IF EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'vehicles' 
    AND column_name = 'capacity'
  ) THEN
    ALTER TABLE vehicles DROP COLUMN capacity;
  END IF;
END $$;

-- Add status check constraint if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.check_constraints
    WHERE constraint_name = 'vehicles_status_check'
  ) THEN
    ALTER TABLE vehicles
    ADD CONSTRAINT vehicles_status_check
    CHECK (status IN ('active', 'inactive'));
  END IF;
END $$;

-- Add index on driver_id if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_indexes
    WHERE tablename = 'vehicles'
    AND indexname = 'idx_vehicles_driver_id'
  ) THEN
    CREATE INDEX idx_vehicles_driver_id ON vehicles(driver_id);
  END IF;
END $$;

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';