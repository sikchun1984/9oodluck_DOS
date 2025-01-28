import { Link, useNavigate } from 'react-router-dom';
import { Order } from '../types';
import { orderService } from '../services/order';
import { toast } from 'react-hot-toast';
import { LoadingSpinner } from './ui/LoadingSpinner';
import { OrderListItem } from './OrderList/OrderListItem';
import { EmptyState } from './ui/EmptyState';
import { PlusIcon } from '@heroicons/react/24/outline';
import { useState, useEffect, useCallback } from 'react';
import { AppError } from '../utils/error';

export function OrderList() {
  const navigate = useNavigate();
  const [orders, setOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadOrders = useCallback(async () => {
    try {
      setError(null);
      setIsLoading(true);
      const data = await orderService.getOrders();
      setOrders(data || []);
    } catch (err) {
      const error = AppError.fromError(err);
      if (error.message.includes('session has expired')) {
        navigate('/login');
      } else {
        setError(error.message);
        toast.error(error.message);
      }
      console.error('Error loading orders:', err);
    } finally {
      setIsLoading(false);
    }
  }, [navigate]);

  useEffect(() => {
    loadOrders();
  }, [loadOrders]);

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner />
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600">{error}</p>
        <button
          onClick={loadOrders}
          className="mt-4 text-indigo-600 hover:text-indigo-900"
        >
          Try again
        </button>
      </div>
    );
  }

  if (orders.length === 0) {
    return (
      <EmptyState
        title="No orders yet"
        description="Create your first order to get started."
        action={
          <Link
            to="/orders/new"
            className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700"
          >
            Create Order
          </Link>
        }
      />
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h2 className="text-lg font-medium text-gray-900">Orders</h2>
        <Link
          to="/orders/new"
          className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700"
        >
          <PlusIcon className="-ml-1 mr-2 h-5 w-5" />
          New Order
        </Link>
      </div>
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Date/Time
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Passenger
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Route
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Vehicle
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Status
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Actions
            </th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {orders.map((order) => (
            <OrderListItem 
              key={order.id} 
              order={order}
              onOrdersChange={loadOrders}
            />
          ))}
        </tbody>
      </table>
      </div>
    </div>
  );
}