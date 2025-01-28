/*
  # Fix Vehicle Assignment Trigger

  1. Changes
    - Fix the COALESCE comparison in manage_primary_vehicle function
    - Add proper type handling for UUID comparison

  2. Security
    - Maintain existing RLS policies
*/

-- Drop existing function and recreate with fixed logic
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