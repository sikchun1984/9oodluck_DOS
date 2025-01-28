/*
  # Fix vehicle-driver relationship

  1. Changes
    - Update vehicles table to reference auth.users instead of drivers
    - Add cascade delete for vehicles when driver is deleted
  
  2. Security
    - Maintain existing RLS policies
*/

-- First drop the existing foreign key
ALTER TABLE vehicles 
DROP CONSTRAINT IF EXISTS vehicles_driver_id_fkey;

-- Add new foreign key referencing auth.users
ALTER TABLE vehicles
ADD CONSTRAINT vehicles_driver_id_fkey 
FOREIGN KEY (driver_id) 
REFERENCES auth.users(id)
ON DELETE CASCADE;