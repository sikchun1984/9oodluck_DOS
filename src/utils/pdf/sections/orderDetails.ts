import { jsPDF } from 'jspdf';
import { Order } from '../../../types';

export async function addOrderDetails(doc: jsPDF, order: Order, startY: number): Promise<number> {
  const margin = 20;
  let currentY = startY;

  doc.setFontSize(10);
  const details = [
    { label: 'Order ID:', value: order.id },
    { label: 'Date:', value: order.date },
    { label: 'Time:', value: order.time },
    { label: 'Passenger:', value: order.passenger_name },
    { label: 'Contact:', value: order.contact },
    { label: 'From:', value: order.origin },
    { label: 'To:', value: order.destination },
    { label: 'Vehicle Type:', value: order.vehicle_type },
    { label: 'License Plate:', value: order.vehicle?.plate_number || '-' },
    { label: 'Status:', value: order.status }
  ];

  const labelX = margin;
  const valueX = margin + 30;
  const lineHeight = 7;

  details.forEach((detail) => {
    doc.text(detail.label, labelX, currentY);
    doc.text(detail.value, valueX, currentY);
    currentY += lineHeight;
  });

  return currentY;
}