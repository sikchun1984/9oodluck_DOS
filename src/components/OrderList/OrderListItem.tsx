import { Link } from 'react-router-dom';
import { formatDate } from '../../utils/date';
import { Order } from '../../types';
import { OrderStatus } from './OrderStatus';
import { orderService } from '../../services/order'; 
import { AppError } from '../../utils/error';
import { toast } from 'react-hot-toast';

interface OrderListItemProps {
  order: Order;
  onOrdersChange: () => void;
}

export function OrderListItem({ order, onOrdersChange }: OrderListItemProps) {
  const handleDelete = async () => {
    if (!window.confirm('Are you sure you want to delete this order?')) {
      return;
    }
    
    try {
      await orderService.deleteOrder(order.id);
      onOrdersChange();
      toast.success('Order deleted successfully');
    } catch (error) {
      const message = error instanceof AppError ? error.message : 'Failed to delete order';
      toast.error(message);
      console.error('Failed to delete order:', error);
    }
  };

  return (
    <tr>
      <td className="px-6 py-4 whitespace-nowrap">
        <div className="text-sm text-gray-900">
          {formatDate(order.date)}
        </div>
        <div className="text-sm text-gray-500">{order.time}</div>
      </td>
      <td className="px-6 py-4 whitespace-nowrap">
        <div className="text-sm text-gray-900">{order.passenger_name}</div>
        <div className="text-sm text-gray-500">{order.contact}</div>
      </td>
      <td className="px-6 py-4 whitespace-nowrap">
        <div className="text-sm text-gray-900">{order.origin}</div>
        <div className="text-sm text-gray-500">→ {order.destination}</div>
      </td>
      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
        {order.vehicle?.plate_number || '-'}
      </td>
      <td className="px-6 py-4 whitespace-nowrap">
        <OrderStatus status={order.status} />
      </td>
      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
        <Link
          to={`/orders/${order.id}`}
          className="text-indigo-600 hover:text-indigo-900"
        >
          View
        </Link>
        {order.status !== 'completed' && (
          <button
            onClick={handleDelete}
            className="text-red-600 hover:text-red-900"
          >
            Delete
          </button>
        )}
      </td>
    </tr>
  );
}