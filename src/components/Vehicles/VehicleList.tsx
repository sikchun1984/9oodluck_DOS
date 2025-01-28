import { useState } from 'react';
import { useLocation } from 'react-router-dom';
import { useVehicleList } from './useVehicleList';
import { VehicleTable } from './VehicleTable';
import { LoadingSpinner } from '../ui/LoadingSpinner';
import { VehicleForm } from '../VehicleForm';

export function VehicleList() {
  const location = useLocation();
  const { vehicles, loading, error, refreshVehicles } = useVehicleList();
  const [activeTab, setActiveTab] = useState<'vehicles' | 'add'>(
    location.state?.openAddVehicle ? 'add' : 'vehicles'
  );
  
  const handleTabChange = (tab: 'vehicles' | 'add') => {
    if (tab === 'vehicles') {
      refreshVehicles();
    }
    setActiveTab(tab);
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner />
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600">{error}</p>
        <button
          onClick={refreshVehicles}
          className="mt-4 text-indigo-600 hover:text-indigo-900"
        >
          Try again
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          <button
            onClick={() => handleTabChange('vehicles')}
            className={`${
              activeTab === 'vehicles'
                ? 'border-indigo-500 text-indigo-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
          >
            Vehicles
          </button>
          <button
            onClick={() => handleTabChange('add')}
            className={`${
              activeTab === 'add'
                ? 'border-indigo-500 text-indigo-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
          >
            Add Vehicle
          </button>
        </nav>
      </div>

      {activeTab === 'vehicles' && (
        <VehicleTable 
          vehicles={vehicles} 
          onVehiclesChange={refreshVehicles}
          onAddVehicle={() => handleTabChange('add')}
        />
      )}
      {activeTab === 'add' && (
        <div className="bg-white shadow sm:rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <VehicleForm onSuccess={function() {
              refreshVehicles();
              handleTabChange('vehicles');
            }} />
          </div>
        </div>
      )}
    </div>
  );
}