-- Create storage bucket for license images if it doesn't exist
INSERT INTO storage.buckets (id, name)
VALUES ('license-images', 'license-images')
ON CONFLICT DO NOTHING;

-- Enable RLS on storage bucket
CREATE POLICY "Users can upload own license images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'license-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view license images"
ON storage.objects
FOR SELECT
TO authenticated
USING (bucket_id = 'license-images');

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';