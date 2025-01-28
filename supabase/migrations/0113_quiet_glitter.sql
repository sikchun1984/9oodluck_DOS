-- First ensure admin user exists and has correct settings
DO $$
DECLARE
  v_admin_id uuid;
BEGIN
  -- Get admin user ID
  SELECT id INTO v_admin_id
  FROM auth.users
  WHERE email = '9oodluckgroup@gmail.com';

  IF v_admin_id IS NULL THEN
    RAISE EXCEPTION 'Admin user not found';
  END IF;

  -- Ensure admin has driver profile
  INSERT INTO drivers (id, email, full_name, role, license_number)
  VALUES (
    v_admin_id,
    '9oodluckgroup@gmail.com',
    'System Admin',
    'admin',
    'ADMIN-' || encode(sha256(v_admin_id::text::bytea), 'hex')
  )
  ON CONFLICT (id) DO UPDATE
  SET role = 'admin';

  -- Create or update default receipt template
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
    v_admin_id,
    company_name_zh,
    company_name,
    address,
    phone,
    logo,
    license_image,
    footer,
    footer_image
  FROM receipt_templates
  WHERE driver_id = v_admin_id
  ON CONFLICT (driver_id) DO UPDATE
  SET
    company_name_zh = EXCLUDED.company_name_zh,
    company_name = EXCLUDED.company_name,
    address = EXCLUDED.address,
    phone = EXCLUDED.phone,
    logo = EXCLUDED.logo,
    license_image = EXCLUDED.license_image,
    footer = EXCLUDED.footer,
    footer_image = EXCLUDED.footer_image;

  -- Create or update default vehicle types
  INSERT INTO vehicle_types (driver_id, name)
  VALUES
    (v_admin_id, 'Sedan'),
    (v_admin_id, 'SUV'),
    (v_admin_id, 'Van'),
    (v_admin_id, 'Bus')
  ON CONFLICT (driver_id, name) DO NOTHING;
END $$;

-- Update copy_default_receipt_template function to preserve images
CREATE OR REPLACE FUNCTION copy_default_receipt_template()
RETURNS trigger AS $$
BEGIN
  -- Copy template from admin user including images
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
    SELECT id FROM drivers 
    WHERE email = '9oodluckgroup@gmail.com'
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

-- Update copy_default_vehicle_types function
CREATE OR REPLACE FUNCTION copy_default_vehicle_types()
RETURNS trigger AS $$
BEGIN
  -- Copy types from admin user
  INSERT INTO vehicle_types (driver_id, name)
  SELECT 
    NEW.id,
    name
  FROM vehicle_types
  WHERE driver_id IN (
    SELECT id FROM drivers 
    WHERE email = '9oodluckgroup@gmail.com'
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

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';