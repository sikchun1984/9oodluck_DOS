import { useLocation } from 'react-router-dom';
import { NavLink } from './NavLink';

export function MainNav() {
  const location = useLocation();

  const isActive = (path: string) => {
    return location.pathname === path;
  };

  return (
    <div className="hidden sm:ml-6 sm:flex sm:space-x-8">
      <NavLink to="/orders" isActive={isActive('/orders')}>
        Orders
      </NavLink>
      <NavLink to="/vehicles" isActive={isActive('/vehicles')}>
        Vehicles
      </NavLink>
      <NavLink to="/drivers" isActive={isActive('/drivers')}>
        Drivers
      </NavLink>
      <NavLink to="/settings" isActive={isActive('/settings')}>
        Settings
      </NavLink>
    </div>
  );
}