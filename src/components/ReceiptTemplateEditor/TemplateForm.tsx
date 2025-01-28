import { ReceiptTemplate } from '../../types';
import { ImageUpload } from './ImageUpload';

interface TemplateFormProps {
  template: ReceiptTemplate;
  onChange: (template: ReceiptTemplate) => void;
  onSave: () => Promise<void>;
  saving: boolean;
  onUploadLicenseImage: (file: File) => Promise<string>;
  onUploadFooterImage: (file: File) => Promise<string>;
}

export function TemplateForm({ 
  template, 
  onChange, 
  onSave, 
  saving,
  onUploadLicenseImage,
  onUploadFooterImage 
}: TemplateFormProps) {
  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    onChange({ ...template, [name]: value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await onSave();
    } catch (error) {
      console.error('Failed to save template:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="company_name_zh" className="block text-sm font-medium text-gray-700">
          公司名稱 (中文)
        </label>
        <input
          type="text"
          name="company_name_zh"
          id="company_name_zh"
          value={template.company_name_zh || ''}
          onChange={handleChange}
          className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        />
      </div>

      <div>
        <label htmlFor="company_name" className="block text-sm font-medium text-gray-700">
          Company Name (English)
        </label>
        <input
          type="text"
          name="company_name"
          id="company_name"
          value={template.company_name}
          onChange={handleChange}
          className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        />
      </div>

      <div>
        <label htmlFor="address" className="block text-sm font-medium text-gray-700">
          Address
        </label>
        <textarea
          name="address"
          id="address"
          rows={3}
          value={template.address}
          onChange={handleChange}
          className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        />
      </div>

      <div>
        <label htmlFor="phone" className="block text-sm font-medium text-gray-700">
          Phone
        </label>
        <input
          type="text"
          name="phone"
          id="phone"
          value={template.phone}
          onChange={handleChange}
          className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        />
      </div>

      <div>
        <ImageUpload
          label="License Image"
          description="Upload your business license image (PNG, JPG up to 2MB)"
          currentImage={template.license_image}
          onUpload={onUploadLicenseImage}
        />
      </div>

      <div>
        <ImageUpload
          label="Footer Image"
          description="Upload an image to be displayed in the footer (PNG, JPG, GIF up to 2MB)"
          currentImage={template.footer_image}
          onUpload={onUploadFooterImage}
        />
      </div>

      <div className="pt-5">
        <button
          type="submit"
          disabled={saving}
          className="w-full inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
        >
          {saving ? 'Saving...' : 'Save Template'}
        </button>
      </div>
    </form>
  );
}