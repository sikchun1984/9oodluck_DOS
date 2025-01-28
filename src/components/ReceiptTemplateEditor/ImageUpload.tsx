import { useRef } from 'react';
import { toast } from 'react-hot-toast';

interface ImageUploadProps {
  currentImage?: string;
  onUpload: (file: File) => Promise<string>;
  label: string;
  description: string;
}

export function ImageUpload({ currentImage, onUpload, label, description }: ImageUploadProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    
    // Clear input value to allow re-uploading same file
    e.target.value = '';
    
    // Clear input value to allow re-uploading same file
    e.target.value = '';

    // Validate file type
    if (!file.type.startsWith('image/')) {
      toast.error('Please upload an image file');
      return;
    }

    // Validate file size (max 2MB)
    if (file.size > 2 * 1024 * 1024) {
      toast.error('Image must be less than 2MB');
      return;
    }

    try {
      toast.loading('Uploading image...');
      const url = await onUpload(file);
      toast.success('Image uploaded successfully');
      return url;
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to upload image';
      toast.error(message);
      console.error('Upload error:', error);
    }
  };

  return (
    <div>
      <label className="block text-sm font-medium text-gray-700">
        {label}
      </label>
      <div className="mt-1 flex items-center space-x-4">
        {currentImage && (
          <img
            src={currentImage}
            alt={label}
            className="h-16 w-16 object-contain"
            onError={(e) => {
              const target = e.currentTarget as HTMLImageElement;
              if (!target.dataset.retried) {
                target.dataset.retried = 'true';
                target.src = currentImage + '?t=' + new Date().getTime();
              } else {
                target.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40"%3E%3Crect width="40" height="40" fill="%23f3f4f6"/%3E%3C/svg%3E';
              }
            }}
          />
        )}
        <button
          type="button"
          onClick={() => fileInputRef.current?.click()}
          className="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          {currentImage ? 'Change Image' : 'Upload Image'}
        </button>
      </div>
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        accept="image/*"
        className="hidden"
      />
      <p className="mt-2 text-sm text-gray-500">
        {description}
      </p>
    </div>
  );
}