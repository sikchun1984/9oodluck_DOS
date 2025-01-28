-- Add license image column to receipt_templates
ALTER TABLE receipt_templates
ADD COLUMN license_image text;

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';