/*
  # Remove unused vehicle columns
  
  1. Changes
    - Remove model and capacity columns from vehicles table
    - Update existing data to work with simplified schema
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