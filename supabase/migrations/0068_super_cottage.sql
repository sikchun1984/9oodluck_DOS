-- Remove test account data safely
DO $$
BEGIN
  -- First remove from drivers table to handle foreign key constraint
  DELETE FROM drivers 
  WHERE id IN (
    SELECT id FROM auth.users 
    WHERE email = '+853999999999@example.com'
  );

  -- Then remove from auth.users table
  DELETE FROM auth.users 
  WHERE email = '+853999999999@example.com';
END $$;

-- Force schema cache refresh
SELECT pg_notify('pgrst', 'reload schema');