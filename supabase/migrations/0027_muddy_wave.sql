/*
  # Add user roles and default admin

  1. Changes
    - Add role column to drivers table
    - Create default admin user
    - Add role-based policies
*/

-- Add role column to drivers table
ALTER TABLE drivers 
ADD COLUMN role text NOT NULL DEFAULT 'driver' 
CHECK (role IN ('admin', 'driver', 'dispatcher'));

-- Create function to create default admin
CREATE OR REPLACE FUNCTION create_default_admin()
RETURNS void AS $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Create admin user if not exists
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    phone,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    phone_confirmed_at,
    confirmation_sent_at
  )
  VALUES (
    gen_random_uuid(),  -- Generate UUID for id
    '00000000-0000-0000-0000-000000000000',  -- Default instance_id
    NULL,  -- No email
    crypt('999999999', gen_salt('bf')),  -- Password
    '+853999999999',  -- Phone
    '{"provider":"phone","providers":["phone"]}',
    '{"role":"admin"}',
    now(),
    now(),
    now(),  -- Phone confirmed
    now()   -- Confirmation sent
  )
  ON CONFLICT (phone) DO NOTHING
  RETURNING id INTO v_user_id;

  -- Create admin driver profile if user was created
  IF v_user_id IS NOT NULL THEN
    INSERT INTO drivers (id, full_name, phone, role, license_number)
    VALUES (v_user_id, 'System Admin', '+853999999999', 'admin', 'ADMIN001');
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Execute function to create admin
SELECT create_default_admin();

-- Drop function after use
DROP FUNCTION create_default_admin();

-- Update RLS policies for role-based access
CREATE POLICY "Admins have full access"
ON drivers
FOR ALL
TO authenticated
USING (
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'admin'
)
WITH CHECK (
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'admin'
);

CREATE POLICY "Dispatchers can view all drivers"
ON drivers
FOR SELECT
TO authenticated
USING (
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'dispatcher'
);