import React from 'react';
import { vehicleService } from '../services/vehicleService';
import { toast } from 'react-hot-toast';
import { useNavigate } from 'react-router-dom';
import { VehicleTypeSelect } from './VehicleForm/VehicleTypeSelect';

export function VehicleForm() {
  const navigate = useNavigate();
  const [isSubmitting, setIsSubmitting] = React.useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      const formData = new FormData(e.currentTarget);
      const vehicleData = {
        plate_number: formData.get('plateNumber') as string,
        type: formData.get('type') as string,
        status: 'active' as const
      };

      await vehicleService.createVehicle(vehicleData);
      toast.success('Vehicle added successfully');
      navigate('/vehicles');
    } catch (error) {
      toast.error('Failed to add vehicle');
    } finally {
      setIsSubmitting(false);
    }
  };

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
          required
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
      </div>

      <div>
        <label htmlFor="type" className="block text-sm font-medium text-gray-700">
          Type
        </label>
        <VehicleTypeSelect disabled={isSubmitting} />
      </div>

      <button
        type="submit"
        disabled={isSubmitting}
        className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
      >
        {isSubmitting ? 'Adding...' : 'Add Vehicle'}
      </button>
    </form>
  );
}