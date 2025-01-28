import { z } from 'zod';

export const orderSchema = z.object({
  passenger_name: z.string().min(1, 'Passenger name is required'),
  contact: z.string().min(1, 'Contact is required'),
  driver_id: z.string().uuid('Invalid driver selected'),
  origin: z.string().min(1, 'Origin is required'),
  destination: z.string().min(1, 'Destination is required'),
  date: z.string().min(1, 'Date is required'),
  time: z.string().min(1, 'Time is required'),
  vehicle_id: z.string().uuid('Invalid vehicle selected'),
  status: z.literal('pending')
});

export type OrderFormData = z.infer<typeof orderSchema>;