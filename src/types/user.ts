export type UserRole = 'admin' | 'driver' | 'dispatcher';

export interface User {
  id: string;
  roles: UserRole[];
  phone: string;
}