import { useState, useCallback, useEffect } from 'react';
import { Vehicle } from '../../types';
import { vehicleService } from '../../services/vehicleService';
import { toast } from 'react-hot-toast';

export function useVehicleList() {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadVehicles = useCallback(async () => {
    try {
      setError(null);
      const data = await vehicleService.getVehicles();
      setVehicles(data);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to load vehicles';
      setError(message);
      toast.error(message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadVehicles();
  }, [loadVehicles]);

  return {
    vehicles,
    loading,
    error,
    refreshVehicles: loadVehicles
  };
}