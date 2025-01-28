/*
  # Fix driver vehicles table and relationships

  1. Changes
    - Add missing driver reference in driver_vehicles table
    - Add missing driver data to vehicle assignments query
    - Fix unique constraint issue

  2. Security
    - Update RLS policies for better access control
*/

-- First ensure the drivers table exists and has correct references
CREATE TABLE IF NOT EXISTS drivers (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  phone text NOT NULL,
  license_number text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Modify driver_vehicles table
ALTER TABLE driver_vehicles
DROP CONSTRAINT IF EXISTS driver_vehicles_driver_id_vehicle_id_key;

-- Add new composite unique constraint
ALTER TABLE driver_vehicles
ADD CONSTRAINT driver_vehicles_unique_assignment 
UNIQUE (driver_id, vehicle_id);

-- Update RLS policies
ALTER TABLE driver_vehicles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Drivers can manage their vehicle assignments" ON driver_vehicles;

CREATE POLICY "Drivers can manage their vehicle assignments"
ON driver_vehicles
FOR ALL
TO authenticated
USING (
  auth.uid() = driver_id
  AND EXISTS (
    SELECT 1 FROM drivers d 
    WHERE d.id = driver_vehicles.driver_id
  )
)
WITH CHECK (
  auth.uid() = driver_id
  AND EXISTS (
    SELECT 1 FROM drivers d 
    WHERE d.id = driver_vehicles.driver_id
  )
);