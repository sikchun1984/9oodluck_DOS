export interface Vehicle {
  id: string;
  plate_number: string;
  model?: string;
  type: string;
  driver_id: string;
  status: 'active' | 'inactive';
  created_at?: string;
}