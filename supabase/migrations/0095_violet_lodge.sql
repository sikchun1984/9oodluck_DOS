-- Add role column back to drivers table
ALTER TABLE drivers 
ADD COLUMN role text NOT NULL DEFAULT 'driver'
CHECK (role IN ('admin', 'driver', 'dispatcher'));

-- Create index for role column
CREATE INDEX idx_drivers_role ON drivers(role);

-- Set admin role for system admin
UPDATE drivers 
SET role = 'admin'
WHERE email = '9oodluckgroup@gmail.com';

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';