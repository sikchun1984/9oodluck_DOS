import { useState } from 'react';
import { toast } from 'react-hot-toast';
import { databaseService } from '../../services/databaseService';
import { ReceiptTemplateEditor } from '../ReceiptTemplateEditor/ReceiptTemplateEditor';
import { VehicleTypeManager } from '../Vehicles/VehicleTypeManager';
import { UserManagement } from './UserManagement';
import { LoadingSpinner } from '../ui/LoadingSpinner';

const DATABASE_OPTIONS = [
  { id: 'drivers', label: 'Driver Profile' },
  { id: 'orders', label: 'Orders' },
  { id: 'vehicles', label: 'Vehicles' },
  { id: 'vehicle_types', label: 'Vehicle Types' },
  { id: 'receipt_templates', label: 'Receipt Templates' }
];

export function SettingsPage() {
  const [initializing, setInitializing] = useState(false);
  const [selectedTables, setSelectedTables] = useState<string[]>([]);
  const [activeTab, setActiveTab] = useState<'database' | 'receipt' | 'users' | 'vehicles'>('database');
  const [refreshKey, setRefreshKey] = useState(0);
  
  const handleTabChange = (tab: 'database' | 'receipt' | 'users' | 'vehicles') => {
    setActiveTab(tab);
    setRefreshKey(prev => prev + 1);
  };

  const handleToggleTable = (tableId: string) => {
    setSelectedTables(prev => 
      prev.includes(tableId) 
        ? prev.filter(id => id !== tableId)
        : [...prev, tableId]
    );
  };

  const handleInitializeDatabase = async () => {
    if (selectedTables.length === 0) {
      toast.error('Please select at least one table to initialize');
      return;
    }

    if (!window.confirm('Are you sure you want to initialize the selected tables? This will reset all related data.')) {
      return;
    }

    setInitializing(true);
    try {
      await databaseService.initializeDatabase(selectedTables);
      toast.success('Selected tables initialized successfully');
      setSelectedTables([]);
    } catch (error) {
      toast.error('Failed to initialize database');
    } finally {
      setInitializing(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          <button
            onClick={() => handleTabChange('database')}
            className={`${
              activeTab === 'database'
                ? 'border-indigo-500 text-indigo-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
          >
            Database Settings
          </button>
          <button
            onClick={() => handleTabChange('receipt')}
            className={`${
              activeTab === 'receipt'
                ? 'border-indigo-500 text-indigo-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
          >
            Receipt Template
          </button>
          <button
            onClick={() => handleTabChange('users')}
            className={`${
              activeTab === 'users'
                ? 'border-indigo-500 text-indigo-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
          >
            User Management
          </button>
          <button
            onClick={() => handleTabChange('vehicles')}
            className={`${
              activeTab === 'vehicles'
                ? 'border-indigo-500 text-indigo-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            } whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
          >
            Vehicle Types
          </button>
        </nav>
      </div>

      {activeTab === 'database' && (
        <div className="bg-white shadow px-4 py-5 sm:rounded-lg sm:p-6">
          <div className="md:grid md:grid-cols-3 md:gap-6">
            <div className="md:col-span-1">
              <h3 className="text-lg font-medium leading-6 text-gray-900">
                Database Settings
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                Manage your database configuration and initialization.
              </p>
            </div>
            <div className="mt-5 md:mt-0 md:col-span-2">
              <div className="space-y-6">
                <div>
                  <h4 className="text-sm font-medium text-gray-900">Initialize Database</h4>
                  <p className="mt-1 text-sm text-gray-500">
                    Select the tables you want to initialize. This will clear all existing data in the selected tables.
                  </p>
                  <div className="mt-4 space-y-4">
                    {DATABASE_OPTIONS.map(option => (
                      <div key={option.id} className="flex items-center">
                        <input
                          id={option.id}
                          name={option.id}
                          type="checkbox"
                          checked={selectedTables.includes(option.id)}
                          onChange={() => handleToggleTable(option.id)}
                          disabled={initializing}
                          className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                        />
                        <label htmlFor={option.id} className="ml-3 text-sm text-gray-700">
                          {option.label}
                        </label>
                      </div>
                    ))}
                  </div>
                  <button
                    type="button"
                    onClick={handleInitializeDatabase}
                    disabled={initializing || selectedTables.length === 0}
                    className="mt-4 inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50"
                  >
                    {initializing ? (
                      <>
                        <LoadingSpinner />
                        <span className="ml-2">Initializing...</span>
                      </>
                    ) : (
                      'Initialize Selected Tables'
                    )}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
      
      {activeTab === 'receipt' && (
        <ReceiptTemplateEditor key={`receipt-${refreshKey}`} />
      )}
      
      {activeTab === 'users' && (
        <UserManagement key={`users-${refreshKey}`} />
      )}
      {activeTab === 'vehicles' && (
        <div className="bg-white shadow px-4 py-5 sm:rounded-lg sm:p-6">
          <div className="md:grid md:grid-cols-3 md:gap-6">
            <div className="md:col-span-1">
              <h3 className="text-lg font-medium leading-6 text-gray-900">
                Vehicle Types
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                Manage the types of vehicles available in your system.
              </p>
            </div>
            <div className="mt-5 md:mt-0 md:col-span-2">
              <VehicleTypeManager key={`vehicle-types-${refreshKey}`} />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}