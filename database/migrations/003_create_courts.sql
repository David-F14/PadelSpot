-- =============================================
-- Migration: 003_create_courts
-- Description: Create courts table for padel courts within centers
-- Author: Claude Code
-- Date: 2024-12-14
-- =============================================

-- Create courts table
CREATE TABLE IF NOT EXISTS public.courts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  center_id UUID NOT NULL REFERENCES public.centers(id) ON DELETE CASCADE,
  
  -- Basic information
  name TEXT NOT NULL, -- e.g., "Court 1", "Court Central"
  description TEXT,
  court_number INTEGER NOT NULL,
  
  -- Court specifications
  surface_type TEXT CHECK (surface_type IN ('terre_battue', 'gazon_synthetique', 'beton_poreux', 'resine')) NOT NULL DEFAULT 'gazon_synthetique',
  court_type TEXT CHECK (court_type IN ('interieur', 'exterieur', 'semi_couvert')) NOT NULL DEFAULT 'exterieur',
  
  -- Dimensions and features
  length_meters DECIMAL(4,2) DEFAULT 20.00, -- Standard padel court is 20x10
  width_meters DECIMAL(4,2) DEFAULT 10.00,
  has_lighting BOOLEAN DEFAULT false,
  has_heating BOOLEAN DEFAULT false,
  has_air_conditioning BOOLEAN DEFAULT false,
  
  -- Equipment and amenities
  equipment JSONB DEFAULT '{}', -- rackets, balls, etc.
  features TEXT[] DEFAULT '{}', -- sound system, scoreboard, etc.
  
  -- Pricing
  base_price_per_hour DECIMAL(6,2) NOT NULL, -- Price in euros
  peak_hours_multiplier DECIMAL(3,2) DEFAULT 1.0, -- Multiplier for peak hours
  weekend_multiplier DECIMAL(3,2) DEFAULT 1.0, -- Multiplier for weekends
  
  -- Peak hours definition (stored as JSONB for flexibility)
  peak_hours JSONB DEFAULT '{
    "weekdays": [{"start": "18:00", "end": "21:00"}],
    "weekends": [{"start": "09:00", "end": "12:00"}, {"start": "14:00", "end": "18:00"}]
  }',
  
  -- Availability
  is_active BOOLEAN DEFAULT true,
  is_maintenance BOOLEAN DEFAULT false,
  maintenance_note TEXT,
  
  -- Images
  image_urls TEXT[] DEFAULT '{}',
  
  -- Quality metrics
  condition_rating INTEGER CHECK (condition_rating >= 1 AND condition_rating <= 5) DEFAULT 5,
  last_maintenance_date DATE,
  next_maintenance_date DATE,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Constraints
  UNIQUE(center_id, court_number)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_courts_center_id ON public.courts(center_id);
CREATE INDEX IF NOT EXISTS idx_courts_is_active ON public.courts(is_active);
CREATE INDEX IF NOT EXISTS idx_courts_surface_type ON public.courts(surface_type);
CREATE INDEX IF NOT EXISTS idx_courts_court_type ON public.courts(court_type);
CREATE INDEX IF NOT EXISTS idx_courts_base_price ON public.courts(base_price_per_hour);

-- Enable Row Level Security
ALTER TABLE public.courts ENABLE ROW LEVEL SECURITY;

-- Create policies for courts
-- Everyone can view courts from active centers
CREATE POLICY "Everyone can view courts from active centers" ON public.courts
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.centers 
      WHERE centers.id = courts.center_id 
      AND centers.is_active = true
    )
  );

-- Center managers can view all their courts
CREATE POLICY "Center managers can view their courts" ON public.courts
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.centers 
      WHERE centers.id = courts.center_id 
      AND centers.manager_user_id = auth.uid()
    )
  );

-- Only center managers can update their courts
CREATE POLICY "Center managers can update their courts" ON public.courts
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.centers 
      WHERE centers.id = courts.center_id 
      AND centers.manager_user_id = auth.uid()
    )
  );

-- Only center managers can create courts for their centers
CREATE POLICY "Center managers can create courts" ON public.courts
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.centers 
      WHERE centers.id = courts.center_id 
      AND centers.manager_user_id = auth.uid()
    )
  );

-- Only center managers can delete their courts
CREATE POLICY "Center managers can delete their courts" ON public.courts
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.centers 
      WHERE centers.id = courts.center_id 
      AND centers.manager_user_id = auth.uid()
    )
  );

-- Function to calculate court price based on time slot
CREATE OR REPLACE FUNCTION public.calculate_court_price(
  court_id UUID,
  booking_date DATE,
  start_time TIME,
  duration_hours DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
  court_record RECORD;
  base_price DECIMAL;
  final_price DECIMAL;
  is_weekend BOOLEAN;
  is_peak_hour BOOLEAN;
  day_of_week INTEGER;
  peak_hours_data JSONB;
BEGIN
  -- Get court information
  SELECT * INTO court_record FROM public.courts WHERE id = court_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Court not found';
  END IF;
  
  base_price := court_record.base_price_per_hour * duration_hours;
  final_price := base_price;
  
  -- Check if it's weekend (Saturday = 6, Sunday = 0)
  day_of_week := EXTRACT(DOW FROM booking_date);
  is_weekend := day_of_week IN (0, 6);
  
  -- Apply weekend multiplier
  IF is_weekend THEN
    final_price := final_price * court_record.weekend_multiplier;
  END IF;
  
  -- Check if it's peak hour
  peak_hours_data := court_record.peak_hours;
  is_peak_hour := false;
  
  -- TODO: Implement peak hour logic based on JSONB data
  -- For now, assume peak hours are 18:00-21:00 on weekdays and 9:00-12:00, 14:00-18:00 on weekends
  IF NOT is_weekend AND start_time >= TIME '18:00' AND start_time < TIME '21:00' THEN
    is_peak_hour := true;
  ELSIF is_weekend AND ((start_time >= TIME '09:00' AND start_time < TIME '12:00') OR (start_time >= TIME '14:00' AND start_time < TIME '18:00')) THEN
    is_peak_hour := true;
  END IF;
  
  -- Apply peak hours multiplier
  IF is_peak_hour THEN
    final_price := final_price * court_record.peak_hours_multiplier;
  END IF;
  
  RETURN ROUND(final_price, 2);
END;
$$ LANGUAGE plpgsql;

-- Function to check court availability
CREATE OR REPLACE FUNCTION public.is_court_available(
  court_id UUID,
  booking_date DATE,
  start_time TIME,
  end_time TIME
)
RETURNS BOOLEAN AS $$
DECLARE
  booking_count INTEGER;
BEGIN
  -- Check if court exists and is active
  IF NOT EXISTS (
    SELECT 1 FROM public.courts 
    WHERE id = court_id 
    AND is_active = true 
    AND is_maintenance = false
  ) THEN
    RETURN false;
  END IF;
  
  -- Check for overlapping bookings
  SELECT COUNT(*) INTO booking_count
  FROM public.bookings
  WHERE bookings.court_id = is_court_available.court_id
    AND bookings.booking_date = is_court_available.booking_date
    AND status NOT IN ('cancelled', 'no_show')
    AND (
      (bookings.start_time < is_court_available.end_time AND bookings.end_time > is_court_available.start_time)
    );
  
  RETURN booking_count = 0;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
DROP TRIGGER IF EXISTS handle_updated_at ON public.courts;
CREATE TRIGGER handle_updated_at
  BEFORE UPDATE ON public.courts
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- Grant necessary permissions
GRANT ALL ON public.courts TO authenticated;
GRANT SELECT ON public.courts TO anon;