import { useState } from 'react';
import { AssignVehicleModal } from './AssignVehicleModal';

interface VehicleListActionsProps {
  vehicleId: string;
  onDelete: () => void;
  onAssigned: () => void;
}

export function VehicleListActions({ 
  vehicleId, 
  onDelete,
  onAssigned 
}: VehicleListActionsProps) {
  const [showAssignModal, setShowAssignModal] = useState(false);

  return (
    <div className="flex space-x-3">
      <button
        onClick={() => setShowAssignModal(true)}
        className="text-indigo-600 hover:text-indigo-900"
      >
        Assign Driver
      </button>
      <button
        onClick={onDelete}
        className="text-red-600 hover:text-red-900"
      >
        Delete
      </button>

      <AssignVehicleModal
        isOpen={showAssignModal}
        onClose={() => setShowAssignModal(false)}
        vehicleId={vehicleId}
        onAssigned={onAssigned}
      />
    </div>
  );
}