import { supabase } from '../../lib/supabase';
import { AppError } from '../../utils/error';
import { getAuthenticatedUser } from '../auth/userService';

export async function uploadImage(file: File, type: 'logo' | 'license' | 'footer'): Promise<string> {
  const user = await getAuthenticatedUser();
  
  const timestamp = new Date().getTime();
  const fileExt = file.name.split('.').pop();
  const filePath = `${user.id}/${type}-${timestamp}.${fileExt}`;

  // Choose bucket based on image type
  const bucket = type === 'license' ? 'license-images' : 'receipt-logos';

  const { error: uploadError } = await supabase.storage
    .from(bucket)
    .upload(filePath, file);

  if (uploadError) {
    throw new AppError(`Failed to upload image to ${bucket}: ${uploadError.message}`);
  }

  const { data: { publicUrl } } = supabase.storage
    .from(bucket)
    .getPublicUrl(filePath);

  return publicUrl;
}