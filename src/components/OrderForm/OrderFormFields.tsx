import { VehicleSelect } from './VehicleSelect/VehicleSelect';
import { DriverSelect } from './DriverSelect';

interface OrderFormFieldsProps {
  disabled: boolean;
  errors?: Record<string, string>;
}

export function OrderFormFields({ disabled, errors = {} }: OrderFormFieldsProps) {
  const getFieldError = (field: string) => errors[field];

  return (
    <div className="space-y-6">
      <div>
        <label htmlFor="passengerName" className="block text-sm font-medium text-gray-700">
          Passenger Name
        </label>
        <input
          type="text"
          name="passengerName"
          id="passengerName"
          required
          disabled={disabled}
          className={`mt-1 block w-full rounded-md shadow-sm focus:border-indigo-500 focus:ring-indigo-500 ${
            errors.passenger_name ? 'border-red-300' : 'border-gray-300'
          }`}
        />
        {errors.passenger_name && (
          <p className="mt-1 text-sm text-red-600">{errors.passenger_name}</p>
        )}
      </div>

      <div>
        <label htmlFor="contact" className="block text-sm font-medium text-gray-700">
          Contact
        </label>
        <input
          type="text"
          name="contact"
          id="contact"
          required
          disabled={disabled}
          className={`mt-1 block w-full rounded-md shadow-sm focus:border-indigo-500 focus:ring-indigo-500 ${
            errors.contact ? 'border-red-300' : 'border-gray-300'
          }`}
        />
        {errors.contact && (
          <p className="mt-1 text-sm text-red-600">{errors.contact}</p>
        )}
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label htmlFor="origin" className="block text-sm font-medium text-gray-700">
            Origin
          </label>
          <input
            type="text"
            name="origin"
            id="origin"
            required
            disabled={disabled}
            className={`mt-1 block w-full rounded-md shadow-sm focus:border-indigo-500 focus:ring-indigo-500 ${
              errors.origin ? 'border-red-300' : 'border-gray-300'
            }`}
          />
          {errors.origin && (
            <p className="mt-1 text-sm text-red-600">{errors.origin}</p>
          )}
        </div>

        <div>
          <label htmlFor="destination" className="block text-sm font-medium text-gray-700">
            Destination
          </label>
          <input
            type="text"
            name="destination"
            id="destination"
            required
            disabled={disabled}
            className={`mt-1 block w-full rounded-md shadow-sm focus:border-indigo-500 focus:ring-indigo-500 ${
              errors.destination ? 'border-red-300' : 'border-gray-300'
            }`}
          />
          {errors.destination && (
            <p className="mt-1 text-sm text-red-600">{errors.destination}</p>
          )}
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label htmlFor="date" className="block text-sm font-medium text-gray-700">
            Date
          </label>
          <input
            type="date"
            name="date"
            id="date"
            required
            disabled={disabled}
            className={`mt-1 block w-full rounded-md shadow-sm focus:border-indigo-500 focus:ring-indigo-500 ${
              errors.date ? 'border-red-300' : 'border-gray-300'
            }`}
          />
          {errors.date && (
            <p className="mt-1 text-sm text-red-600">{errors.date}</p>
          )}
        </div>

        <div>
          <label htmlFor="time" className="block text-sm font-medium text-gray-700">
            Time
          </label>
          <input
            type="time"
            name="time"
            id="time"
            required
            disabled={disabled}
            className={`mt-1 block w-full rounded-md shadow-sm focus:border-indigo-500 focus:ring-indigo-500 ${
              errors.time ? 'border-red-300' : 'border-gray-300'
            }`}
          />
          {errors.time && (
            <p className="mt-1 text-sm text-red-600">{errors.time}</p>
          )}
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label htmlFor="capacity" className="block text-sm font-medium text-gray-700">
            Capacity
          </label>
        </div>
      </div>

      <div>
        <label htmlFor="driverId" className="block text-sm font-medium text-gray-700">
          Driver
        </label>
        <DriverSelect />
        {errors.driver_id && (
          <p className="mt-1 text-sm text-red-600">{errors.driver_id}</p>
        )}
      </div>

      <VehicleSelect 
        disabled={disabled} 
        error={getFieldError('vehicle_id') || getFieldError('vehicle_type')} 
      />
    </div>
  );
}