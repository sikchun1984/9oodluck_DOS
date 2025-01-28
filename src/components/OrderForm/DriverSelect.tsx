import { useState, useEffect } from 'react';
import { Driver } from '../../types/driver';
import { driverService } from '../../services/driverService';
import { LoadingSpinner } from '../ui/LoadingSpinner';

export function DriverSelect() {
  const [currentDriver, setCurrentDriver] = useState<Driver | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadCurrentDriver();
  }, []);

  const loadCurrentDriver = async () => {
    try {
      setError(null);
      const driver = await driverService.getDriverProfile();
      setCurrentDriver(driver);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to load driver profile';
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center space-x-2">
        <LoadingSpinner />
        <span className="text-sm text-gray-500">Loading driver info...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-sm text-red-600">
        {error}
        <button
          onClick={loadCurrentDriver}
          className="ml-2 text-indigo-600 hover:text-indigo-900"
        >
          Try again
        </button>
      </div>
    );
  }

  return (
    <div className="text-sm text-gray-700">
      {currentDriver ? (
        <>
          <span className="font-medium">{currentDriver.full_name}</span>
          {currentDriver.phone && <span className="ml-2">({currentDriver.phone})</span>}
        </>
      ) : (
        'No driver information available'
      )}
    </div>
  );
}