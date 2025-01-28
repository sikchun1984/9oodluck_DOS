/*
  # Fix driver vehicles table and relationships

  1. Changes
    - Recreate driver_vehicles table with correct structure
    - Update trigger function to properly handle primary vehicle assignments
    - Add proper indexes and constraints

  2. Security
    - Enable RLS
    - Add comprehensive policies for vehicle management
*/

-- Drop existing table and related objects
DROP TRIGGER IF EXISTS manage_primary_vehicle_trigger ON driver_vehicles;
DROP FUNCTION IF EXISTS manage_primary_vehicle();
DROP TABLE IF EXISTS driver_vehicles;

-- Create driver_vehicles table with correct structure
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

-- Create function to manage primary vehicle assignments
CREATE OR REPLACE FUNCTION manage_primary_vehicle()
RETURNS TRIGGER AS $$
BEGIN
  -- Only proceed if setting as primary
  IF NEW.is_primary THEN
    -- Set all other vehicles for this driver as non-primary
    UPDATE driver_vehicles
    SET is_primary = false
    WHERE driver_id = NEW.driver_id
    AND id != COALESCE(NEW.id, uuid_nil());
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for primary vehicle management
CREATE TRIGGER manage_primary_vehicle_trigger
BEFORE INSERT OR UPDATE ON driver_vehicles
FOR EACH ROW
EXECUTE FUNCTION manage_primary_vehicle();

-- Create indexes for better query performance
CREATE INDEX idx_driver_vehicles_driver_id ON driver_vehicles(driver_id);
CREATE INDEX idx_driver_vehicles_vehicle_id ON driver_vehicles(vehicle_id);
CREATE INDEX idx_driver_vehicles_is_primary ON driver_vehicles(driver_id, is_primary) WHERE is_primary = true;