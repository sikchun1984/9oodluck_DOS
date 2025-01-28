/*
  # Fix vehicle assignments and relationships

  1. Changes
    - Add proper foreign key relationships
    - Update driver_vehicles table structure
    - Fix constraints and references

  2. Security
    - Update RLS policies for better access control
*/

-- First ensure the drivers table exists with correct structure
CREATE TABLE IF NOT EXISTS drivers (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  phone text NOT NULL,
  license_number text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Recreate driver_vehicles table with proper references
DROP TABLE IF EXISTS driver_vehicles;
CREATE TABLE driver_vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id uuid NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  vehicle_id uuid NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  assigned_at timestamptz DEFAULT now(),
  is_primary boolean DEFAULT false,
  UNIQUE(driver_id, vehicle_id)
);

-- Enable RLS
ALTER TABLE driver_vehicles ENABLE ROW LEVEL SECURITY;

-- Create comprehensive policies
CREATE POLICY "Drivers can manage their vehicle assignments"
ON driver_vehicles
FOR ALL
TO authenticated
USING (
  auth.uid() = driver_id
)
WITH CHECK (
  auth.uid() = driver_id
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_driver_vehicles_driver_id ON driver_vehicles(driver_id);
CREATE INDEX IF NOT EXISTS idx_driver_vehicles_vehicle_id ON driver_vehicles(vehicle_id);