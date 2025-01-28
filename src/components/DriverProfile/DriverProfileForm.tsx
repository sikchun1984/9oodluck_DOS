import { useState } from 'react';
import { toast } from 'react-hot-toast';
import { Driver } from '../../types/driver';
import { driverService } from '../../services/driverService';

interface DriverProfileFormProps {
  currentDriver: Driver | null;
  onSuccess?: () => void;
}

export function DriverProfileForm({ currentDriver, onSuccess }: DriverProfileFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);
    const formData = new FormData(e.currentTarget);

    try {
      const driverData = {
        full_name: formData.get('fullName') as string,
        email: formData.get('email') as string,
        role: currentDriver?.role || 'driver', // Keep existing role
        phone: formData.get('phone') as string || null
      };

      await driverService.updateDriverProfile(driverData);
      toast.success('Driver profile updated successfully');
      onSuccess?.();
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to update driver profile';
      toast.error(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label htmlFor="fullName" className="block text-sm font-medium text-gray-700">
          Full Name
        </label>
        <input
          type="text"
          name="fullName"
          id="fullName"
          defaultValue={currentDriver?.full_name}
          required
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
      </div>

      <div>
        <label htmlFor="email" className="block text-sm font-medium text-gray-700">
          Email
        </label>
        <input
          type="email"
          name="email"
          id="email"
          defaultValue={currentDriver?.email}
          required
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
      </div>
      
      <div>
        <label htmlFor="role" className="block text-sm font-medium text-gray-700">
          Role
        </label>
        <div className="mt-1 block w-full text-sm text-gray-700">
          {currentDriver?.role || 'driver'}
        </div>
      </div>
      <div>
        <label htmlFor="phone" className="block text-sm font-medium text-gray-700">
          Phone Number
          <span className="text-sm text-gray-500 ml-1">(optional)</span>
        </label>
        <input
          type="tel"
          name="phone"
          id="phone"
          defaultValue={currentDriver?.phone || ''}
          pattern="[0-9+\-\s]+"
          title="Enter a valid phone number (numbers, +, -, and spaces only)"
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
      </div>

      <button
        type="submit"
        disabled={isSubmitting}
        className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
      >
        {isSubmitting ? 'Saving...' : 'Save Profile'}
      </button>
    </form>
  );
}