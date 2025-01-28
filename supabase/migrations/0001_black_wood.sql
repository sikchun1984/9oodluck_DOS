/*
  # Create orders table and security policies

  1. New Tables
    - `orders`
      - `id` (uuid, primary key)
      - `created_at` (timestamp)
      - `passenger_name` (text)
      - `contact` (text)
      - `origin` (text)
      - `destination` (text)
      - `date` (date)
      - `time` (time)
      - `vehicle_type` (text)
      - `price` (numeric)
      - `driver_id` (uuid, foreign key)
      - `status` (text)

  2. Security
    - Enable RLS on `orders` table
    - Add policies for authenticated drivers to:
      - Create orders
      - Read their own orders
      - Update their own orders
*/

CREATE TABLE orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  passenger_name text NOT NULL,
  contact text NOT NULL,
  origin text NOT NULL,
  destination text NOT NULL,
  date date NOT NULL,
  time time NOT NULL,
  vehicle_type text NOT NULL,
  price numeric NOT NULL,
  driver_id uuid REFERENCES auth.users(id),
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'completed', 'cancelled'))
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Allow drivers to create orders
CREATE POLICY "Drivers can create orders"
  ON orders
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = driver_id);

-- Allow drivers to read their own orders
CREATE POLICY "Drivers can read own orders"
  ON orders
  FOR SELECT
  TO authenticated
  USING (auth.uid() = driver_id);

-- Allow drivers to update their own orders
CREATE POLICY "Drivers can update own orders"
  ON orders
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = driver_id)
  WITH CHECK (auth.uid() = driver_id);