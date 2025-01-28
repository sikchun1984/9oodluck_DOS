import { jsPDF } from 'jspdf';
import { Order, ReceiptTemplate } from '../../types';
import { addHeader } from './sections/header';
import { addOrderDetails } from './sections/orderDetails';
import { addFooter } from './sections/footer';

export async function generateReceipt(order: Order, template: ReceiptTemplate) {
  const doc = new jsPDF();
  let currentY = 20;

  // Add header section (logo and company info)
  currentY = await addHeader(doc, template, currentY);

  // Add order details section
  currentY = await addOrderDetails(doc, order, currentY);

  // Add footer section
  await addFooter(doc, template);

  // Save the PDF
  doc.save(`receipt-${order.id}.pdf`);
}