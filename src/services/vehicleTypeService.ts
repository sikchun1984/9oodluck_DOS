import { supabase } from '../lib/supabase';
import { VehicleType } from '../types/vehicleType';
import { AppError } from '../utils/error';
import { getAuthenticatedUser } from './auth/userService';

export const vehicleTypeService = {
  async getVehicleTypes(): Promise<VehicleType[]> {
    const user = await getAuthenticatedUser();

    const { data, error } = await supabase
      .from('vehicle_types')
      .select('*')
      .eq('driver_id', user.id)
      .order('name');

    if (error) {
      throw new AppError('Failed to load vehicle types', error);
    }

    return data || [];
  },

  async createVehicleType(name: string): Promise<VehicleType> {
    const user = await getAuthenticatedUser();

    const { data, error } = await supabase
      .from('vehicle_types')
      .insert({ name, driver_id: user.id })
      .select()
      .single();

    if (error) {
      throw new AppError('Failed to create vehicle type', error);
    }

    return data;
  },

  async deleteVehicleType(id: string): Promise<void> {
    const { error } = await supabase
      .from('vehicle_types')
      .delete()
      .eq('id', id);

    if (error) {
      throw new AppError('Failed to delete vehicle type', error);
    }
  }
};