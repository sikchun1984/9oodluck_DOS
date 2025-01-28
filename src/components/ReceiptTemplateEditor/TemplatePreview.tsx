import { type ReactElement } from 'react';
import { ReceiptTemplate } from '../../types';

interface TemplatePreviewProps {
  template: ReceiptTemplate;
}

export function TemplatePreview({ template }: TemplatePreviewProps): ReactElement {
  return (
    <div className="bg-white shadow sm:rounded-lg">
      <div className="px-4 py-5 sm:p-6">
        <h3 className="text-lg font-medium leading-6 text-gray-900">Preview</h3>
        <div className="mt-4 border p-4">
          <div className="text-center space-y-2">
            {template.logo && (
              <img
                src={template.logo}
                alt="Company logo"
                className="h-16 mx-auto object-contain"
              />
            )}
            <h2 className="text-xl font-bold">{template.company_name}</h2>
            <p className="text-sm text-gray-600">{template.address}</p>
            <p className="text-sm text-gray-600">Tel: {template.phone}</p>
          </div>
          
          <div className="mt-8 border-t pt-4">
            <h3 className="text-lg font-medium text-center">RECEIPT</h3>
            
            <div className="mt-4 space-y-2">
              <div className="grid grid-cols-2 text-sm">
                <span className="text-gray-600">Order ID:</span>
                <span>SAMPLE-123</span>
              </div>
              <div className="grid grid-cols-2 text-sm">
                <span className="text-gray-600">Date:</span>
                <span>{new Date().toLocaleDateString()}</span>
              </div>
            </div>
          </div>

          <div className="mt-8 text-center text-sm text-gray-600">
            {template.footer}
          </div>
        </div>
      </div>
    </div>
  );
}