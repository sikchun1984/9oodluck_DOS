-- First ensure the user exists in drivers table
DO $$
DECLARE
  v_user_id uuid;
  v_has_other_admins boolean;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = '9oodluckgroup@gmail.com';

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  -- Ensure driver profile exists
  INSERT INTO drivers (id, email, full_name, license_number)
  VALUES (
    v_user_id,
    '9oodluckgroup@gmail.com',
    'System Admin',
    'ADMIN-' || encode(sha256(v_user_id::text::bytea), 'hex')
  )
  ON CONFLICT (id) DO UPDATE
  SET 
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name;

  -- Check if user already has admin role
  IF NOT EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_id = v_user_id AND role = 'admin'
  ) THEN
    -- Add admin role without removing existing roles
    INSERT INTO user_roles (user_id, role)
    VALUES (v_user_id, 'admin')
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;

  -- Update user metadata
  UPDATE auth.users
  SET raw_user_meta_data = jsonb_build_object(
    'role', 'admin'
  )
  WHERE id = v_user_id;

  RAISE NOTICE 'Successfully set admin role for user: %', '9oodluckgroup@gmail.com';
END $$;