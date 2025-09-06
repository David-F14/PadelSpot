-- =============================================
-- Migration: 002_create_centers
-- Description: Create centers table for padel centers
-- Author: Claude Code
-- Date: 2024-12-14
-- =============================================

-- Create centers table
CREATE TABLE IF NOT EXISTS public.centers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  
  -- Basic information
  name TEXT NOT NULL,
  description TEXT,
  slug TEXT UNIQUE NOT NULL, -- URL-friendly version of name
  
  -- Contact information
  email TEXT,
  phone TEXT,
  website TEXT,
  
  -- Address
  address_line1 TEXT NOT NULL,
  address_line2 TEXT,
  city TEXT NOT NULL,
  postal_code TEXT NOT NULL,
  country TEXT DEFAULT 'France' NOT NULL,
  
  -- Geographic coordinates for distance calculations
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  
  -- Business hours (stored as JSONB for flexibility)
  opening_hours JSONB DEFAULT '{
    "monday": {"open": "08:00", "close": "22:00", "closed": false},
    "tuesday": {"open": "08:00", "close": "22:00", "closed": false},
    "wednesday": {"open": "08:00", "close": "22:00", "closed": false},
    "thursday": {"open": "08:00", "close": "22:00", "closed": false},
    "friday": {"open": "08:00", "close": "22:00", "closed": false},
    "saturday": {"open": "08:00", "close": "22:00", "closed": false},
    "sunday": {"open": "09:00", "close": "21:00", "closed": false}
  }',
  
  -- Facilities and amenities
  amenities TEXT[] DEFAULT '{}', -- parking, shower, restaurant, etc.
  facilities JSONB DEFAULT '{}', -- detailed facilities info
  
  -- Media
  logo_url TEXT,
  cover_image_url TEXT,
  gallery_images TEXT[] DEFAULT '{}',
  
  -- Business information
  manager_user_id UUID REFERENCES public.user_profiles(id),
  registration_number TEXT, -- SIRET or equivalent
  vat_number TEXT,
  
  -- Status and settings
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  accepts_online_booking BOOLEAN DEFAULT true,
  booking_advance_days INTEGER DEFAULT 30, -- how many days in advance bookings are allowed
  cancellation_policy TEXT,
  
  -- Rating and reviews
  average_rating DECIMAL(2,1) DEFAULT 0.0,
  total_reviews INTEGER DEFAULT 0,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_centers_city ON public.centers(city);
CREATE INDEX IF NOT EXISTS idx_centers_location ON public.centers(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_centers_is_active ON public.centers(is_active);
CREATE INDEX IF NOT EXISTS idx_centers_slug ON public.centers(slug);
CREATE INDEX IF NOT EXISTS idx_centers_manager_user_id ON public.centers(manager_user_id);
CREATE INDEX IF NOT EXISTS idx_centers_average_rating ON public.centers(average_rating);

-- Enable Row Level Security
ALTER TABLE public.centers ENABLE ROW LEVEL SECURITY;

-- Create policies for centers
-- Everyone can view active centers
CREATE POLICY "Everyone can view active centers" ON public.centers
  FOR SELECT USING (is_active = true);

-- Only authenticated users can view inactive centers if they are the manager
CREATE POLICY "Managers can view their centers" ON public.centers
  FOR SELECT USING (auth.uid() = manager_user_id);

-- Only managers can update their own centers
CREATE POLICY "Managers can update own centers" ON public.centers
  FOR UPDATE USING (auth.uid() = manager_user_id);

-- Only authenticated users can create centers (they become the manager)
CREATE POLICY "Authenticated users can create centers" ON public.centers
  FOR INSERT WITH CHECK (auth.uid() = manager_user_id);

-- Function to generate slug from name
CREATE OR REPLACE FUNCTION public.generate_center_slug(center_name TEXT)
RETURNS TEXT AS $$
DECLARE
  base_slug TEXT;
  final_slug TEXT;
  counter INTEGER := 0;
BEGIN
  -- Convert to lowercase and replace spaces with hyphens
  base_slug := LOWER(REGEXP_REPLACE(center_name, '[^a-zA-Z0-9\s]', '', 'g'));
  base_slug := REGEXP_REPLACE(base_slug, '\s+', '-', 'g');
  base_slug := TRIM(base_slug, '-');
  
  final_slug := base_slug;
  
  -- Check for uniqueness and add counter if needed
  WHILE EXISTS (SELECT 1 FROM public.centers WHERE slug = final_slug) LOOP
    counter := counter + 1;
    final_slug := base_slug || '-' || counter;
  END LOOP;
  
  RETURN final_slug;
END;
$$ LANGUAGE plpgsql;

-- Function to automatically generate slug before insert
CREATE OR REPLACE FUNCTION public.handle_center_slug()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.slug IS NULL OR NEW.slug = '' THEN
    NEW.slug := public.generate_center_slug(NEW.name);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically generate slug
DROP TRIGGER IF EXISTS handle_center_slug ON public.centers;
CREATE TRIGGER handle_center_slug
  BEFORE INSERT OR UPDATE ON public.centers
  FOR EACH ROW EXECUTE PROCEDURE public.handle_center_slug();

-- Trigger to automatically update updated_at
DROP TRIGGER IF EXISTS handle_updated_at ON public.centers;
CREATE TRIGGER handle_updated_at
  BEFORE UPDATE ON public.centers
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- Grant necessary permissions
GRANT ALL ON public.centers TO authenticated;
GRANT SELECT ON public.centers TO anon;