/*
  # Add Permission-Related Indexes

  1. New Indexes
    - Add indexes on user_roles table for faster role lookups
    - Add indexes on orders table for status and date filtering
    - Add composite indexes for common permission checks
  
  2. Performance
    - Optimize role-based permission checks
    - Improve order filtering and sorting
*/

-- Add indexes for user_roles table
CREATE INDEX IF NOT EXISTS idx_user_roles_user_role 
ON user_roles(user_id, role);

CREATE INDEX IF NOT EXISTS idx_user_roles_role 
ON user_roles(role);

-- Add indexes for orders table
CREATE INDEX IF NOT EXISTS idx_orders_status_date 
ON orders(status, date);

CREATE INDEX IF NOT EXISTS idx_orders_driver_status 
ON orders(driver_id, status);

-- Add indexes for drivers table
CREATE INDEX IF NOT EXISTS idx_drivers_email_id 
ON drivers(email, id);

-- Force schema cache refresh
SELECT pg_notify('pgrst', 'reload schema');