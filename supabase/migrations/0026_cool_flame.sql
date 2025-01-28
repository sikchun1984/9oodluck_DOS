/*
  # Add vehicle types management
  
  1. New Tables
    - `vehicle_types`
      - `id` (uuid, primary key)
      - `name` (text, unique)
      - `driver_id` (uuid, references auth.users)
      - `created_at` (timestamp)
  
  2. Security
    - Enable RLS on vehicle_types table
    - Add policies for driver access
*/

-- Create vehicle types table
CREATE TABLE vehicle_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  driver_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(name, driver_id)
);

-- Enable RLS
ALTER TABLE vehicle_types ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Drivers can manage their vehicle types"
ON vehicle_types
FOR ALL
TO authenticated
USING (auth.uid() = driver_id)
WITH CHECK (auth.uid() = driver_id);

-- Insert default vehicle types for existing vehicles
INSERT INTO vehicle_types (name, driver_id)
SELECT DISTINCT v.type, v.driver_id
FROM vehicles v
ON CONFLICT DO NOTHING;