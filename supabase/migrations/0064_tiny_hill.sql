-- Drop existing phone constraint if it exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'drivers_phone_check'
  ) THEN
    ALTER TABLE drivers DROP CONSTRAINT drivers_phone_check;
  END IF;
END $$;

-- Make phone column nullable and add validation
ALTER TABLE drivers 
ALTER COLUMN phone DROP NOT NULL;

-- Add new phone validation
ALTER TABLE drivers
ADD CONSTRAINT drivers_phone_check 
CHECK (phone IS NULL OR phone ~ '^[0-9+\-\s]+$');