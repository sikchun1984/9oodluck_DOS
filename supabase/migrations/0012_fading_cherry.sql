-- Enable RLS on receipt_templates
ALTER TABLE receipt_templates ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Drivers can manage own templates" ON receipt_templates;

-- Create comprehensive policies for receipt template management
CREATE POLICY "Drivers can manage own templates"
  ON receipt_templates
  FOR ALL
  TO authenticated
  USING (auth.uid() = driver_id)
  WITH CHECK (auth.uid() = driver_id);

-- Allow drivers to insert their own template
CREATE POLICY "Drivers can create template"
  ON receipt_templates
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = driver_id);