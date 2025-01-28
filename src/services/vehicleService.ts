import { supabase } from '../lib/supabase';
import { Vehicle } from '../types';
import { AppError } from '../utils/error';
import { retryFetch } from '../utils/api/retryFetch';

export const vehicleService = {
  async getVehicles() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      throw new AppError('Not authenticated');
    }

    return await retryFetch(async () => {
      const { data, error } = await supabase
        .from('vehicles')
        .select('*')
        .eq('driver_id', user.id)
        .order('created_at', { ascending: false });

      if (error) {
        throw new AppError(error.message === 'JWT expired' 
          ? 'Your session has expired. Please sign in again.'
          : 'Failed to load vehicles', {
          code: error.code,
          details: error.details,
          hint: error.hint
        });
      }

      return data || [];
    });
  },

  async getActiveVehicles() {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      throw new AppError('Not authenticated');
    }

    return await retryFetch(async () => {
      const { data, error } = await supabase
        .from('vehicles')
        .select('*')
        .eq('driver_id', user.id)
        .eq('status', 'active')
        .order('created_at', { ascending: false });

      if (error) {
        throw new AppError('Failed to load vehicles', {
          code: error.code,
          details: error.details,
          hint: error.hint
        });
      }
    
      return data || [];
    });
  },

  async getVehicle(id: string): Promise<Vehicle> {
    return await retryFetch(async () => {
      const { data, error } = await supabase
        .from('vehicles')
        .select('*')
        .eq('id', id)
        .single();

      if (error) {
        throw new AppError('Failed to load vehicle', {
          code: error.code,
          details: error.details,
          hint: error.hint
        });
      }

      if (!data) {
        throw new AppError('Vehicle not found');
      }

      return data;
    });
  },

  async createVehicle(vehicleData: Omit<Vehicle, 'id' | 'created_at' | 'driver_id'>) {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      throw new AppError('Not authenticated');
    }

    return await retryFetch(async () => {
      const { data, error } = await supabase
        .from('vehicles')
        .insert({
          ...vehicleData,
          driver_id: user.id
        })
        .select()
        .single();

      if (error) {
        throw new AppError('Failed to create vehicle', {
          code: error.code,
          details: error.details || error.message,
          hint: error.hint
        });
      }

      return data;
    });
  },

  async updateVehicle(id: string, vehicleData: Partial<Vehicle>) {
    return await retryFetch(async () => {
      const { data, error } = await supabase
        .from('vehicles')
        .update(vehicleData)
        .eq('id', id)
        .select()
        .single();

      if (error) {
        throw new AppError('Failed to update vehicle', {
          code: error.code,
          details: error.details,
          hint: error.hint
        });
      }

      return data;
    });
  },

  async deleteVehicle(id: string) {
    return await retryFetch(async () => {
      const { error } = await supabase
        .from('vehicles')
        .delete()
        .eq('id', id);

      if (error) {
        throw new AppError('Failed to delete vehicle', {
          code: error.code,
          details: error.details,
          hint: error.hint
        });
      }
    });
  }
};