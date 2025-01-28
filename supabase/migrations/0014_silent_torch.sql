CREATE OR REPLACE FUNCTION set_primary_vehicle(p_driver_id uuid, p_vehicle_id uuid)
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