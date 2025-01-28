import { useState, useEffect } from 'react';
import { toast } from 'react-hot-toast';
import { vehicleTypeService } from '../../services/vehicleTypeService';
import { VehicleType } from '../../types/vehicleType';
import { LoadingSpinner } from '../ui/LoadingSpinner';

export function VehicleTypeManager() {
  const [types, setTypes] = useState<VehicleType[]>([]);
  const [loading, setLoading] = useState(true);
  const [newTypeName, setNewTypeName] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    loadVehicleTypes();
  }, []);

  const loadVehicleTypes = async () => {
    try {
      const data = await vehicleTypeService.getVehicleTypes();
      setTypes(data);
    } catch (error) {
      toast.error('Failed to load vehicle types');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTypeName.trim()) return;

    setIsSubmitting(true);
    try {
      await vehicleTypeService.createVehicleType(newTypeName);
      toast.success('Vehicle type added successfully');
      setNewTypeName('');
      loadVehicleTypes();
    } catch (error) {
      toast.error('Failed to add vehicle type');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this vehicle type?')) {
      return;
    }

    try {
      await vehicleTypeService.deleteVehicleType(id);
      toast.success('Vehicle type deleted successfully');
      loadVehicleTypes();
    } catch (error) {
      toast.error('Failed to delete vehicle type');
    }
  };

  if (loading) {
    return <LoadingSpinner />;
  }

  return (
    <div className="space-y-6">
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="typeName" className="block text-sm font-medium text-gray-700">
            New Vehicle Type
          </label>
          <div className="mt-1 flex rounded-md shadow-sm">
            <input
              type="text"
              name="typeName"
              id="typeName"
              value={newTypeName}
              onChange={(e) => setNewTypeName(e.target.value)}
              className="flex-1 min-w-0 block w-full rounded-md border-gray-300 focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
              placeholder="Enter vehicle type name"
            />
            <button
              type="submit"
              disabled={isSubmitting || !newTypeName.trim()}
              className="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
            >
              Add Type
            </button>
          </div>
        </div>
      </form>

      <div className="bg-white shadow overflow-hidden sm:rounded-lg">
        <ul className="divide-y divide-gray-200">
          {types.map((type) => (
            <li key={type.id} className="px-4 py-4 flex items-center justify-between">
              <span className="text-sm font-medium text-gray-900">{type.name}</span>
              <button
                onClick={() => handleDelete(type.id)}
                className="text-red-600 hover:text-red-900 text-sm font-medium"
              >
                Delete
              </button>
            </li>
          ))}
          {types.length === 0 && (
            <li className="px-4 py-4 text-sm text-gray-500 text-center">
              No vehicle types added yet
            </li>
          )}
        </ul>
      </div>
    </div>
  );
}