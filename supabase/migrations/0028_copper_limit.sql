/*
  # Add role-based authentication with phone numbers
  
  1. Changes
    - Add role column to drivers table
    - Create default admin user with phone number
    - Add role-based access policies
    
  2. Security
    - Enable RLS for drivers table
    - Add policies for admin and dispatcher access
*/

-- Add role column to drivers table if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'drivers' AND column_name = 'role'
  ) THEN
    ALTER TABLE drivers 
    ADD COLUMN role text NOT NULL DEFAULT 'driver' 
    CHECK (role IN ('admin', 'driver', 'dispatcher'));
  END IF;
END $$;

-- Create default admin user if not exists
DO $$
DECLARE
  v_user_id uuid;
BEGIN
  -- First check if admin user already exists
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE phone = '+853999999999';
  
  -- Create admin user if not exists
  IF v_user_id IS NULL THEN
    INSERT INTO auth.users (
      id,
      instance_id,
      phone,
      encrypted_password,
      email_confirmed_at,
      phone_confirmed_at,
      created_at,
      updated_at,
      raw_app_meta_data,
      raw_user_meta_data,
      is_super_admin,
      role
    )
    VALUES (
      gen_random_uuid(),
      '00000000-0000-0000-0000-000000000000',
      '+853999999999',
      crypt('999999999', gen_salt('bf')),
      now(),
      now(),
      now(),
      now(),
      '{"provider":"phone","providers":["phone"]}',
      '{"role":"admin"}',
      false,
      'authenticated'
    )
    RETURNING id INTO v_user_id;

    -- Create admin driver profile
    INSERT INTO drivers (
      id,
      full_name,
      phone,
      license_number,
      role
    )
    VALUES (
      v_user_id,
      'System Admin',
      '+853999999999',
      'ADMIN001',
      'admin'
    );
  END IF;
END $$;

-- Update RLS policies
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins have full access" ON drivers;
DROP POLICY IF EXISTS "Dispatchers can view all drivers" ON drivers;
DROP POLICY IF EXISTS "Drivers can manage own profile" ON drivers;

-- Create new policies
CREATE POLICY "Admins have full access"
ON drivers FOR ALL
TO authenticated
USING (
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'admin'
)
WITH CHECK (
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'admin'
);

CREATE POLICY "Dispatchers can view all drivers"
ON drivers FOR SELECT
TO authenticated
USING (
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'dispatcher'
);

CREATE POLICY "Drivers can manage own profile"
ON drivers FOR ALL
TO authenticated
USING (
  auth.uid() = id AND 
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'driver'
)
WITH CHECK (
  auth.uid() = id AND 
  (SELECT role FROM drivers WHERE id = auth.uid()) = 'driver'
);