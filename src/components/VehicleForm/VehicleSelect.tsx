import { useState, useEffect } from 'react';
import { vehicleTypeService } from '../../services/vehicleTypeService';
import { VehicleType } from '../../types/vehicleType';
import { toast } from 'react-hot-toast';

interface VehicleSelectProps {
  disabled: boolean;
}

export function VehicleSelect({ disabled }: VehicleSelectProps) {
  const [types, setTypes] = useState<VehicleType[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadVehicleTypes();
  }, []);

  const loadVehicleTypes = async () => {
    try {
      setError(null);
      const data = await vehicleTypeService.getVehicleTypes();
      setTypes(data);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to load vehicle types';
      setError(message);
      toast.error(message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <select disabled className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500">
        <option>Loading...</option>
      </select>
    );
  }

  if (error) {
    return (
      <div className="text-sm text-red-600">
        {error}
        <button
          onClick={loadVehicleTypes}
          className="ml-2 text-indigo-600 hover:text-indigo-900"
        >
          Try again
        </button>
      </div>
    );
  }

  return (
    <select
      name="type"
      id="type"
      required
      disabled={disabled}
      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
    >
      <option value="">Select a type</option>
      {types.map((type) => (
        <option key={type.id} value={type.name}>
          {type.name}
        </option>
      ))}
      {types.length === 0 && (
        <option disabled value="">No vehicle types available</option>
      )}
    </select>
  );
}