import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { vehicleService } from '../../services/vehicleService';
import { VehicleTypeSelect } from './VehicleTypeSelect';

interface VehicleFormProps {
  onSuccess?: () => void;
}

export function VehicleForm({ onSuccess }: VehicleFormProps) {
  const navigate = useNavigate();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setIsSubmitting(true);
    
    const formData = new FormData(event.currentTarget);
    const plateNumber = formData.get('plateNumber') as string;
    const type = formData.get('type') as string;

    if (!plateNumber.trim() || !type.trim()) {
      toast.error('Please fill in all required fields');
      setIsSubmitting(false);
      return;
    }

    try {
      const vehicleData = {
        plate_number: plateNumber.trim(),
        type: type,
        status: 'active' as const
      };

      await vehicleService.createVehicle(vehicleData);
      toast.success('Vehicle added successfully');
      if (onSuccess) {
        onSuccess();
      } else {
        navigate('/vehicles');
      }
    } catch (error) {
      const message = error instanceof Error 
        ? error.message.includes('duplicate key') 
          ? 'A vehicle with this plate number already exists'
          : error.message
        : 'Failed to add vehicle';
      toast.error(message);
      console.error('Failed to add vehicle:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="plateNumber" className="block text-sm font-medium text-gray-700">
          Plate Number
        </label>
        <input
          type="text"
          name="plateNumber"
          id="plateNumber"
          placeholder="Enter vehicle plate number"
          required
          maxLength={20}
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
        />
      </div>

      <div>
        <label htmlFor="type" className="block text-sm font-medium text-gray-700">
          Type
        </label>
        <VehicleTypeSelect disabled={isSubmitting} />
      </div>
      
      <div>
        <button
          type="submit"
          disabled={isSubmitting}
          className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
        >
          {isSubmitting ? 'Adding...' : 'Add Vehicle'}
        </button>
      </div>
    </form>
  );
}