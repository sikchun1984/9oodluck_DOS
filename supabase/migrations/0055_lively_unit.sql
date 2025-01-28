/*
  # Fix vehicle table structure
  
  1. Changes
    - Remove model and capacity columns
    - Preserve foreign key relationships
    - Update indexes and constraints
    - Refresh schema cache
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
    ALTER TABLE vehicles DROP COLUMN IF EXISTS model;
  END IF;

  -- Remove capacity column if it exists
  IF EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'vehicles' 
    AND column_name = 'capacity'
  ) THEN
    ALTER TABLE vehicles DROP COLUMN IF EXISTS capacity;
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

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';