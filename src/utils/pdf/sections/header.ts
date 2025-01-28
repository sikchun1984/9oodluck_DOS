import { jsPDF } from 'jspdf';
import { ReceiptTemplate } from '../../../types';
import { loadImage } from '../utils/imageLoader';

export async function addHeader(doc: jsPDF, template: ReceiptTemplate, startY: number): Promise<number> {
  const pageWidth = doc.internal.pageSize.getWidth();
  let currentY = startY;

  // Add logo if exists
  if (template.logo) {
    try {
      const img = await loadImage(template.logo);
      const { width: logoWidth, height: logoHeight } = calculateLogoDimensions(img);
      const logoX = (pageWidth - logoWidth) / 2;
      
      doc.addImage(img, 'PNG', logoX, currentY, logoWidth, logoHeight);
      currentY += logoHeight + 10;
    } catch (error) {
      console.error('Failed to load logo:', error);
    }
  }

  // Add company info
  doc.setFontSize(16);
  doc.text(template.company_name, pageWidth / 2, currentY, { align: 'center' });
  currentY += 8;
  
  doc.setFontSize(10);
  doc.text(template.address, pageWidth / 2, currentY, { align: 'center' });
  currentY += 6;
  doc.text(`Tel: ${template.phone}`, pageWidth / 2, currentY, { align: 'center' });
  currentY += 15;

  // Add receipt title
  doc.setFontSize(14);
  doc.text('RECEIPT', pageWidth / 2, currentY, { align: 'center' });
  currentY += 15;

  return currentY;
}

function calculateLogoDimensions(img: HTMLImageElement) {
  const maxWidth = 40;
  const maxHeight = 40;
  const aspectRatio = img.width / img.height;
  
  let width = maxWidth;
  let height = width / aspectRatio;
  
  if (height > maxHeight) {
    height = maxHeight;
    width = height * aspectRatio;
  }

  return { width, height };
}