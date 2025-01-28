/*
  # Add receipt templates

  1. New Tables
    - `receipt_templates`
      - `id` (uuid, primary key)
      - `driver_id` (uuid, references auth.users)
      - `company_name` (text)
      - `logo` (text, nullable)
      - `address` (text)
      - `phone` (text)
      - `footer` (text)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Storage
    - Create bucket for receipt logos

  3. Security
    - Enable RLS on receipt_templates table
    - Add policies for CRUD operations
*/

-- Create receipt_templates table
CREATE TABLE receipt_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id uuid REFERENCES auth.users(id) NOT NULL,
  company_name text NOT NULL,
  logo text,
  address text NOT NULL,
  phone text NOT NULL,
  footer text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE receipt_templates ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Drivers can manage own templates"
  ON receipt_templates
  FOR ALL
  TO authenticated
  USING (auth.uid() = driver_id)
  WITH CHECK (auth.uid() = driver_id);

-- Create storage bucket for logos
INSERT INTO storage.buckets (id, name)
VALUES ('receipt-logos', 'receipt-logos')
ON CONFLICT DO NOTHING;

-- Enable RLS on storage bucket
CREATE POLICY "Drivers can upload own logos"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'receipt-logos' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Anyone can view logos"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (bucket_id = 'receipt-logos');