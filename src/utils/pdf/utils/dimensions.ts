export function calculateImageDimensions(
  originalWidth: number,
  originalHeight: number,
  maxWidth: number,
  maxHeight: number
) {
  const aspectRatio = originalWidth / originalHeight;
  let width = maxWidth;
  let height = width / aspectRatio;

  if (height > maxHeight) {
    height = maxHeight;
    width = height * aspectRatio;
  }

  return { width, height };
}

export function calculateCenteredPosition(
  containerWidth: number,
  containerHeight: number,
  elementWidth: number,
  elementHeight: number,
  marginBottom = 0
) {
  return {
    x: (containerWidth - elementWidth) / 2,
    y: containerHeight - marginBottom - elementHeight
  };
}