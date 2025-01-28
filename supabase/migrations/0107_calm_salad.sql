-- Add Chinese company name column to receipt_templates
ALTER TABLE receipt_templates
ADD COLUMN company_name_zh text;

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';