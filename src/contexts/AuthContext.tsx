import React, { createContext, useContext, useEffect, useState } from 'react';
import { User } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';

interface AuthContextType {
  user: User | null;
  loading: boolean;
  role: string | null;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [role, setRole] = useState<string | null>(null);

  const loadRole = async (userId: string, retryCount = 0) => {
    const MAX_RETRIES = 3;
    const RETRY_DELAY = 2000; // Increase delay between retries

    try {
      const { data, error } = await supabase
        .from('drivers')
        .select('role')
        .eq('id', userId)
        .single();

      if (error) {
        if (error.message.includes('JWT expired')) {
          await supabase.auth.signOut();
          setUser(null);
          setRole(null);
          return;
        }
        throw error;
      }

      setRole(data?.role || null);
    } catch (error) {
      console.error('Error loading role:', error);
      if (retryCount < MAX_RETRIES && navigator.onLine) {
        setTimeout(() => {
          loadRole(userId, retryCount + 1);
        }, RETRY_DELAY * (retryCount + 1));
      } else {
        // Only set role to null if we're out of retries or offline
        setRole(null); 
        if (!navigator.onLine) {
          console.log('Network appears to be offline');
        }
      }
    }
  };

  useEffect(() => {
    let mounted = true;

    const initializeAuth = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!mounted) return;

        setUser(session?.user || null);
        if (session?.user) {
          loadRole(session.user.id);
        }
        setLoading(false);
      } catch (error) {
        console.error('Auth initialization error:', error);
        if (mounted) {
          setLoading(false);
        }
      }
    };

    initializeAuth();

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (mounted) {
        setUser(session?.user || null);
        if (session?.user) {
          loadRole(session.user.id);
        } else {
          setRole(null);
        }
        setLoading(false);
      }
    });

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, []);

  return (
    <AuthContext.Provider value={{ user, loading, role }}>
      {children}
    </AuthContext.Provider>
  );
}