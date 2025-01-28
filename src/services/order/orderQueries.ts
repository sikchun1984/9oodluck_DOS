import { supabase } from '../../lib/supabase';
import { Order } from '../../types';
import { AppError } from '../../utils/error';
import { getAuthenticatedUser } from '../auth/userService';
import { retryFetch } from '../../utils/api/retryFetch';

export async function getOrders(): Promise<Order[] | null> {
  const user = await getAuthenticatedUser();

  return await retryFetch(async () => {
    const { data, error } = await supabase
      .from('orders')
      .select('*, vehicle:vehicles(plate_number, type), driver:drivers(full_name, phone, email)')
      .eq('created_by', user.id)
      .returns<Order[]>()
      .order('created_at', { ascending: false });

    if (error) {
      throw new AppError('Failed to load orders', {
        code: error.code,
        details: error.details,
        hint: error.hint
      });
    }

    return data || [];
  });
}

export async function getOrder(orderId: string): Promise<Order> {
  try {
    const { data, error } = await supabase
      .from('orders')
      .select(`
        *,
        vehicle:vehicles(id, plate_number, type),
        driver:drivers(id, full_name, email, phone)
      `)
      .eq('id', orderId)
      .single();

    if (error) {
      throw new AppError(error.message || 'Failed to load order', {
        code: error.code,
        details: error.details,
        hint: error.hint
      });
    }

    if (!data) {
      throw new AppError('Order not found');
    }

    return data as Order;
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError('Failed to load order');
  }
}