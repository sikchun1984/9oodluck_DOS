import { useState, useCallback } from 'react';
import { Order } from '../../types';
import { orderService } from '../../services/order';
import { toast } from 'react-hot-toast';

export function useOrderList() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadOrders = useCallback(async () => {
    try {
      setError(null);
      const data = await orderService.getOrders(); 
      setOrders(data || []);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to load orders';
      setError(message);
      toast.error(message);
      console.error('Failed to load orders:', err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  return {
    orders,
    isLoading,
    error,
    loadOrders
  };
}