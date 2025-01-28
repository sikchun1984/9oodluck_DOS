/*
  # Add vehicles management

  1. New Tables
    - `vehicles`
      - `id` (uuid, primary key)
      - `plate_number` (text, unique)
      - `model` (text)
      - `type` (text)
      - `capacity` (integer)
      - `driver_id` (uuid, references drivers)
      - `status` (text) - active/inactive
      - `created_at` (timestamptz)

  2. Changes
    - Add vehicle_id to orders table
    - Remove license_plate from orders

  3. Security
    - Enable RLS on vehicles table
    - Add policies for CRUD operations
*/

-- Create vehicles table
CREATE TABLE vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plate_number text UNIQUE NOT NULL,
  model text NOT NULL,
  type text NOT NULL,
  capacity integer NOT NULL,
  driver_id uuid REFERENCES drivers(id) NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at timestamptz DEFAULT now()
);

-- Add vehicle_id to orders
ALTER TABLE orders 
ADD COLUMN vehicle_id uuid REFERENCES vehicles(id);

-- Update existing orders with a default vehicle (if any exist)
DO $$
DECLARE
  v_id uuid;
BEGIN
  -- Get or create a default vehicle for existing orders
  INSERT INTO vehicles (plate_number, model, type, capacity, driver_id)
  SELECT 
    o.license_plate,
    'Default Model',
    o.vehicle_type,
    4,
    o.driver_id
  FROM orders o
  WHERE o.license_plate IS NOT NULL
  GROUP BY o.license_plate, o.vehicle_type, o.driver_id
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_id;

  -- Update orders with the vehicle_id
  IF v_id IS NOT NULL THEN
    UPDATE orders o
    SET vehicle_id = v.id
    FROM vehicles v
    WHERE v.plate_number = o.license_plate;
  END IF;
END $$;

-- Make vehicle_id required
ALTER TABLE orders
ALTER COLUMN vehicle_id SET NOT NULL;

-- Remove license_plate from orders
ALTER TABLE orders
DROP COLUMN license_plate;

-- Enable RLS on vehicles
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;

-- Policies for vehicles table
CREATE POLICY "Drivers can read own vehicles"
  ON vehicles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = driver_id);

CREATE POLICY "Drivers can insert own vehicles"
  ON vehicles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = driver_id);

CREATE POLICY "Drivers can update own vehicles"
  ON vehicles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = driver_id)
  WITH CHECK (auth.uid() = driver_id);

CREATE POLICY "Drivers can delete own vehicles"
  ON vehicles
  FOR DELETE
  TO authenticated
  USING (auth.uid() = driver_id);