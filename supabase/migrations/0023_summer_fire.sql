-- Drop existing table and recreate with simplified structure
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

-- Create policy for authenticated users
CREATE POLICY "Drivers can manage their vehicle assignments"
ON driver_vehicles
FOR ALL
TO authenticated
USING (auth.uid() = driver_id)
WITH CHECK (auth.uid() = driver_id);

-- Create indexes
CREATE INDEX idx_driver_vehicles_driver_id ON driver_vehicles(driver_id);
CREATE INDEX idx_driver_vehicles_vehicle_id ON driver_vehicles(vehicle_id);
CREATE INDEX idx_driver_vehicles_is_primary ON driver_vehicles(driver_id, is_primary);

-- Create function to handle primary vehicle logic
CREATE OR REPLACE FUNCTION handle_primary_vehicle(p_driver_id uuid, p_vehicle_id uuid)
RETURNS void AS $$
BEGIN
  -- First, set all vehicles for this driver as non-primary
  UPDATE driver_vehicles
  SET is_primary = false
  WHERE driver_id = p_driver_id;
  
  -- Then set the specified vehicle as primary
  UPDATE driver_vehicles
  SET is_primary = true
  WHERE driver_id = p_driver_id AND vehicle_id = p_vehicle_id;
END;
$$ LANGUAGE plpgsql;