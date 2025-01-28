/*
  # Update schema for driver information and vehicle details

  1. Changes
    - Add drivers table for driver information
    - Update orders table structure
      - Remove price column
      - Add license_plate column with default value
    - Add RLS policies for drivers table

  2. Tables
    - New `drivers` table
      - `id` (uuid, references auth.users)
      - `full_name` (text)
      - `phone` (text)
      - `license_number` (text)
      - `created_at` (timestamptz)
*/

-- Add driver information
CREATE TABLE IF NOT EXISTS drivers (
  id uuid PRIMARY KEY REFERENCES auth.users(id),
  full_name text NOT NULL,
  phone text NOT NULL,
  license_number text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Update orders table
-- First add the new column as nullable
ALTER TABLE orders ADD COLUMN IF NOT EXISTS license_plate text;

-- Then remove the price column
ALTER TABLE orders DROP COLUMN IF EXISTS price;

-- Update existing rows with a default value
UPDATE orders SET license_plate = 'PENDING' WHERE license_plate IS NULL;

-- Finally make the column NOT NULL
ALTER TABLE orders ALTER COLUMN license_plate SET NOT NULL;

-- Enable RLS on drivers table
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;

-- Policies for drivers table
CREATE POLICY "Drivers can read own data"
  ON drivers
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Drivers can update own data"
  ON drivers
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);