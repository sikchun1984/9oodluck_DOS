import { useState, useEffect } from 'react';
import { vehicleService } from '../../services/vehicleService';
import { Vehicle } from '../../types';
import { LoadingSpinner } from '../ui/LoadingSpinner';

interface VehicleSelectProps {
  disabled: boolean;
}
import { AppError } from '../../utils/error';

export function VehicleSelect({ disabled }: VehicleSelectProps) {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadVehicles = async () => {
      try {
        setError(null);
        const data = await vehicleService.getActiveVehicles();
        setVehicles(data);
      } catch (err) {
        const error = AppError.fromError(err);
        const message = error.message;
        setError(message);
        console.error('Error loading vehicles:', err);
      } finally {
        setLoading(false);
      }
    };

    loadVehicles();
  }, []);

  if (loading) {
    return <LoadingSpinner />;
  }

  if (error) {
    return (
      <div className="rounded-md bg-red-50 p-4">
        <div className="text-sm text-red-700">{error}</div>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-2 gap-4">
      <div>
        <label htmlFor="vehicleId" className="block text-sm font-medium text-gray-700">
          Vehicle
        </label>
        <select
          name="vehicleId"
          id="vehicleId"
          required
          disabled={disabled || vehicles.length === 0}
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        >
          <option value="">Select a vehicle</option>
          {vehicles.map((vehicle) => (
            <option key={vehicle.id} value={vehicle.id}>
              {vehicle.plate_number} ({vehicle.type})
            </option>
          ))}
        </select>
        {vehicles.length === 0 && (
          <p className="mt-1 text-sm text-red-600">
            No active vehicles available. Please add a vehicle first.
          </p>
        )}
      </div>
    </div>
  );
}