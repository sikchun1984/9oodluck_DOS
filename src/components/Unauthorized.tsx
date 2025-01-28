import { Link } from 'react-router-dom';
import { useNavigate } from 'react-router-dom';
import { authService } from '../services/authService';
import { toast } from 'react-hot-toast';

export function Unauthorized() {
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
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8 text-center">
        <h2 className="mt-6 text-3xl font-extrabold text-gray-900">
          未經授權的訪問
        </h2>
        <p className="mt-2 text-sm text-gray-600">
          您沒有權限訪問此頁面。請聯繫管理員或返回首頁。
        </p>
        <div className="mt-5 space-y-3">
          <Link
            to="/"
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 w-full justify-center"
          >
            返回首頁
          </Link>
          <button
            onClick={handleLogout}
            className="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 w-full justify-center"
          >
            登出
          </button>
        </div>
      </div>
    </div>
  );
}