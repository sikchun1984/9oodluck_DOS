import { useAuth } from '../contexts/AuthContext';
import { UserRole } from '../types/user';

export function useHasPermission(allowedRoles: UserRole[]) {
  const { user, loading, role } = useAuth();

  if (loading) {
    return { loading: true, hasPermission: false };
  }

  // Ensure user is logged in and has a role
  if (!user || !role) {
    return { loading: false, hasPermission: false };
  }

  // Check if user has any of the allowed roles
  const hasPermission = allowedRoles.includes(role as UserRole);

  return { loading: false, hasPermission };
}