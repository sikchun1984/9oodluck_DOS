import { Link } from 'react-router-dom';
import { useReceiptTemplate } from '../../hooks/useReceiptTemplate';
import { LoadingSpinner } from '../ui/LoadingSpinner';

export function CompanyHeader() {
  const { template, loading, error } = useReceiptTemplate();

  if (loading) {
    return (
      <div className="flex-shrink-0 flex items-center h-[91px]">
        <LoadingSpinner />
      </div>
    );
  }

  if (error && !error.includes('no rows')) {
    return (
      <Link to="/" className="flex-shrink-0 flex items-center">
        <h1 className="text-xl font-bold text-gray-900">旅行社</h1>
      </Link>
    );
  }

  return (
    <Link to="/" className="flex-shrink-0 flex items-center">
      {template.logo ? (
        <img
          src={template.logo}
          alt={template.company_name}
          className="h-[91px] w-auto max-w-[200px] object-contain mr-3"
        />
      ) : null}
      <h1 className="text-xl font-bold text-gray-900">
        {template.company_name || '旅行社'}
      </h1>
    </Link>
  );
}