/*
  # Fix Vehicle Assignment System

  1. Changes
    - Drop and recreate driver_vehicles table with correct references
    - Add proper RLS policies
    - Add function for managing primary vehicle assignments

  2. Security
    - Enable RLS
    - Add policies for authenticated users
    - Ensure proper access control
*/

-- Drop existing table
DROP TABLE IF EXISTS driver_vehicles;

-- Create driver_vehicles table with correct references
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
  IF NEW.is_primary THEN
    -- Set all other vehicles for this driver as non-primary
    UPDATE driver_vehicles
    SET is_primary = false
    WHERE driver_id = NEW.driver_id
    AND id != NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to manage primary vehicle assignments
CREATE TRIGGER manage_primary_vehicle_trigger
BEFORE INSERT OR UPDATE ON driver_vehicles
FOR EACH ROW
EXECUTE FUNCTION manage_primary_vehicle();