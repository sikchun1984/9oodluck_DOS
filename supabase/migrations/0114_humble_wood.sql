-- Delete user and related data
DO $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Get user ID
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = 'sikchun1984@gmail.com';

  IF v_user_id IS NULL THEN
    RAISE NOTICE 'User not found';
    RETURN;
  END IF;

  -- Delete from drivers (this will cascade to related tables)
  DELETE FROM drivers
  WHERE id = v_user_id;

  -- Delete from auth.users
  DELETE FROM auth.users
  WHERE id = v_user_id;

  -- Delete storage objects
  DELETE FROM storage.objects
  WHERE bucket_id IN ('receipt-logos', 'license-images')
  AND (storage.foldername(name))[1] = v_user_id::text;

  -- Delete receipt template
  DELETE FROM receipt_templates
  WHERE driver_id = v_user_id;

  -- Delete vehicle types
  DELETE FROM vehicle_types
  WHERE driver_id = v_user_id;

  -- Delete orders
  DELETE FROM orders
  WHERE driver_id = v_user_id;

  -- Delete vehicles
  DELETE FROM vehicles
  WHERE driver_id = v_user_id;

  RAISE NOTICE 'User and related data deleted successfully';
END $$;

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';