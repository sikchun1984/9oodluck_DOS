import { Navigate, useLocation } from 'react-router-dom';
import { useHasPermission } from '../hooks/useRole';
import { UserRole } from '../types/user';
import { LoadingSpinner } from './ui/LoadingSpinner';

interface RoleProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles: UserRole[];
}

export function RoleProtectedRoute({ children, allowedRoles }: RoleProtectedRouteProps) {
  const { hasPermission, loading } = useHasPermission(allowedRoles);
  const location = useLocation();

  if (loading) {
    return (
      <div className="min-h-screen flex justify-center items-center">
        <LoadingSpinner />
      </div>
    );
  }

  if (!hasPermission) {
    return <Navigate to="/unauthorized" state={{ from: location }} replace />;
  }

  return <>{children}</>;
}