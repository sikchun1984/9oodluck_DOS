import { useVehicleAvailability } from '../hooks/useVehicleAvailability';
import { LoadingSpinner } from './ui/LoadingSpinner';

export function VehicleCountChecker() {
  const { hasVehicles, loading, error } = useVehicleAvailability();

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner />
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto bg-white shadow px-4 py-5 sm:rounded-lg sm:p-6">
      <div className="text-center">
        <h3 className="text-lg font-medium text-gray-900">
          Vehicle Status Check
        </h3>
        <p className="mt-2 text-sm text-gray-500">
          {hasVehicles 
            ? "You have vehicles available in your account."
            : "You currently have no vehicles in your account."
          }
        </p>
        {error && (
          <p className="mt-2 text-sm text-red-600">
            Error checking vehicles: {error}
          </p>
        )}
      </div>
    </div>
  );
}