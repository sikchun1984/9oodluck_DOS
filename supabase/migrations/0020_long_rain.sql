/*
  # Fix Vehicle Assignment Schema

  1. Changes
    - Modify driver_vehicles table to use auth.users directly
    - Add trigger for managing primary vehicle status
    - Update RLS policies for better security

  2. Security
    - Enable RLS
    - Add policies for authenticated users
*/

-- Recreate driver_vehicles table with proper structure
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

-- Create function to manage primary vehicle assignments
CREATE OR REPLACE FUNCTION manage_primary_vehicle()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_primary THEN
    -- Set all other vehicles for this driver as non-primary
    UPDATE driver_vehicles
    SET is_primary = false
    WHERE driver_id = NEW.driver_id
    AND id != COALESCE(NEW.id, -1);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to manage primary vehicle assignments
DROP TRIGGER IF EXISTS manage_primary_vehicle_trigger ON driver_vehicles;
CREATE TRIGGER manage_primary_vehicle_trigger
BEFORE INSERT OR UPDATE ON driver_vehicles
FOR EACH ROW
EXECUTE FUNCTION manage_primary_vehicle();