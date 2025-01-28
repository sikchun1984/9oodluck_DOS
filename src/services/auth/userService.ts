import { supabase } from '../../lib/supabase';
import { AppError } from '../../utils/error';
import type { User } from '@supabase/supabase-js';

export async function getAuthenticatedUser(): Promise<User> {
  const { data: { user }, error } = await supabase.auth.getUser();
  
  if (error || !user) {
    throw new AppError('Not authenticated');
  }

  return user;
}