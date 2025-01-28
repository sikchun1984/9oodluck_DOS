import { jsPDF } from 'jspdf';
import { ReceiptTemplate } from '../../../types';
import { loadImage } from '../utils/imageLoader';
import { calculateImageDimensions, calculateCenteredPosition } from '../utils/dimensions';

export async function addFooter(doc: jsPDF, template: ReceiptTemplate): Promise<void> {
  if (!template.footer_image) return;

  try {
    const img = await loadImage(template.footer_image);
    
    const pageWidth = doc.internal.pageSize.getWidth();
    const pageHeight = doc.internal.pageSize.getHeight();
    const margin = 20;
    
    // Calculate footer image dimensions
    const { width, height } = calculateImageDimensions(
      img.width,
      img.height,
      pageWidth - (margin * 2),
      40 // max height
    );

    // Calculate centered position
    const { x, y } = calculateCenteredPosition(
      pageWidth,
      pageHeight,
      width,
      height,
      margin
    );

    // Add the image to the PDF
    doc.addImage(img, 'PNG', x, y, width, height);
  } catch (error) {
    console.error('Failed to load footer image:', error);
  }
}