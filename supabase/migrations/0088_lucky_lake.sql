-- First check if there are other admin users
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

  -- Check if there are other admin users
  SELECT EXISTS (
    SELECT 1 
    FROM user_roles 
    WHERE role = 'admin' 
    AND user_id != v_user_id
  ) INTO v_has_other_admins;

  -- If no other admins exist, we need to keep this user as admin
  IF NOT v_has_other_admins AND EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_id = v_user_id 
    AND role = 'admin'
  ) THEN
    -- Keep only admin role for this user
    DELETE FROM user_roles 
    WHERE user_id = v_user_id 
    AND role != 'admin';
  ELSE
    -- Safe to reset roles completely
    DELETE FROM user_roles 
    WHERE user_id = v_user_id;
    
    -- Add admin role
    INSERT INTO user_roles (user_id, role)
    VALUES (v_user_id, 'admin');
  END IF;

  -- Update user metadata
  UPDATE auth.users
  SET raw_user_meta_data = jsonb_build_object(
    'role', 'admin'
  )
  WHERE id = v_user_id;

  RAISE NOTICE 'Successfully set admin-only role for user: %', '9oodluckgroup@gmail.com';
END $$;