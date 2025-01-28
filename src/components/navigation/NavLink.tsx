import React from 'react';
import { Link } from 'react-router-dom';

interface NavLinkProps {
  to: string;
  isActive: boolean;
  children: React.ReactNode;
}

export function NavLink({ to, isActive, children }: NavLinkProps) {
  return (
    <Link
      to={to}
      className={`inline-flex items-center px-1 pt-1 text-sm font-medium ${
        isActive 
          ? 'text-gray-900 border-b-2 border-indigo-500' 
          : 'text-gray-500 hover:text-gray-900 hover:border-b-2 hover:border-gray-300'
      }`}
    >
      {children}
    </Link>
  );
}