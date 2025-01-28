export interface Order {
  id: string; // Format: YYYYMMDDHHMM####
  created_at?: string;
  passenger_name: string;
  contact: string;
  origin: string;
  destination: string;
  date: string;
  time: string;
  vehicle_type: string;
  driver_id: string;
  vehicle_id: string;
  created_by: string;
  vehicle?: {
    plate_number: string;
    type: string;
  };
  driver?: {
    full_name: string;
    phone: string | null;
    email: string;
  };
  status: 'pending' | 'completed' | 'cancelled';
}