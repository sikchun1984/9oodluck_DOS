import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { supabase } from '../../lib/supabase';
import { useAuth } from '../../contexts/AuthContext';
import { useVehicleAvailability } from '../../hooks/useVehicleAvailability';
import { orderService } from '../../services/order';
import { OrderFormData } from '../../utils/validation/orderValidation';
import { VehicleSelect } from './VehicleSelect';
import { LoadingSpinner } from '../ui/LoadingSpinner';

export function OrderForm() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [submitting, setSubmitting] = useState(false);
  const [driverProfile, setDriverProfile] = useState<{ full_name: string; phone: string | null } | null>(null);
  const [formError, setFormError] = useState<string | null>(null);
  const { hasVehicles, loading, error } = useVehicleAvailability();

  useEffect(() => {
    const loadDriverProfile = async () => {
      try {
        const { data, error } = await supabase
          .from('drivers')
          .select('full_name, phone')
          .eq('id', user?.id)
          .single();

        if (error) throw error;
        setDriverProfile(data);
      } catch (err) {
        console.error('Error loading driver profile:', err);
        toast.error('Failed to load driver profile');
      }
    };

    if (user?.id) {
      loadDriverProfile();
    }
  }, [user?.id]);

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner />
      </div>
    );
  }

  if (!hasVehicles) {
    return (
      <div className="max-w-3xl mx-auto bg-white shadow px-4 py-5 sm:rounded-lg sm:p-6">
        <div className="text-center py-8">
          <h3 className="text-lg font-medium text-gray-900">No Vehicles Available</h3>
          <p className="mt-1 text-sm text-gray-500">
            You need to add at least one active vehicle before you can create orders.
            {error && (
              <span className="block mt-2 text-red-600">{error}</span>
            )}
          </p>
          <Link
            to="/vehicles"
            state={{ openAddVehicle: true }}
            className="mt-6 inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Add Your First Vehicle
          </Link>
        </div>
      </div>
    );
  }

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setSubmitting(true);
    setFormError(null);

    try {
      const formData = new FormData(e.currentTarget);
      const orderData: OrderFormData = {
        driver_id: user?.id as string,
        passenger_name: formData.get('passengerName') as string,
        contact: formData.get('contact') as string,
        origin: formData.get('origin') as string,
        destination: formData.get('destination') as string,
        date: formData.get('date') as string,
        time: formData.get('time') as string,
        vehicle_id: formData.get('vehicleId')?.toString() || '',
        status: 'pending' as const
      };

      if (!orderData.vehicle_id) {
        throw new Error('Please select a vehicle');
      }

      await orderService.createOrder(orderData);
      toast.success('Order created successfully');
      navigate('/orders');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to create order';
      setFormError(message);
      console.error('Failed to create order:', message);
      toast.error(message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-3xl mx-auto">
      <form onSubmit={handleSubmit} className="space-y-6 bg-white shadow px-4 py-5 sm:rounded-lg sm:p-6">
        <div className="md:grid md:grid-cols-3 md:gap-6">
          <div className="md:col-span-1">
            <h3 className="text-lg font-medium leading-6 text-gray-900">New Order</h3>
            <p className="mt-1 text-sm text-gray-500">
              Enter the order details below.
            </p>
          </div>
          <div className="mt-5 md:mt-0 md:col-span-2">
            <div className="grid grid-cols-6 gap-6">
              {formError && (
                <div className="col-span-6">
                  <div className="rounded-md bg-red-50 p-4">
                    <div className="text-sm text-red-700">{formError}</div>
                  </div>
                </div>
              )}

              <div className="col-span-6 sm:col-span-4">
                <label htmlFor="passengerName" className="block text-sm font-medium text-gray-700">
                  Passenger Name
                </label>
                <input
                  type="text"
                  name="passengerName"
                  id="passengerName"
                  required
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>

              <div className="col-span-6 sm:col-span-4">
                <label htmlFor="contact" className="block text-sm font-medium text-gray-700">
                  Contact
                </label>
                <input
                  type="text"
                  name="contact"
                  id="contact"
                  required
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>

              <div className="col-span-6 sm:col-span-3">
                <label htmlFor="origin" className="block text-sm font-medium text-gray-700">
                  Origin
                </label>
                <input
                  type="text"
                  name="origin"
                  id="origin"
                  required
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>

              <div className="col-span-6 sm:col-span-3">
                <label htmlFor="destination" className="block text-sm font-medium text-gray-700">
                  Destination
                </label>
                <input
                  type="text"
                  name="destination"
                  id="destination"
                  required
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>

              <div className="col-span-6 sm:col-span-3">
                <label htmlFor="date" className="block text-sm font-medium text-gray-700">
                  Date
                </label>
                <input
                  type="date"
                  name="date"
                  id="date"
                  required
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>

              <div className="col-span-6 sm:col-span-3">
                <label htmlFor="time" className="block text-sm font-medium text-gray-700">
                  Time
                </label>
                <input
                  type="time"
                  name="time"
                  id="time"
                  required
                  disabled={submitting}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
              </div>

              <div className="col-span-6">
                <label className="block text-sm font-medium text-gray-700">
                  Driver
                </label>
                <div className="mt-1 text-sm text-gray-900">
                  {driverProfile ? (
                    <div>
                      <span>{driverProfile.full_name}</span>
                      {driverProfile.phone && (
                        <span className="ml-2 text-gray-500">({driverProfile.phone})</span>
                      )}
                    </div>
                  ) : (
                    <span className="text-gray-500">Loading driver info...</span>
                  )}
                </div>
              </div>

              <div className="col-span-6">
                <label htmlFor="vehicleId" className="block text-sm font-medium text-gray-700 mt-4">
                  Vehicle
                </label>
                <VehicleSelect disabled={submitting} />
              </div>
            </div>
          </div>
        </div>

        <div className="flex justify-end">
          <button
            type="submit"
            disabled={submitting}
            className="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
          >
            {submitting ? 'Creating...' : 'Create Order'}
          </button>
        </div>
      </form>
    </div>
  );
}