import { z } from 'zod';

export function validateFormData<T>(
  schema: z.Schema<T>,
  data: unknown
): { success: true; data: T } | { success: false; errors: Record<string, string> } {
  const result = schema.safeParse(data);
  
  if (!result.success) {
    const errors = result.error.errors.reduce((acc, error) => ({
      ...acc,
      [error.path[0]]: error.message
    }), {});

    return {
      success: false,
      errors
    };
  }

  return {
    success: true,
    data: result.data
  };
}