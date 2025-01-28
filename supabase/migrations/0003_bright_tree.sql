/*
  # Add delete policy for orders

  1. Changes
    - Add RLS policy to allow drivers to delete their own orders

  2. Security
    - Only allow drivers to delete their own orders
*/

-- Add delete policy for orders
CREATE POLICY "Drivers can delete own orders"
  ON orders
  FOR DELETE
  TO authenticated
  USING (auth.uid() = driver_id);