-- Drop existing policies
DROP POLICY IF EXISTS "drivers_select_own" ON drivers;
DROP POLICY IF EXISTS "drivers_update_own" ON drivers;
DROP POLICY IF EXISTS "drivers_insert_own" ON drivers;
DROP POLICY IF EXISTS "orders_access_own" ON orders;

-- Drop role column from drivers
ALTER TABLE drivers DROP COLUMN IF EXISTS role;

-- Create simple ownership-based policies for drivers
CREATE POLICY "drivers_select"
ON drivers
FOR SELECT
TO authenticated
USING (id = auth.uid());

CREATE POLICY "drivers_update"
ON drivers
FOR UPDATE
TO authenticated
USING (id = auth.uid());

CREATE POLICY "drivers_insert"
ON drivers
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Create simple ownership-based policies for orders
CREATE POLICY "orders_select"
ON orders
FOR SELECT
TO authenticated
USING (driver_id = auth.uid());

CREATE POLICY "orders_insert"
ON orders
FOR INSERT
TO authenticated
WITH CHECK (driver_id = auth.uid());

CREATE POLICY "orders_update"
ON orders
FOR UPDATE
TO authenticated
USING (driver_id = auth.uid());

CREATE POLICY "orders_delete"
ON orders
FOR DELETE
TO authenticated
USING (driver_id = auth.uid());

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';