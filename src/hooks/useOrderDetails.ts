import { useState, useCallback, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { Order } from '../types';
import { orderService } from '../services/order';
import { generateReceipt } from '../utils/receiptGenerator';

export function useOrderDetails(orderId: string) {
  const navigate = useNavigate();
  const [order, setOrder] = useState<Order | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const loadOrder = useCallback(async () => {
    try {
      const data = await orderService.getOrder(orderId);
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
      const updatedOrder = await orderService.updateOrderStatus(order.id, status);
      setOrder(updatedOrder);
      toast.success(`Order marked as ${status}`);
    } catch (error) {
      toast.error('Failed to update order status');
    }
  };
  
  const handleDelete = async () => {
    if (!order) return;
    
    if (!window.confirm('Are you sure you want to delete this order?')) {
      return;
    }

    try {
      await orderService.deleteOrder(order.id);
      toast.success('Order deleted successfully');
      navigate('/orders');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to delete order';
      toast.error(message);
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
    handleDelete,
    handleGenerateReceipt
  };
}