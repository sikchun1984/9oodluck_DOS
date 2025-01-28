-- Modify orders table to use text ID instead of UUID
ALTER TABLE orders
ALTER COLUMN id TYPE text;

-- Drop and recreate foreign key constraints that reference orders.id
ALTER TABLE orders
DROP CONSTRAINT IF EXISTS orders_driver_id_fkey,
ADD CONSTRAINT orders_driver_id_fkey 
  FOREIGN KEY (driver_id) 
  REFERENCES drivers(id)
  ON DELETE CASCADE;

-- Add check constraint for order ID format
ALTER TABLE orders
ADD CONSTRAINT orders_id_format_check
CHECK (id ~ '^\d{16}$');

-- Force schema cache refresh
NOTIFY pgrst, 'reload schema';