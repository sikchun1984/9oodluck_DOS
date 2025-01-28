import { useState, useEffect } from 'react';
import { driverService } from '../services/driverService';
import { toast } from 'react-hot-toast';
import { DriverProfileForm } from './DriverProfile/DriverProfileForm';
import { DriverProfileView } from './DriverProfile/DriverProfileView';
import { AppError } from '../utils/error';
import { Driver } from '../types/driver';
import { LoadingSpinner } from './ui/LoadingSpinner';
import { useNavigate } from 'react-router-dom';


export function DriverList() {
  const navigate = useNavigate();
  const [driver, setDriver] = useState<Driver | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isEditing, setIsEditing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadDriver();
  }, []);

  const loadDriver = async () => {
    try {
      setError(null);
      const data = await driverService.getDriverProfile();
      setDriver(data);
    } catch (err) {
      const error = err instanceof AppError ? err.message : 'Failed to load driver profile';
      if (error.includes('session has expired')) {
        navigate('/login');
      } else {
        setError(error);
        toast.error(error);
      }
      console.error('Failed to load driver profile:', err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleProfileUpdate = () => {
    loadDriver();
    setIsEditing(false);
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner />
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600">{error}</p>
        <button
          onClick={loadDriver}
          className="mt-4 text-indigo-600 hover:text-indigo-900"
        >
          Try again
        </button>
      </div>
    );
  }

  if (!driver || isEditing) {
    return (
      <div className="max-w-3xl mx-auto">
        <div className="bg-white shadow px-4 py-5 sm:rounded-lg sm:p-6">
          <div className="md:grid md:grid-cols-3 md:gap-6">
            <div className="md:col-span-1">
              <h3 className="text-lg font-medium leading-6 text-gray-900">
                {driver ? 'Edit Profile' : 'Create Profile'}
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                {driver 
                  ? 'Update your driver information.'
                  : 'Please complete your driver profile to continue.'
                }
              </p>
            </div>
            <div className="mt-5 md:mt-0 md:col-span-2">
              <DriverProfileForm 
                currentDriver={driver} 
                onSuccess={handleProfileUpdate} 
              />
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto">
      <DriverProfileView 
        driver={driver} 
        onEdit={() => setIsEditing(true)} 
      />
    </div>
  );
}