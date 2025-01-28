import { OrderFormData } from '../validation/orderValidation';

export function getOrderFormData(form: HTMLFormElement): Partial<OrderFormData> {
  const formData = new FormData(form);
  
  const vehicleId = formData.get('vehicleId')?.toString().trim();
  const driverId = formData.get('driverId')?.toString().trim();

  if (!vehicleId) {
    throw new Error('You must select a vehicle');
  }

  if (!driverId) {
    throw new Error('You must select a driver');
  }

  return {
    passenger_name: formData.get('passengerName')?.toString() || '',
    contact: formData.get('contact')?.toString() || '',
    driver_id: driverId,
    origin: formData.get('origin')?.toString() || '',
    destination: formData.get('destination')?.toString() || '',
    date: formData.get('date')?.toString() || '',
    time: formData.get('time')?.toString() || '',
    vehicle_id: vehicleId,
    status: 'pending' as const
  };
}