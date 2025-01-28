import { supabase } from '../../lib/supabase';
import { ReceiptTemplate } from '../../types';
import { AppError } from '../../utils/error';
import { getAuthenticatedUser } from '../auth/userService';

export const DEFAULT_TEMPLATE: ReceiptTemplate = {
  company_name: 'Travel Agency',
  address: '',
  phone: '',
};

export async function saveTemplate(template: ReceiptTemplate): Promise<ReceiptTemplate> {
  try {
    const user = await getAuthenticatedUser();

    const { data, error } = await supabase
      .from('receipt_templates')
      .upsert({
        driver_id: user.id,
        ...template,
        updated_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) {
      throw new AppError('Failed to save template', {
        code: error.code,
        details: error.details,
        hint: error.hint
      });
    }

    return data || template;
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw AppError.fromError(error);
  }
}

export async function getTemplate(): Promise<ReceiptTemplate> {
  try {
    const user = await getAuthenticatedUser();
    const { data, error } = await supabase
      .from('receipt_templates')
      .select('*')
      .eq('driver_id', user.id)
      .maybeSingle();

    if (error && !error.message.includes('PGRST116')) {
      throw new AppError('Failed to load template', {
        code: error.code,
        details: error.details,
        hint: error.hint
      });
    }

    return data || DEFAULT_TEMPLATE;
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw AppError.fromError(error);
  }
}