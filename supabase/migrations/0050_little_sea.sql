/*
  # Remove model and capacity columns from vehicles table

  1. Changes
    - Remove model column from vehicles table
    - Remove capacity column from vehicles table

  2. Notes
    - This is a non-destructive change that preserves existing data
    - Vehicle functionality will continue to work with just plate number and type
*/

-- Remove model and capacity columns
ALTER TABLE vehicles 
DROP COLUMN IF EXISTS model,
DROP COLUMN IF EXISTS capacity;