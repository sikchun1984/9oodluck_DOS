import { useState, useEffect } from 'react';
import { vehicleService } from '../../services/vehicleService';
import { Vehicle } from '../../types';
import { LoadingSpinner } from '../ui/LoadingSpinner';

interface VehicleSelectProps {
  disabled: boolean;
  error?: string;
}

export function VehicleSelect({ disabled, error }: VehicleSelectProps) {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  useEffect(() => {
    loadVehicles();
  }, []);

  const loadVehicles = async () => {
    try {
      setLoadError(null);
      const data = await vehicleService.getActiveVehicles();
      setVehicles(data);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to load vehicles';
      setLoadError(message);
      console.error('Error loading vehicles:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingSpinner />;
  }

  if (loadError) {
    return (
      <div className="rounded-md bg-red-50 p-4">
        <div className="text-sm text-red-700">{loadError}</div>
      </div>
    );
  }

  return (
    <div>
      <label htmlFor="vehicleId" className="block text-sm font-medium text-gray-700">
        Vehicle
      </label>
      <select
        name="vehicleId"
        id="vehicleId"
        required
        disabled={disabled || vehicles.length === 0}
        className={`mt-1 block w-full rounded-md shadow-sm focus:border-indigo-500 focus:ring-indigo-500 ${
          error ? 'border-red-300' : 'border-gray-300'
        }`}
      >
        <option value="">Select a vehicle</option>
        {vehicles.map((vehicle) => (
          <option key={vehicle.id} value={vehicle.id}>
            {vehicle.plate_number} ({vehicle.type})
          </option>
        ))}
      </select>
      {error && (
        <p className="mt-1 text-sm text-red-600">{error}</p>
      )}
      {vehicles.length === 0 && (
        <p className="mt-1 text-sm text-red-600">
          No active vehicles available. Please add a vehicle first.
        </p>
      )}
    </div>
  );
}