import React from 'react';
import { toast } from 'react-hot-toast';
import { vehicleAssignmentService } from '../../services/vehicleAssignmentService';
import { DriverVehicleAssignment } from '../../types/vehicleAssignment';

export function VehicleAssignmentList() {
  const [assignments, setAssignments] = React.useState<DriverVehicleAssignment[]>([]);
  const [loading, setLoading] = React.useState(true);

  const loadAssignments = React.useCallback(async () => {
    try {
      const data = await vehicleAssignmentService.getAssignedVehicles();
      setAssignments(data);
    } catch (error) {
      toast.error('Failed to load vehicle assignments');
    } finally {
      setLoading(false);
    }
  }, []);

  React.useEffect(() => {
    loadAssignments();
  }, [loadAssignments]);

  const handleSetPrimary = async (vehicleId: string) => {
    try {
      await vehicleAssignmentService.setPrimaryVehicle(vehicleId);
      await loadAssignments();
      toast.success('Primary vehicle updated');
    } catch (error) {
      toast.error('Failed to update primary vehicle');
    }
  };

  const handleUnassign = async (vehicleId: string) => {
    try {
      await vehicleAssignmentService.unassignVehicle(vehicleId);
      await loadAssignments();
      toast.success('Vehicle unassigned');
    } catch (error) {
      toast.error('Failed to unassign vehicle');
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="mt-8">
      <h3 className="text-lg font-medium text-gray-900">Assigned Vehicles</h3>
      <div className="mt-4 overflow-hidden shadow ring-1 ring-black ring-opacity-5 sm:rounded-lg">
        <table className="min-w-full divide-y divide-gray-300">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">Vehicle</th>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">Status</th>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 bg-white">
            {assignments.map((assignment) => (
              <tr key={assignment.id}>
                <td className="px-6 py-4 text-sm text-gray-900">
                  {assignment.vehicle.plate_number} - {assignment.vehicle.model}
                </td>
                <td className="px-6 py-4 text-sm text-gray-500">
                  {assignment.is_primary ? (
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      Primary
                    </span>
                  ) : 'Secondary'}
                </td>
                <td className="px-6 py-4 text-sm">
                  {!assignment.is_primary && (
                    <button
                      onClick={() => handleSetPrimary(assignment.vehicle_id)}
                      className="text-indigo-600 hover:text-indigo-900 mr-4"
                    >
                      Set as Primary
                    </button>
                  )}
                  <button
                    onClick={() => handleUnassign(assignment.vehicle_id)}
                    className="text-red-600 hover:text-red-900"
                  >
                    Unassign
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}