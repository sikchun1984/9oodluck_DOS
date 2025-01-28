import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { vehicleService } from '../../services/vehicleService';
import { Vehicle } from '../../types';
import { VehicleTypeSelect } from './VehicleTypeSelect';
import { LoadingSpinner } from '../ui/LoadingSpinner';

export function EditVehicleForm() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [vehicle, setVehicle] = useState<Vehicle | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadVehicle();
  }, []);

  const loadVehicle = async () => {
    try {
      setError(null);
      if (!id) return;
      const data = await vehicleService.getVehicle(id);
      setVehicle(data);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to load vehicle';
      if (message.includes('session has expired')) {
        navigate('/login');
      } else {
        setError(message);
        toast.error(message);
      }
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!vehicle) return;
    setIsSubmitting(true);
    try {
      const formData = new FormData(e.currentTarget);
      const vehicleData = {
        plate_number: formData.get('plateNumber') as string,
        type: formData.get('type') as string,
        status: formData.get('status') as 'active' | 'inactive'
      };

      await vehicleService.updateVehicle(vehicle.id, vehicleData);
      toast.success('Vehicle updated successfully');
      navigate('/vehicles');
    } catch (error) {
      toast.error('Failed to update vehicle');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600">{error}</p>
        <button
          onClick={loadVehicle}
          className="mt-4 text-indigo-600 hover:text-indigo-900"
        >
          Try again
        </button>
      </div>
    );
  }

  if (!vehicle) {
    return <div>Vehicle not found</div>;
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label htmlFor="plateNumber" className="block text-sm font-medium text-gray-700">
          Plate Number
        </label>
        <input
          type="text"
          name="plateNumber"
          id="plateNumber"
          defaultValue={vehicle.plate_number}
          required
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
      </div>

      <div className="mt-4">
        <label htmlFor="type" className="block text-sm font-medium text-gray-700">
          Type
        </label>
        <VehicleTypeSelect
          defaultValue={vehicle.type}
          disabled={isSubmitting}
          required
        />
      </div>

      <div className="mt-4">
        <label htmlFor="status" className="block text-sm font-medium text-gray-700">
          Status
        </label>
        <select
          name="status"
          id="status"
          defaultValue={vehicle.status}
          required
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        >
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
        </select>
      </div>

      <div className="mt-6 flex justify-end space-x-3">
        <button
          type="button"
          onClick={() => navigate('/vehicles')}
          className="px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={isSubmitting}
          className="px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50"
        >
          {isSubmitting ? 'Saving...' : 'Save Changes'}
        </button>
      </div>
    </form>
  );
}