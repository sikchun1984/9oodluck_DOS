import { AuthError } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';

const formatAuthError = (error: AuthError) => {
  if (error.message.includes('Invalid login credentials')) {
    return 'Invalid email or password';
  }
  return 'Operation failed, please try again';
};

export const authService = {
  async signIn(email: string, password: string) {
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
      });

      if (error) throw error;
      return { data, error: null };
    } catch (err) {
      const authError = err as AuthError;
      return { data: null, error: formatAuthError(authError) };
    }
  },

  async signUp(email: string, password: string) {
    try {
      // Validate email format
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        return { data: null, error: 'Invalid email format' };
      }

      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: { role: 'driver' }
        }
      });

      if (error) throw error;
      return { data, error: null };
    } catch (err) {
      const authError = err as AuthError;
      return { data: null, error: formatAuthError(authError) };
    }
  },

  async signOut() {
    return await supabase.auth.signOut();
  },

  async resetPassword(email: string) {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`
    });

    if (error) throw error;
  }
};