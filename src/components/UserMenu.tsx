import { Fragment } from 'react';
import { Menu, Transition } from '@headlessui/react';
import { 
  UserCircleIcon, 
  ArrowRightOnRectangleIcon,
  Cog6ToothIcon
} from '@heroicons/react/24/outline';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { authService } from '../services/authService';
import { toast } from 'react-hot-toast';

export function UserMenu() {
  const { user, role } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      await authService.signOut();
      navigate('/login');
      toast.success('已成功登出');
    } catch (error) {
      toast.error('登出失敗');
    }
  };

  return (
    <Menu as="div" className="relative ml-3">
      <Menu.Button className="flex items-center gap-2 px-3 py-2 text-sm rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
        <span className="sr-only">Open user menu</span>
        <UserCircleIcon className="h-8 w-8 text-gray-400" />
        <div className="text-left">
          <div className="text-sm font-medium text-gray-700">{user?.email}</div>
          <div className="text-xs text-gray-500 capitalize">{role || '用戶'}</div>
        </div>
      </Menu.Button>
      <Transition
        as={Fragment}
        enter="transition ease-out duration-100"
        enterFrom="transform opacity-0 scale-95"
        enterTo="transform opacity-100 scale-100"
        leave="transition ease-in duration-75"
        leaveFrom="transform opacity-100 scale-100"
        leaveTo="transform opacity-0 scale-95"
      >
        <Menu.Items className="absolute right-0 w-48 py-1 mt-2 origin-top-right bg-white rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
          <Menu.Item>
            {() => (
              <div className="px-4 py-2 text-sm text-gray-700 border-b border-gray-100">
                <div className="font-medium">{user?.email}</div>
                <div className="text-xs text-gray-500 capitalize">{role || '用戶'}</div>
              </div>
            )}
          </Menu.Item>
          <Menu.Item>
            {({ active }) => (
              <button
                onClick={() => navigate('/settings')}
                className={`${
                  active ? 'bg-gray-100' : ''
                } flex items-center w-full gap-2 px-4 py-2 text-sm text-left text-gray-700`}
              >
                <Cog6ToothIcon className="h-5 w-5" />
                User Management
              </button>
            )}
          </Menu.Item>
          <Menu.Item>
            {({ active }) => (
              <button
                onClick={handleLogout}
                className={`${active ? 'bg-gray-100' : ''
                  } flex items-center w-full gap-2 px-4 py-2 text-sm text-left text-gray-700`}
              >
                <ArrowRightOnRectangleIcon className="h-5 w-5" />
                登出
              </button>
            )}
          </Menu.Item>
        </Menu.Items>
      </Transition>
    </Menu>
  );
}