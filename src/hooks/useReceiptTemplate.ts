import { useState, useCallback, useEffect } from 'react';
import { ReceiptTemplate } from '../types';
import { getTemplate, saveTemplate, DEFAULT_TEMPLATE } from '../services/receipt/templateService';
import { uploadImage } from '../services/receipt/imageService';
import { AppError } from '../utils/error';

export function useReceiptTemplate() {
  const [template, setTemplate] = useState<ReceiptTemplate>(DEFAULT_TEMPLATE);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadTemplate = useCallback(async () => {
    try {
      const data = await getTemplate();
      setTemplate(data || DEFAULT_TEMPLATE);
      setError(null);
    } catch (err) {
      const error = err instanceof AppError ? err : new AppError('Failed to load template');
      console.error('Failed to load template:', error);
      setError(error.message);
      setTemplate(DEFAULT_TEMPLATE);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadTemplate();
  }, [loadTemplate]);

  const handleImageUpload = useCallback(async (file: File, type: 'logo' | 'footer') => {
    try {
      const url = await uploadImage(file, type);
      setTemplate(prev => ({
        ...prev,
        [type === 'logo' ? 'logo' : 'footer_image']: url
      }));
      return url;
    } catch (error) {
      throw error;
    }
  }, []);

  const handleSaveTemplate = async () => {
    try {
      setSaving(true);
      const savedTemplate = await saveTemplate(template);
      setTemplate(savedTemplate);
    } catch (error) {
      throw error;
    } finally {
      setSaving(false);
    }
  };

  return {
    template,
    loading,
    error,
    updateTemplate: setTemplate,
    uploadLogo: (file: File) => handleImageUpload(file, 'logo'),
    uploadLicenseImage: (file: File) => uploadImage(file, 'license'),
    uploadFooterImage: (file: File) => handleImageUpload(file, 'footer'),
    saving,
    saveTemplate: handleSaveTemplate,
  };
}