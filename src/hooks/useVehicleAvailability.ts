import { useState, useEffect } from 'react';
import { vehicleService } from '../services/vehicleService';
import { AppError } from '../utils/error';

export function useVehicleAvailability() {
  const [hasVehicles, setHasVehicles] = useState<boolean>(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const checkVehicles = async () => {
      try {
        setLoading(true);
        const vehicles = await vehicleService.getActiveVehicles();
        setHasVehicles(vehicles.length > 0);
        setError(null);
      } catch (err) {
        const error = err instanceof AppError ? err : new AppError('Failed to check vehicles');
        console.error('Error checking vehicles:', error);
        setError('Unable to check vehicle availability. Please try again.');
        setHasVehicles(false);
      } finally {
        setLoading(false);
      }
    };

    checkVehicles();
  }, []); // Empty dependency array since we only need to check once on mount

  return { hasVehicles, loading, error };
}