-- Drop existing policies
DROP POLICY IF EXISTS "orders_own_access" ON orders;

-- Create strict order policy with additional checks
CREATE POLICY "orders_own_access"
ON orders
FOR ALL
TO authenticated
USING (
  -- Ensure user can only access their own orders
  driver_id = auth.uid() AND
  -- Additional check to verify driver exists
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.id = orders.driver_id
  )
)
WITH CHECK (
  -- Ensure user can only modify their own orders
  driver_id = auth.uid() AND
  -- Additional check to verify driver exists
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.id = driver_id
  )
);

-- Add composite index for better query performance
CREATE INDEX IF NOT EXISTS idx_orders_driver_vehicle 
ON orders(driver_id, vehicle_id);

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';