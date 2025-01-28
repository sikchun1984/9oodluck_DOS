import { Order } from '../types';
import { receiptService } from '../services/receiptService';

export async function generateReceipt(order: Order) {
  const template = await receiptService.getTemplate();
  if (!template) {
    throw new Error('Receipt template not found');
  }

  const canvas = document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  if (!ctx) {
    throw new Error('Failed to get canvas context');
  }

  canvas.width = 1748;  // 5.83 inches * 300 DPI
  canvas.height = 2480; // 8.27 inches * 300 DPI

  ctx.fillStyle = 'white';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  let currentY = 100;
  const margin = 100;
  const pageWidth = canvas.width;

  if (template.logo) {
    try {
      const logoImg = await loadImage(template.logo);
      const maxLogoWidth = 400;
      const maxLogoHeight = 400;
      const aspectRatio = logoImg.width / logoImg.height;
      
      let logoWidth = maxLogoWidth;
      let logoHeight = logoWidth / aspectRatio;
      
      if (logoHeight > maxLogoHeight) {
        logoHeight = maxLogoHeight;
        logoWidth = logoHeight * aspectRatio;
      }

      const logoX = (pageWidth - logoWidth) / 2;
      ctx.drawImage(logoImg, logoX, currentY, logoWidth, logoHeight);
      currentY += logoHeight + 90;
    } catch (error) {
      console.error('Failed to load logo:', error);
    }
  }

  ctx.font = 'bold 60px Arial';
  ctx.fillStyle = '#000000';
  ctx.textAlign = 'center';
  if (template.company_name_zh) {
    ctx.fillText(template.company_name_zh, pageWidth / 2, currentY);
    currentY += 80;
  }
  ctx.fillText(template.company_name, pageWidth / 2, currentY);
  currentY += 80;

  ctx.font = '36px Arial';
  ctx.fillText(template.address, pageWidth / 2, currentY);
  currentY += 50;
  ctx.fillText(`Tel: ${template.phone}`, pageWidth / 2, currentY);
  currentY += 80;

  ctx.font = 'bold 48px Arial';
  ctx.fillText('RECEIPT', pageWidth / 2, currentY);
  currentY += 100;

  ctx.font = '36px Arial';
  ctx.textAlign = 'left';
  const details = [
    { label: 'Order ID:', value: order.id },
    { label: 'Created:', value: order.created_at ? new Date(order.created_at).toLocaleString() : '-' },
    { label: 'Date:', value: order.date },
    { label: 'Time:', value: order.time },
    { label: 'Passenger:', value: order.passenger_name },
    { label: 'Contact:', value: order.contact },
    { label: 'From:', value: order.origin },
    { label: 'To:', value: order.destination },
    { label: 'Vehicle:', value: order.vehicle ? `${order.vehicle.plate_number} (${order.vehicle.type})` : '-' },
    { label: 'Driver:', value: order.driver?.full_name || '-' },
    { label: 'Driver Phone:', value: order.driver?.phone || '-' },
    { label: 'Driver Email:', value: order.driver?.email || '-' },
    { label: 'Status:', value: order.status.toUpperCase() }
  ];

  const labelX = margin;
  const valueX = margin + 300;
  const lineHeight = 60;

  details.forEach((detail) => {
    ctx.fillText(detail.label, labelX, currentY);
    ctx.fillText(String(detail.value || ''), valueX, currentY);
    currentY += lineHeight;
  });

  if (template.footer_image) {
    try {
      const footerImg = await loadImage(template.footer_image);
      // Use original dimensions
      const footerWidth = footerImg.width;
      const footerHeight = footerImg.height;

      const footerY = canvas.height - margin - footerHeight;
      const footerX = pageWidth - margin - footerWidth;
      
      ctx.drawImage(footerImg, footerX, footerY, footerWidth, footerHeight);
    } catch (error) {
      console.error('Failed to load footer image:', error);
    }
  }

  const link = document.createElement('a');
  link.download = `receipt-${order.id}.jpg`;
  link.href = canvas.toDataURL('image/jpeg', 1.0);
  link.click();
}

// Helper function to load images with CORS support
function loadImage(src: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => resolve(img);
    img.onerror = () => reject(new Error('Failed to load image'));
    img.src = src;
  });
}