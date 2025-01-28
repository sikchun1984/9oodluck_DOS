import { supabase } from '../lib/supabase';
import { Driver } from '../types/driver';
import { AppError } from '../utils/error';
import { retryFetch } from '../utils/api/retryFetch';

export const driverService = {
  async getDriverProfile() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new AppError('Not authenticated');
    
    // Add retry logic for role fetching
    const maxRetries = 3;
    let attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        const { data, error } = await supabase
          .from('drivers')
          .select('*')
          .eq('id', user.id)
          .single();

        if (error) {
          if (error.code === 'PGRST116') {
            return null;
          }
          throw new AppError('Failed to load driver profile', {
            code: error.code,
            details: error.details,
            hint: error.hint
          });
        }

        return data;
      } catch (error) {
        attempt++;
        if (attempt === maxRetries) throw error;
        await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
      }
    }
  },

  async getDriverById(id: string) {
    return await retryFetch(async () => {
      const { data, error } = await supabase
        .from('drivers')
        .select('*')
        .eq('id', id)
        .single();

      if (error) {
        if (error.code === 'PGRST116') {
          return null;
        }
        throw new AppError('Failed to load driver', {
          code: error.code,
          details: error.details,
          hint: error.hint
        });
      }

      return data;
    });
  },

  async updateDriverProfile(driverData: Partial<Driver>) {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new AppError('Not authenticated');
    
    // Validate phone number format if provided
    if (driverData.phone && !/^[0-9+\-\s]+$/.test(driverData.phone)) {
      throw new AppError('Invalid phone number format');
    }

    return await retryFetch(async () => {
      const { data, error } = await supabase
        .from('drivers')
        .upsert({
          id: user.id,
          email: user.email!, // Use email from auth
          ...driverData
        })
        .select()
        .single();

      if (error) {
        throw new AppError('Failed to update driver profile', {
          code: error.code,
          details: error.details,
          hint: error.hint
        });
      }

      return data;
    });
  }
};