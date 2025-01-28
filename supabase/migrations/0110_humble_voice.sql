-- Update storage bucket settings
UPDATE storage.buckets
SET public = true
WHERE id IN ('receipt-logos', 'license-images');

-- Drop existing policies
DROP POLICY IF EXISTS "Users can upload own license images" ON storage.objects;
DROP POLICY IF EXISTS "Users can view license images" ON storage.objects;

-- Create comprehensive policies for both buckets
CREATE POLICY "manage_own_images"
ON storage.objects
FOR ALL
TO authenticated
USING (
  (bucket_id IN ('receipt-logos', 'license-images'))
  AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  (bucket_id IN ('receipt-logos', 'license-images'))
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow public access to view images
CREATE POLICY "public_image_access"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id IN ('receipt-logos', 'license-images'));

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';