export interface Driver {
  id: string;
  email: string;
  full_name: string;
  phone: string | null;
  license_number?: string;
  role: 'admin' | 'driver' | 'dispatcher';
  created_at?: string;
}