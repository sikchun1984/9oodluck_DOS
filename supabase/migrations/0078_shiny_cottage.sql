/*
  # Add all roles to admin user

  1. Changes
    - Add admin, driver, and dispatcher roles to specified user
    
  2. Security
    - Maintains existing RLS policies
*/

-- Add all roles to the specified user
INSERT INTO user_roles (user_id, role)
SELECT 
  d.id,
  r.role
FROM drivers d
CROSS JOIN (
  VALUES 
    ('admin'),
    ('driver'),
    ('dispatcher')
) AS r(role)
WHERE d.email = '9oodluckgroup@gmail.com'
ON CONFLICT (user_id, role) DO NOTHING;