/*
  # Fix vehicle assignments and relationships

  1. Changes
    - Drop and recreate driver_vehicles table with proper constraints
    - Add proper indexes and foreign keys
    - Update RLS policies

  2. Security
    - Ensure proper access control through RLS
*/

-- Drop existing table and recreate with proper structure
DROP TABLE IF EXISTS driver_vehicles;

CREATE TABLE driver_vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  vehicle_id uuid NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  assigned_at timestamptz DEFAULT now(),
  is_primary boolean DEFAULT false,
  CONSTRAINT driver_vehicles_unique_assignment UNIQUE (driver_id, vehicle_id)
);

-- Enable RLS
ALTER TABLE driver_vehicles ENABLE ROW LEVEL SECURITY;

-- Create comprehensive policies
CREATE POLICY "Drivers can manage their vehicle assignments"
ON driver_vehicles
FOR ALL
TO authenticated
USING (auth.uid() = driver_id)
WITH CHECK (auth.uid() = driver_id);

-- Create indexes for better performance
CREATE INDEX idx_driver_vehicles_driver_id ON driver_vehicles(driver_id);
CREATE INDEX idx_driver_vehicles_vehicle_id ON driver_vehicles(vehicle_id);