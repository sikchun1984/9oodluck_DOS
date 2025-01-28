import React from 'react';
import { Dialog } from '@headlessui/react';
import { vehicleAssignmentService } from '../../services/vehicleAssignmentService';
import { toast } from 'react-hot-toast';

interface AssignVehicleModalProps {
  isOpen: boolean;
  onClose: () => void;
  vehicleId: string;
  onAssigned: () => void;
}

export function AssignVehicleModal({
  isOpen,
  onClose,
  vehicleId,
  onAssigned
}: AssignVehicleModalProps) {
  const [isPrimary, setIsPrimary] = React.useState(false);
  const [assigning, setAssigning] = React.useState(false);

  const handleAssign = async () => {
    setAssigning(true);
    try {
      await vehicleAssignmentService.assignVehicleToDriver(vehicleId, isPrimary);
      onAssigned(); // Call this first to trigger state update
      toast.success('Vehicle assigned successfully');
      onClose();
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to assign vehicle';
      toast.error(message);
    } finally {
      setAssigning(false);
    }
  };

  // Reset state when modal opens
  React.useEffect(() => {
    if (isOpen) {
      setIsPrimary(false);
      setAssigning(false);
    }
  }, [isOpen]);

  return (
    <Dialog open={isOpen} onClose={onClose} className="relative z-50">
      <div className="fixed inset-0 bg-black/30" aria-hidden="true" />
      
      <div className="fixed inset-0 flex items-center justify-center p-4">
        <Dialog.Panel className="mx-auto max-w-sm rounded bg-white p-6">
          <Dialog.Title className="text-lg font-medium text-gray-900">
            Assign Vehicle
          </Dialog.Title>

          <div className="mt-4">
            <div className="flex items-center">
              <input
                id="primary"
                name="primary"
                type="checkbox"
                checked={isPrimary}
                onChange={(e) => setIsPrimary(e.target.checked)}
                className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
              />
              <label htmlFor="primary" className="ml-2 block text-sm text-gray-900">
                Set as primary vehicle
              </label>
            </div>
          </div>

          <div className="mt-6 flex space-x-3">
            <button
              type="button"
              onClick={handleAssign}
              disabled={assigning}
              className="flex-1 inline-flex justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
            >
              {assigning ? 'Assigning...' : 'Assign'}
            </button>
            <button
              type="button"
              onClick={onClose}
              className="flex-1 inline-flex justify-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
            >
              Cancel
            </button>
          </div>
        </Dialog.Panel>
      </div>
    </Dialog>
  );
}