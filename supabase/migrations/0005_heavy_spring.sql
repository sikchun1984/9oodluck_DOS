/*
  # Update Receipt Templates and Storage Policies

  This migration ensures storage policies are properly set up for receipt logos
  and adds any missing policies for existing tables.
*/

-- Create storage bucket for logos if it doesn't exist
DO $$
BEGIN
  INSERT INTO storage.buckets (id, name)
  VALUES ('receipt-logos', 'receipt-logos')
  ON CONFLICT DO NOTHING;
END $$;

-- Enable RLS on storage bucket and add policies
DO $$
BEGIN
  -- Drop existing policies if they exist
  DROP POLICY IF EXISTS "Drivers can upload own logos" ON storage.objects;
  DROP POLICY IF EXISTS "Anyone can view logos" ON storage.objects;

  -- Create new policies
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
END $$;