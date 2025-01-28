import { useState, useEffect } from 'react';
import { vehicleService } from '../../../services/vehicleService';
import { Vehicle } from '../../../types';
import { toast } from 'react-hot-toast';
import { useNavigate } from 'react-router-dom';
import { AppError } from '../../../utils/error';

interface UseVehicleSelectReturn {
  vehicles: Vehicle[];
  loading: boolean;
  error: string | null;
}

export function useVehicleSelect() {
  const navigate = useNavigate();
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const handleNoVehicles = () => {
    toast.error('You must add a vehicle before creating an order');
    navigate('/vehicles/new');
  };

  useEffect(() => {
    const loadVehicles = async () => {
      try {
        const data = await vehicleService.getActiveVehicles();
        setVehicles(data);
        if (data.length === 0) {
          handleNoVehicles();
        }
        setError(null);
      } catch (err) {
        const error = err instanceof AppError ? err : new AppError('Failed to load vehicles');
        console.error('Error loading vehicles:', error);
        setError(error.message);
        handleNoVehicles();
      } finally {
        setLoading(false);
      }
    };

    loadVehicles();
  }, [navigate]);

  return {
    vehicles,
    loading,
    error
  } as UseVehicleSelectReturn;
}