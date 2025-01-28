import { useVehicleSelect } from './useVehicleSelect';
import { LoadingSpinner } from '../../ui/LoadingSpinner';
import { Link } from 'react-router-dom';

interface VehicleSelectProps {
  disabled: boolean;
  error?: string;
}

export function VehicleSelect({ disabled, error }: VehicleSelectProps) {
  const { vehicles, loading, error: loadError } = useVehicleSelect();

  if (loading) {
    return <LoadingSpinner />;
  }

  if (loadError) {
    return (
      <div className="rounded-md bg-red-50 p-4">
        <p className="text-sm text-red-700">{loadError}</p>
      </div>
    );
  }

  if (vehicles.length === 0) {
    return (
      <div className="rounded-md bg-yellow-50 p-4">
        <p className="text-sm text-yellow-700 flex items-center gap-2 font-medium">
          You must{' '}
          <Link to="/vehicles/new" className="font-medium text-yellow-700 underline">
            add a vehicle
          </Link>{' '}
          before creating an order.
        </p>
      </div>
    );
  }

  return (
    <div>
      <div>
        <label htmlFor="vehicleId" className="block text-sm font-medium text-gray-700">
          Select Vehicle
        </label>
        <select
          name="vehicleId"
          id="vehicleId"
          required
          disabled={disabled}
          className={`mt-1 block w-full rounded-md shadow-sm focus:border-indigo-500 focus:ring-indigo-500 ${
            error ? 'border-red-300' : 'border-gray-300'
          }`}
        >
          <option value="">Select a vehicle</option>
          {vehicles.map((vehicle) => (
            <option key={vehicle.id} value={vehicle.id}>
              {vehicle.plate_number} - {vehicle.model}
            </option>
          ))}
        </select>
        {error ? (
          <p className="mt-1 text-sm text-red-600">{error}</p>
        ) : null}
      </div>
    </div>
  );
}