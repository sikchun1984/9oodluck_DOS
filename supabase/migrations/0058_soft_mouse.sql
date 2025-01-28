/*
  # Remove model and capacity columns from vehicles table

  1. Changes
    - Remove model column from vehicles table
    - Remove capacity column from vehicles table
    - Add missing indexes and constraints
*/

-- Remove columns if they exist
ALTER TABLE vehicles 
DROP COLUMN IF EXISTS model,
DROP COLUMN IF EXISTS capacity;

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
SELECT pg_notify('pgrst', 'reload schema');