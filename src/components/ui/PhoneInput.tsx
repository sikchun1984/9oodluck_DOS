import { useState } from 'react';

interface PhoneInputProps {
  value: string;
  onChange: (value: string) => void;
  className?: string;
}

const COUNTRY_CODES = [
  { code: '+853', name: '澳門' },
  { code: '+852', name: '香港' },
  { code: '+86', name: '中國' }
];

export function PhoneInput({ value, onChange, className = '' }: PhoneInputProps) {
  const [selectedCode, setSelectedCode] = useState(COUNTRY_CODES[0].code);
  
  const handlePhoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const phoneNumber = e.target.value.replace(/\D/g, '');
    onChange(`${selectedCode}${phoneNumber}`);
  };

  const handleCodeChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const newCode = e.target.value;
    setSelectedCode(newCode);
    const phoneNumber = value.replace(/^\+\d+/, '');
    onChange(`${newCode}${phoneNumber}`);
  };

  const displayValue = value.replace(selectedCode, '') || '';

  return (
    <div className={`flex ${className}`}>
      <select
        value={selectedCode}
        onChange={handleCodeChange}
        className="appearance-none rounded-none relative block w-40 px-3 py-2 border border-r-0 border-gray-300 bg-gray-50 text-gray-500 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
      >
        {COUNTRY_CODES.map(({ code, name }) => (
          <option key={code} value={code}>
            {name} {code}
          </option>
        ))}
      </select>
      <input
        type="tel"
        value={displayValue}
        onChange={handlePhoneChange}
        placeholder="手機號碼"
        className="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
        required
      />
    </div>
  );
}