import { Order } from '../../types';

interface OrderActionsProps {
  order: Order;
  onStatusUpdate: (status: Order['status']) => Promise<void>;
  onDelete: () => Promise<void>;
  onGenerateReceipt: () => Promise<void>;
}

export function OrderActions({ order, onStatusUpdate, onDelete, onGenerateReceipt }: OrderActionsProps) {
  return (
    <div className="px-4 py-5 sm:px-6 space-x-4">
      {order.status === 'pending' && (
        <>
          <button
            onClick={() => onStatusUpdate('completed')}
            className="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
          >
            Mark as Completed
          </button>
          <button
            onClick={() => onStatusUpdate('cancelled')}
            className="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
          >
            Cancel Order
          </button>
        </>
      )}
      <button
        onClick={onDelete}
        type="button"
        className="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
      >
        Delete Order
      </button>
      <button
        onClick={onGenerateReceipt}
        className="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
      >
        Generate Receipt
      </button>
    </div>
  );
}