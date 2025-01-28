import { supabase } from '../lib/supabase';
import { AppError } from '../utils/error';
import { getAuthenticatedUser } from './auth/userService';

export const databaseService = {
  async initializeDatabase(tables: string[]) {
    const user = await getAuthenticatedUser();

    // Start a transaction
    const { error: initError } = await supabase.rpc('initialize_selected_tables', {
      p_driver_id: user.id,
      p_tables: tables
    });

    if (initError) {
      throw new AppError('Failed to initialize database', initError);
    }

    // If vehicle_types was selected, initialize default types
    if (tables.includes('vehicle_types')) {
      const defaultTypes = ['Sedan', 'SUV', 'Van', 'Bus'];
      const { error: insertError } = await supabase
        .from('vehicle_types')
        .insert(defaultTypes.map(name => ({
          name,
          driver_id: user.id
        })));

      if (insertError) {
        throw new AppError('Failed to initialize default vehicle types', insertError);
      }
    }
  }
};