import { Vehicle } from './vehicle';

export interface DriverVehicleAssignment {
  id: string;
  driver_id: string;
  vehicle_id: string;
  assigned_at: string;
  is_primary: boolean;
  vehicle: Vehicle;
}

export interface VehicleAssignmentService {
  assignVehicleToDriver: (vehicleId: string, isPrimary?: boolean) => Promise<DriverVehicleAssignment>;
  unassignVehicle: (vehicleId: string) => Promise<void>;
  getVehicleAssignment: (vehicleId: string) => Promise<DriverVehicleAssignment | null>;
  getAssignedVehicles: () => Promise<DriverVehicleAssignment[]>;
  setPrimaryVehicle: (vehicleId: string) => Promise<void>;
}