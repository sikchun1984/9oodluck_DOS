/*
  # Clean up duplicate receipt templates

  This migration ensures each driver has at most one receipt template by:
  1. Creating a temporary table to store the latest template for each driver
  2. Deleting all existing templates
  3. Reinserting only the latest template for each driver
  4. Adding a unique constraint to prevent future duplicates
*/

-- Create temporary table to store latest templates
CREATE TEMP TABLE latest_templates AS
SELECT DISTINCT ON (driver_id)
  id,
  driver_id,
  company_name,
  logo,
  address,
  phone,
  footer,
  footer_image,
  created_at,
  updated_at
FROM receipt_templates
ORDER BY driver_id, COALESCE(updated_at, created_at) DESC;

-- Delete all existing templates except those in latest_templates
DELETE FROM receipt_templates
WHERE id NOT IN (SELECT id FROM latest_templates);

-- Add unique constraint to prevent future duplicates
ALTER TABLE receipt_templates
ADD CONSTRAINT receipt_templates_driver_id_key UNIQUE (driver_id);