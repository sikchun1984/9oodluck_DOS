export interface ErrorDetails {
  code?: string;
  details?: unknown;
  hint?: string;
}

export class AppError extends Error {
  constructor(
    message: string,
    public readonly details?: ErrorDetails
  ) {
    super(message);
    this.name = 'AppError';
  }

  static fromError(error: unknown): AppError {
    if (error instanceof AppError) {
      return error;
    }
    if (error instanceof Error) {
      return new AppError(error.message);
    }
    return new AppError('An unexpected error occurred');
  }
}