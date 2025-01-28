import { supabase } from '../lib/supabase';
import { ReceiptTemplate } from '../types';

export const receiptService = {
  async getTemplate() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    const { data, error } = await supabase
      .from('receipt_templates')
      .select('*')
      .eq('driver_id', user.id)
      .maybeSingle();

    if (error) throw error;
    return data;
  },

  async saveTemplate(template: ReceiptTemplate) {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    const { error } = await supabase
      .from('receipt_templates')
      .upsert({
        driver_id: user.id,
        ...template,
        updated_at: new Date().toISOString()
      });

    if (error) throw error;
  },

  async uploadImage(file: File, type: 'logo' | 'footer') {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    // Create a unique filename with timestamp to prevent caching issues
    const timestamp = new Date().getTime();
    const fileExt = file.name.split('.').pop();
    const filePath = `${user.id}/${type}-${timestamp}.${fileExt}`;

    // Upload the new file
    const { error: uploadError } = await supabase.storage
      .from('receipt-logos')
      .upload(filePath, file);

    if (uploadError) throw uploadError;

    // Get the public URL
    const { data: { publicUrl } } = supabase.storage
      .from('receipt-logos')
      .getPublicUrl(filePath);

    return publicUrl;
  }
};