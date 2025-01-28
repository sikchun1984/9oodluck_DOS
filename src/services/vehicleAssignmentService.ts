import { supabase } from '../lib/supabase';
import { DriverVehicleAssignment } from '../types/vehicleAssignment';

export const vehicleAssignmentService = {
  async assignVehicleToDriver(vehicleId: string, isPrimary: boolean = false): Promise<DriverVehicleAssignment> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    const { data, error } = await supabase
      .from('driver_vehicles')
      .insert({
        driver_id: user.id,
        vehicle_id: vehicleId,
        is_primary: isPrimary
      })
      .select('*, vehicle:vehicles(*)')
      .single();

    if (error) throw error;
    return data;
  },

  async unassignVehicle(vehicleId: string): Promise<void> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    const { error } = await supabase
      .from('driver_vehicles')
      .delete()
      .match({ driver_id: user.id, vehicle_id: vehicleId });

    if (error) throw error;
  },

  async getVehicleAssignment(vehicleId: string): Promise<DriverVehicleAssignment | null> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    const { data, error } = await supabase
      .from('driver_vehicles')
      .select('*, vehicle:vehicles(*)')
      .match({ driver_id: user.id, vehicle_id: vehicleId })
      .maybeSingle();

    if (error) throw error;
    return data;
  },

  async getAssignedVehicles(): Promise<DriverVehicleAssignment[]> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    const { data, error } = await supabase
      .from('driver_vehicles')
      .select('*, vehicle:vehicles(*)')
      .eq('driver_id', user.id);

    if (error) throw error;
    return data || [];
  },

  async setPrimaryVehicle(vehicleId: string): Promise<void> {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Not authenticated');

    await supabase.rpc('handle_primary_vehicle', {
      p_driver_id: user.id,
      p_vehicle_id: vehicleId
    });
  }
};