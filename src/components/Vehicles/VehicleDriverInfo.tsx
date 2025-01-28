import { useState, useEffect } from 'react';
import { DriverVehicleAssignment } from '../../types/vehicleAssignment';
import { vehicleAssignmentService } from '../../services/vehicleAssignmentService';
import { toast } from 'react-hot-toast';
import { LoadingSpinner } from '../ui/LoadingSpinner';

interface VehicleDriverInfoProps {
  vehicleId: string;
  onUnassigned: () => void;
}

export function VehicleDriverInfo({ vehicleId, onUnassigned }: VehicleDriverInfoProps) {
  const [assignment, setAssignment] = useState<DriverVehicleAssignment | null>(null);
  const [loading, setLoading] = useState(true);

  const loadAssignment = async () => {
    try {
      const data = await vehicleAssignmentService.getVehicleAssignment(vehicleId);
      setAssignment(data);
    } catch (error) {
      // Only log the error, don't show toast for missing assignments
      console.error('Failed to load assignment:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAssignment();
  }, [vehicleId]);

  const handleUnassign = async () => {
    try {
      await vehicleAssignmentService.unassignVehicle(vehicleId);
      setAssignment(null);
      onUnassigned();
      toast.success('Vehicle unassigned successfully');
    } catch (error) {
      toast.error('Failed to unassign vehicle');
    }
  };

  if (loading) {
    return <LoadingSpinner />;
  }

  if (!assignment) {
    return <div className="text-sm text-gray-500">Not assigned</div>;
  }

  return (
    <div className="flex items-center space-x-2">
      <span className="text-sm font-medium text-gray-900">
        {assignment.is_primary ? 'Primary Vehicle' : 'Assigned'}
      </span>
      <button
        onClick={handleUnassign}
        className="text-xs text-red-600 hover:text-red-900"
      >
        Unassign
      </button>
    </div>
  );
}