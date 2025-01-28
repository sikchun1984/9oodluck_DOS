/*
  # Fix logo upload functionality

  1. Changes
    - Update storage bucket policies to allow all operations
    - Add proper file handling policies
    - Enable public access for logos

  2. Security
    - Maintain RLS for storage bucket
    - Restrict file operations to authenticated users
    - Allow public access for viewing logos
*/

-- Drop existing policies
DO $$
BEGIN
  DROP POLICY IF EXISTS "Drivers can manage own logos" ON storage.objects;
  DROP POLICY IF EXISTS "Public logo access" ON storage.objects;
END $$;

-- Create comprehensive policies for logo management
CREATE POLICY "Drivers can manage own logos"
  ON storage.objects
  FOR ALL
  TO authenticated
  USING (
    bucket_id = 'receipt-logos' AND
    (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id = 'receipt-logos' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

-- Allow public access to view logos
CREATE POLICY "Public logo access"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'receipt-logos');

-- Update bucket public access
UPDATE storage.buckets
SET public = true
WHERE id = 'receipt-logos';