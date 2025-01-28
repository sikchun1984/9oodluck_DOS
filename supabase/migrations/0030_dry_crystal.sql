/*
  # Add admin user

  1. Changes
    - Updates the specified user's role to admin
    - Creates driver profile if not exists
*/

-- Function to set admin user
CREATE OR REPLACE FUNCTION set_admin_user(p_email text)
RETURNS void AS $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = p_email;

  -- Update user metadata to include admin role
  IF v_user_id IS NOT NULL THEN
    -- Update user metadata
    UPDATE auth.users
    SET raw_user_meta_data = jsonb_set(
      COALESCE(raw_user_meta_data, '{}'::jsonb),
      '{role}',
      '"admin"'
    )
    WHERE id = v_user_id;

    -- Create or update driver profile
    INSERT INTO drivers (id, full_name, email, license_number, role)
    VALUES (
      v_user_id,
      'Admin User',
      p_email,
      'ADMIN002',
      'admin'
    )
    ON CONFLICT (id) DO UPDATE
    SET role = 'admin'
    WHERE drivers.id = v_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Set admin user
SELECT set_admin_user('9oodluckgroup@gmail.com');

-- Drop function after use
DROP FUNCTION set_admin_user(text);