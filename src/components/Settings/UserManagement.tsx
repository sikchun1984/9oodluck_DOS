import { useState, useEffect } from 'react';
import { toast } from 'react-hot-toast';
import { userManagementService } from '../../services/userManagementService';
import { useNavigate } from 'react-router-dom';
import { Driver } from '../../types';
import { LoadingSpinner } from '../ui/LoadingSpinner';

export function UserManagement() {
  const [users, setUsers] = useState<Driver[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      setError(null);
      const data = await userManagementService.getUsers();
      setUsers(data);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to load users';
      if (message.includes('session has expired')) {
        navigate('/login');
      } else {
        setError(message);
        toast.error(message);
      }
      console.error('Error loading users:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleRoleChange = async (userId: string, newRole: string) => {
    try {
      await userManagementService.updateUserRole(userId, newRole);
      loadUsers();
      toast.success('User role updated successfully');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to update user role';
      toast.error(message);
    }
  };

  if (loading) {
    return <LoadingSpinner />;
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600">{error}</p>
        <button
          onClick={loadUsers}
          className="mt-4 text-indigo-600 hover:text-indigo-900"
        >
          Try again
        </button>
      </div>
    );
  }

  return (
    <div className="bg-white shadow overflow-hidden sm:rounded-lg">
      <div className="px-4 py-5 sm:px-6">
        <h3 className="text-lg leading-6 font-medium text-gray-900">
          User Management
        </h3>
        <p className="mt-1 text-sm text-gray-500">
          Manage user accounts and their roles
        </p>
      </div>
      <div className="border-t border-gray-200">
        <ul className="divide-y divide-gray-200">
          {users.map(user => (
            <li key={user.id} className="px-4 py-4 flex items-center justify-between">
              <div className="flex-grow">
                <h4 className="text-sm font-medium text-gray-900 flex items-center">
                  {user.full_name}
                  {user.role === 'admin' && user.full_name !== 'System Admin' && (
                    <span className="ml-2 text-xs bg-yellow-100 text-yellow-800 px-2 py-1 rounded">
                      System Admin
                    </span>
                  )}
                </h4>
                <p className="text-sm text-gray-500 mt-1">
                  <span className="mr-2">
                    Email: {user.email}
                  </span>
                  {user.phone && (
                    <span className="mr-2">
                      Phone: <span className="font-mono">{user.phone}</span>
                    </span>
                  )}
                </p>
                <p className="text-sm text-gray-500 mt-1">
                  {(user.role !== 'admin' || user.full_name === 'System Admin') && (
                    <span className="text-xs bg-gray-100 px-2 py-1 rounded">
                      {user.role}
                    </span>
                  )}
                </p>
              </div>
              <div className="flex items-center space-x-4 ml-4">
                <select
                  value={user.role}
                  onChange={(e) => handleRoleChange(user.id, e.target.value)}
                  className="block w-32 rounded-md border-gray-300 shadow-sm 
                    focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm
                    disabled:opacity-50 disabled:cursor-not-allowed"
                  disabled={user.role === 'admin'}
                >
                  <option value="driver">Driver</option>
                  <option value="dispatcher">Dispatcher</option>
                  <option value="admin">Admin</option>
                </select>
              </div>
            </li>
          ))}
          {users.length === 0 && (
            <li className="px-4 py-4 text-center text-gray-500">
              No users found
            </li>
          )}
        </ul>
      </div>
    </div>
  );
}