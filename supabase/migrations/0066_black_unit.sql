-- Drop email column from drivers table
ALTER TABLE drivers DROP COLUMN IF EXISTS email;

-- Make sure phone is nullable and has proper validation
ALTER TABLE drivers 
ALTER COLUMN phone DROP NOT NULL;

-- Add phone validation if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'drivers_phone_check'
  ) THEN
    ALTER TABLE drivers
    ADD CONSTRAINT drivers_phone_check 
    CHECK (phone IS NULL OR phone ~ '^[0-9+\-\s]+$');
  END IF;
END $$;

-- Force schema cache refresh
SELECT pg_notify('pgrst', 'reload schema');