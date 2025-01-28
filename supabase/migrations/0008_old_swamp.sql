/*
  # Add footer image to receipt templates
  
  1. Changes
    - Add footer_image column to receipt_templates table
    - Make footer column nullable since we're transitioning to footer_image
*/

-- Make footer column nullable first
ALTER TABLE receipt_templates 
ALTER COLUMN footer DROP NOT NULL;

-- Add footer_image column
ALTER TABLE receipt_templates 
ADD COLUMN IF NOT EXISTS footer_image text;