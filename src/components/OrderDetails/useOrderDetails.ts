import { useState, useCallback, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { Order } from '../../types';
import { getOrder, updateOrderStatus } from '../../services/order';
import { generateReceipt } from '../../utils/receiptGenerator';

export function useOrderDetails(orderId: string) {
  const navigate = useNavigate();
  const [order, setOrder] = useState<Order | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const loadOrder = useCallback(async () => {
    try {
      const data = await getOrder(orderId);
      setOrder(data);
    } catch (error) {
      toast.error('Failed to load order');
      navigate('/orders');
    } finally {
      setIsLoading(false);
    }
  }, [orderId, navigate]);

  useEffect(() => {
    loadOrder();
  }, [loadOrder]);

  const handleStatusUpdate = async (status: Order['status']) => {
    if (!order) return;

    try {
      const updatedOrder = await updateOrderStatus(order.id, status);
      setOrder(updatedOrder);
      toast.success(`Order marked as ${status}`);
    } catch (error) {
      toast.error('Failed to update order status');
    }
  };

  const handleGenerateReceipt = async () => {
    if (!order) return;
    await generateReceipt(order);
  };

  return {
    order,
    isLoading,
    handleStatusUpdate,
    handleGenerateReceipt
  };
}