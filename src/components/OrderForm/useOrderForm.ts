import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { createOrder } from '../../services/order';
import { validateFormData } from '../../utils/validation/formValidation';
import { orderSchema } from '../../utils/validation/orderValidation';
import { getOrderFormData } from '../../utils/forms/orderForm';
import type { FormEvent } from 'react';

export function useOrderForm() {
  const navigate = useNavigate();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);
    setErrors({});

    try {
      // Get form data and validate vehicle selection
      let formData;
      try {
        formData = getOrderFormData(e.currentTarget);
      } catch (error) {
        const message = error instanceof Error ? error.message : 'Invalid vehicle selection';
        setErrors({ vehicle_id: message });
        toast.error(message);
        setIsSubmitting(false);
        return;
      }

      // Validate all form fields
      const validation = validateFormData(orderSchema, formData);

      if (!validation.success) {
        setErrors(validation.errors);
        toast.error('Please fill in all required fields');
        setIsSubmitting(false);
        return;
      }

      // Create order
      await createOrder(validation.data);
      toast.success('Order created successfully');
      navigate('/orders');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'An unexpected error occurred';
      toast.error(message);
      if (message.includes('vehicle')) {
        setErrors({ vehicle_id: message });
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  return {
    isSubmitting,
    errors,
    handleSubmit
  };
}