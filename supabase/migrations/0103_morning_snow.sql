-- Drop existing order policies
DROP POLICY IF EXISTS "orders_admin" ON orders;
DROP POLICY IF EXISTS "orders_driver" ON orders;
DROP POLICY IF EXISTS "orders_dispatcher" ON orders;

-- Create simplified order policies
CREATE POLICY "orders_crud"
ON orders
FOR ALL
TO authenticated
USING (
  -- Users can manage their own orders
  driver_id = auth.uid()
);

CREATE POLICY "orders_read_admin_dispatcher"
ON orders
FOR SELECT
TO authenticated
USING (
  -- Admins and dispatchers can read all orders
  EXISTS (
    SELECT 1 FROM drivers d
    WHERE d.id = auth.uid()
    AND d.role IN ('admin', 'dispatcher')
  )
);

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';