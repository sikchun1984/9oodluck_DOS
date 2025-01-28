export function validateRequiredFields<T extends Record<string, unknown>>(
  data: T,
  requiredFields: string[]
): string[] {
  return requiredFields.filter(field => !data[field as keyof T]);
}