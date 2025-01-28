-- Ensure we don't have duplicate templates per driver
WITH latest_templates AS (
  SELECT DISTINCT ON (driver_id)
    id
  FROM receipt_templates
  ORDER BY driver_id, COALESCE(updated_at, created_at) DESC
)
-- Delete all templates except the latest one per driver
DELETE FROM receipt_templates
WHERE id NOT IN (SELECT id FROM latest_templates);

-- Drop the constraint if it exists and recreate it
DO $$ 
BEGIN
  -- Drop the constraint if it exists
  IF EXISTS (
    SELECT 1 
    FROM information_schema.table_constraints 
    WHERE constraint_name = 'receipt_templates_driver_id_key'
    AND table_name = 'receipt_templates'
  ) THEN
    ALTER TABLE receipt_templates 
    DROP CONSTRAINT receipt_templates_driver_id_key;
  END IF;

  -- Add the unique constraint
  ALTER TABLE receipt_templates
  ADD CONSTRAINT receipt_templates_driver_id_key UNIQUE (driver_id);
EXCEPTION
  WHEN others THEN
    -- If anything fails, log it but don't stop the migration
    RAISE NOTICE 'Failed to modify constraint: %', SQLERRM;
END $$;