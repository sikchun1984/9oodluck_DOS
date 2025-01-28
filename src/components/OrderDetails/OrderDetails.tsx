import { useParams } from 'react-router-dom';
import { LoadingSpinner } from '../ui/LoadingSpinner';
import { useOrderDetails } from '../../hooks/useOrderDetails';
import { OrderInfo } from './OrderInfo';
import { OrderActions } from './OrderActions';

export function OrderDetails() {
  const { id } = useParams<{ id: string }>();
  const { order, isLoading, handleStatusUpdate, handleDelete, handleGenerateReceipt } = useOrderDetails(id!);

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner />
      </div>
    );
  }

  if (!order) {
    return <div>Order not found</div>;
  }

  return (
    <div className="bg-white shadow overflow-hidden sm:rounded-lg">
      <div className="px-4 py-5 sm:px-6">
        <h3 className="text-lg leading-6 font-medium text-gray-900">
          Order Details
        </h3>
      </div>
      <OrderInfo order={order} />
      <OrderActions
        order={order}
        onStatusUpdate={handleStatusUpdate}
        onDelete={handleDelete}
        onGenerateReceipt={handleGenerateReceipt}
      />
    </div>
  );
}