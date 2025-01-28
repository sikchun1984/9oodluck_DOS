/*
  # Fix Drivers Table RLS Policies

  1. Changes
    - Add insert policy for drivers table
    - Update existing policies to be more permissive for profile creation
    - Ensure drivers can manage their own profile

  2. Security
    - Enable RLS on drivers table
    - Add policies for CRUD operations
    - Restrict access to own data only
*/

-- First ensure RLS is enabled
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Drivers can read own data" ON drivers;
DROP POLICY IF EXISTS "Drivers can update own data" ON drivers;

-- Create comprehensive policies for driver profile management
CREATE POLICY "Drivers can manage own profile"
  ON drivers
  FOR ALL
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Allow drivers to insert their own profile
CREATE POLICY "Drivers can create profile"
  ON drivers
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);