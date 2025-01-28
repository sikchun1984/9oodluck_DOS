import { AppError } from '../error';

interface RetryOptions {
  maxAttempts?: number;
  delayMs?: number;
  ignoreErrors?: string[];
}

export async function retryFetch<T>(
  operation: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const { 
    maxAttempts = 3, 
    delayMs = 1000,
    ignoreErrors = ['PGRST116'] // Don't retry for "no rows" case
  } = options;
  
  let lastError: Error | null = null;
  let attempt = 1;

  while (attempt <= maxAttempts) {
    try {
      return await operation();
    } catch (error) {
      // Don't retry for specific error cases
      if (error instanceof Error && 
          'code' in error && 
          ignoreErrors.includes(error.code as string)) {
        throw error;
      }
      
      lastError = error instanceof Error ? error : new Error('Unknown error');
      
      if (attempt === maxAttempts) break;
      
      await new Promise(resolve => setTimeout(resolve, delayMs * attempt));
      attempt++;
    }
  }

  throw new AppError('Failed to connect to the server. Please check your connection and try again.', {
    details: lastError?.message
  });
}