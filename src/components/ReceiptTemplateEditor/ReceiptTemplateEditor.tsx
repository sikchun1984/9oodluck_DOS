import { ImageUpload } from './ImageUpload';
import { TemplateForm } from './TemplateForm';
import { TemplatePreview } from './TemplatePreview';
import { useReceiptTemplate } from '../../hooks/useReceiptTemplate';

export function ReceiptTemplateEditor() {
  const { 
    template, 
    updateTemplate, 
    uploadLogo,
    uploadLicenseImage,
    uploadFooterImage,
    saving,
    saveTemplate 
  } = useReceiptTemplate();

  return (
    <div className="space-y-6">
      <div className="bg-white shadow px-4 py-5 sm:rounded-lg sm:p-6">
        <div className="md:grid md:grid-cols-3 md:gap-6">
          <div className="md:col-span-1">
            <h3 className="text-lg font-medium leading-6 text-gray-900">
              Receipt Template
            </h3>
            <p className="mt-1 text-sm text-gray-500">
              Customize your receipt template and preview how it will look.
            </p>
          </div>
          <div className="mt-5 md:mt-0 md:col-span-2">
            <div className="grid grid-cols-1 gap-6">
              <ImageUpload 
                label="Company Logo"
                currentImage={template.logo}
                onUpload={uploadLogo}
                description="Upload your company logo (PNG, JPG, GIF up to 2MB)"
              />
              <TemplateForm 
                template={template}
                onChange={updateTemplate}
                onUploadLicenseImage={uploadLicenseImage}
                onSave={saveTemplate}
                saving={saving}
                onUploadFooterImage={uploadFooterImage}
              />
            </div>
          </div>
        </div>
      </div>
      <TemplatePreview template={template} />
    </div>
  );
}