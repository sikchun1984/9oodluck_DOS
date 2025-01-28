/*
  # Remove model and capacity columns

  1. Changes
    - Remove model column from vehicles table
    - Remove capacity column from vehicles table
*/

-- Remove model and capacity columns
ALTER TABLE vehicles 
DROP COLUMN IF EXISTS model,
DROP COLUMN IF EXISTS capacity;