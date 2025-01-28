import { supabase } from '../../lib/supabase';
import { Order } from '../../types';
import { AppError } from '../../utils/error';
import { getAuthenticatedUser } from '../auth/userService';
import { generateOrderId } from '../../utils/orderIdGenerator';
import type { OrderFormData } from '../../utils/validation/orderValidation';

export async function createOrder(orderData: OrderFormData): Promise<Order> {
  try {
    const user = await getAuthenticatedUser();
    const orderId = generateOrderId();
    
    const orderWithDriver = {
      ...orderData,
      id: orderId,
      driver_id: user.id,
      created_by: user.id
    };

    // Verify vehicle exists and belongs to user
    const { data: vehicles, error: vehicleError } = await supabase
      .from('vehicles')
      .select('type')
      .eq('id', orderWithDriver.vehicle_id)
      .limit(1);

    if (vehicleError) {
      throw new AppError('Failed to verify vehicle');
    }

    if (!vehicles || vehicles.length === 0) {
      throw new AppError('Please select a valid vehicle');
    }

    const { data, error } = await supabase
      .from('orders')
      .insert({
        id: orderId,
        driver_id: orderWithDriver.driver_id,
        passenger_name: orderWithDriver.passenger_name,
        contact: orderWithDriver.contact,
        origin: orderWithDriver.origin,
        destination: orderWithDriver.destination,
        date: orderWithDriver.date,
        time: orderWithDriver.time,
        vehicle_id: orderWithDriver.vehicle_id,
        vehicle_type: vehicles[0].type,
        status: 'pending',
        created_by: orderWithDriver.created_by
      })
      .select()
      .single();

    if (error) {
      throw new AppError('Failed to create order');
    }

    return data;
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError('An unexpected error occurred while creating the order');
  }
}

export async function updateOrderStatus(
  orderId: string, 
  status: Order['status']
): Promise<Order> {
  const { data, error } = await supabase
    .from('orders')
    .update({ status })
    .eq('id', orderId)
    .select()
    .single();

  if (error) {
    throw new AppError(error.message || 'Failed to update order status', {
      code: error.code,
      details: error.details,
      hint: error.hint
    });
  }

  if (!data) {
    throw new AppError('Failed to update order status');
  }

  return data;
}

export async function deleteOrder(orderId: string): Promise<void> {
  const { error } = await supabase
    .from('orders')
    .delete()
    .eq('id', orderId);

  if (error) {
    throw new AppError(error.message || 'Failed to delete order', {
      code: error.code,
      details: error.details,
      hint: error.hint
    });
  }
}