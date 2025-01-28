-- Update auth.users table to use email instead of phone
UPDATE auth.users
SET email = CONCAT(phone, '@example.com'),
    phone = NULL
WHERE phone IS NOT NULL;

-- Update drivers table to add email column
ALTER TABLE drivers
ADD COLUMN email text;

-- Update existing drivers with email from auth.users
UPDATE drivers d
SET email = u.email
FROM auth.users u
WHERE d.id = u.id;

-- Make email required and unique
ALTER TABLE drivers
ALTER COLUMN email SET NOT NULL,
ADD CONSTRAINT drivers_email_key UNIQUE (email);

-- Drop phone column from drivers
ALTER TABLE drivers
DROP COLUMN phone;