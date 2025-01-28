import { getOrders, getOrder } from './orderQueries';
import { createOrder, updateOrderStatus, deleteOrder } from './orderMutations';

export const orderService = {
  getOrders,
  getOrder,
  createOrder,
  updateOrderStatus,
  deleteOrder
};

export {
  getOrders,
  getOrder,
  createOrder,
  updateOrderStatus,
  deleteOrder
};