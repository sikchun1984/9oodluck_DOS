-- Remove test account data
DO $$
BEGIN
  -- First remove from drivers table
  DELETE FROM drivers 
  WHERE phone = '+853999999999';

  -- Then remove from auth.users table
  DELETE FROM auth.users 
  WHERE phone = '+853999999999';
END $$;

-- Force schema cache refresh
SELECT pg_notify('pgrst', 'reload schema');