export async function loadImage(src: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.crossOrigin = "anonymous"; // Enable CORS
    img.onload = () => resolve(img);
    img.onerror = (e) => {
      console.error('Image load error:', e);
      reject(new Error('Failed to load image'));
    };
    img.src = src;
  });
}