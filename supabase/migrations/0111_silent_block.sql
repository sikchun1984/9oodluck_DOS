-- Create function to copy default receipt template
CREATE OR REPLACE FUNCTION copy_default_receipt_template()
RETURNS trigger AS $$
BEGIN
  -- Copy template from admin user if exists
  INSERT INTO receipt_templates (
    driver_id,
    company_name_zh,
    company_name,
    address,
    phone,
    logo,
    license_image,
    footer,
    footer_image
  )
  SELECT 
    NEW.id,
    company_name_zh,
    company_name,
    address,
    phone,
    logo,
    license_image,
    footer,
    footer_image
  FROM receipt_templates
  WHERE driver_id IN (
    SELECT id FROM drivers WHERE role = 'admin'
  )
  LIMIT 1;

  -- If no admin template exists, create default
  IF NOT FOUND THEN
    INSERT INTO receipt_templates (
      driver_id,
      company_name_zh,
      company_name,
      address,
      phone
    ) VALUES (
      NEW.id,
      '旅行社',
      'Travel Agency',
      'Macau',
      '+853 0000 0000'
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create function to copy default vehicle types
CREATE OR REPLACE FUNCTION copy_default_vehicle_types()
RETURNS trigger AS $$
BEGIN
  -- Copy types from admin user if exists
  INSERT INTO vehicle_types (driver_id, name)
  SELECT 
    NEW.id,
    name
  FROM vehicle_types
  WHERE driver_id IN (
    SELECT id FROM drivers WHERE role = 'admin'
  );

  -- If no admin types exist, create defaults
  IF NOT FOUND THEN
    INSERT INTO vehicle_types (driver_id, name)
    VALUES
      (NEW.id, 'Sedan'),
      (NEW.id, 'SUV'),
      (NEW.id, 'Van'),
      (NEW.id, 'Bus');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
DROP TRIGGER IF EXISTS copy_receipt_template_trigger ON drivers;
CREATE TRIGGER copy_receipt_template_trigger
AFTER INSERT ON drivers
FOR EACH ROW
EXECUTE FUNCTION copy_default_receipt_template();

DROP TRIGGER IF EXISTS copy_vehicle_types_trigger ON drivers;
CREATE TRIGGER copy_vehicle_types_trigger
AFTER INSERT ON drivers
FOR EACH ROW
EXECUTE FUNCTION copy_default_vehicle_types();

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';