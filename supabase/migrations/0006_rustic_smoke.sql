/*
  # Update storage bucket policies

  1. Changes
    - Add UPDATE policy for logo uploads
    - Modify existing INSERT policy to handle file replacements
    - Ensure proper access control for file operations

  2. Security
    - Maintain RLS for storage bucket
    - Restrict file access to authenticated users
    - Allow drivers to manage their own logos
*/

-- Drop existing policies
DO $$
BEGIN
  DROP POLICY IF EXISTS "Drivers can upload own logos" ON storage.objects;
  DROP POLICY IF EXISTS "Anyone can view logos" ON storage.objects;
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
  TO authenticated
  USING (bucket_id = 'receipt-logos');