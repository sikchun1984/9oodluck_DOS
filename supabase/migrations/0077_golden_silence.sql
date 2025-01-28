/*
  # Add support for multiple roles per user

  1. New Tables
    - `user_roles`: Junction table for users and their roles
      - `user_id` (uuid, references drivers.id)
      - `role` (text, one of: admin, driver, dispatcher)
      - Primary key on (user_id, role)

  2. Changes
    - Move existing roles to the new table
    - Update policies to use new role checking
    - Remove role column from drivers table
    
  3. Security
    - Enable RLS on user_roles table
    - Add policies for role management
*/

-- Create user_roles table
CREATE TABLE user_roles (
  user_id uuid REFERENCES drivers(id) ON DELETE CASCADE,
  role text CHECK (role IN ('admin', 'driver', 'dispatcher')),
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, role)
);

-- Migrate existing roles
INSERT INTO user_roles (user_id, role)
SELECT id, role FROM drivers;

-- Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Create policies for user_roles
CREATE POLICY "Admins can manage roles"
ON user_roles
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'admin'
  )
);

CREATE POLICY "Users can view own roles"
ON user_roles
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Create helper functions
CREATE OR REPLACE FUNCTION auth.has_role(user_id uuid, required_role text)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.user_id = $1
    AND user_roles.role = $2
  );
$$;

CREATE OR REPLACE FUNCTION auth.get_user_roles(user_id uuid)
RETURNS text[]
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT array_agg(role)
  FROM user_roles
  WHERE user_roles.user_id = $1;
$$;

-- Update existing policies to use new role system
DROP POLICY IF EXISTS "orders_admin_access" ON orders;
DROP POLICY IF EXISTS "orders_driver_access" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher_access" ON orders;

CREATE POLICY "orders_admin_access"
ON orders
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'admin'
  )
);

CREATE POLICY "orders_driver_access"
ON orders
FOR ALL
TO authenticated
USING (
  driver_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'driver'
  )
);

CREATE POLICY "orders_dispatcher_access"
ON orders
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = auth.uid()
    AND ur.role = 'dispatcher'
  )
);

-- Now we can safely drop the role column
ALTER TABLE drivers DROP COLUMN role;