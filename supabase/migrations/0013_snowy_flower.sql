/*
  # Add Vehicle-Driver Relationship

  1. Changes
    - Add driver_vehicles junction table for many-to-many relationship
    - Add RLS policies for driver_vehicles table
    - Add foreign key constraints

  2. Security
    - Enable RLS on driver_vehicles table
    - Add policies for authenticated drivers
*/

-- Create junction table for driver-vehicle relationships
CREATE TABLE driver_vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  vehicle_id uuid REFERENCES vehicles(id) ON DELETE CASCADE,
  assigned_at timestamptz DEFAULT now(),
  is_primary boolean DEFAULT false,
  UNIQUE(driver_id, vehicle_id)
);

-- Enable RLS
ALTER TABLE driver_vehicles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Drivers can manage their vehicle assignments"
  ON driver_vehicles
  FOR ALL
  TO authenticated
  USING (auth.uid() = driver_id)
  WITH CHECK (auth.uid() = driver_id);

-- Create index for better query performance
CREATE INDEX idx_driver_vehicles_driver_id ON driver_vehicles(driver_id);
CREATE INDEX idx_driver_vehicles_vehicle_id ON driver_vehicles(vehicle_id);