import { PostgrestError } from '@supabase/supabase-js';
import { AppError } from './types';

export function handleDatabaseError(error: PostgrestError, message?: string): AppError {
  return new AppError(message || error.message || 'Database operation failed', {
    code: error.code,
    details: error.details,
    hint: error.hint
  });
}