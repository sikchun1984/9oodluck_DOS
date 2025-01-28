import { supabase } from '../lib/supabase';
import { AppError } from '../utils/error';

import { Driver } from '../types/driver';

export const userManagementService = {
  async getUsers(): Promise<Driver[]> {
    const { data, error } = await supabase
      .from('drivers')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      throw new AppError('Failed to load users', {
        code: error.code,
        details: error.details,
        hint: error.hint
      });
    }

    return data || [];
  },

  async updateUserRole(userId: string, role: string): Promise<void> {
    const { error } = await supabase
      .from('drivers')
      .update({ role })
      .eq('id', userId);

    if (error) {
      throw new AppError('Failed to update user role', {
        code: error.code,
        details: error.details,
        hint: error.hint
      });
    }
  },

  async deleteUser(userId: string): Promise<void> {
    const { error } = await supabase
      .from('drivers')
      .delete()
      .eq('id', userId);

    if (error) {
      throw new AppError('Failed to delete user', {
        code: error.code,
        details: error.details,
        hint: error.hint
      });
    }
  }
};