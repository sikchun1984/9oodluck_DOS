-- Add created_by column to orders table
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES auth.users(id) ON DELETE CASCADE;

-- Set existing orders' created_by to driver_id
UPDATE orders
SET created_by = driver_id
WHERE created_by IS NULL;

-- Make created_by required
ALTER TABLE orders
ALTER COLUMN created_by SET NOT NULL;

-- Drop existing policies
DROP POLICY IF EXISTS "orders_own_access" ON orders;

-- Create strict order policy
CREATE POLICY "orders_own_access"
ON orders
FOR ALL
TO authenticated
USING (
  -- Users can only access orders they created
  created_by = auth.uid()
)
WITH CHECK (
  -- Users can only create/modify orders as themselves
  created_by = auth.uid()
);

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_orders_created_by ON orders(created_by);

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';