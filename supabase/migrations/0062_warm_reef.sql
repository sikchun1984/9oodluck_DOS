-- Add phone column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'drivers' 
    AND column_name = 'phone'
  ) THEN
    ALTER TABLE drivers ADD COLUMN phone text;
  END IF;
END $$;

-- Add phone constraint if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.table_constraints
    WHERE constraint_name = 'drivers_phone_check'
  ) THEN
    ALTER TABLE drivers
    ADD CONSTRAINT drivers_phone_check CHECK (phone ~ '^[0-9+\-\s]+$');
  END IF;
END $$;

-- Add index on phone if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_drivers_phone ON drivers(phone);

-- Force schema cache refresh
SELECT pg_notify('pgrst', 'reload schema');