-- =============================================
-- Migration: 005_create_bookings
-- Description: Create bookings table for user reservations
-- Author: Claude Code
-- Date: 2024-12-14
-- =============================================

-- Create bookings table
CREATE TABLE IF NOT EXISTS public.bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  
  -- Booking references
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  court_id UUID NOT NULL REFERENCES public.courts(id) ON DELETE RESTRICT,
  center_id UUID NOT NULL REFERENCES public.centers(id) ON DELETE RESTRICT,
  
  -- Booking details
  booking_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_minutes INTEGER GENERATED ALWAYS AS (
    EXTRACT(EPOCH FROM (end_time - start_time)) / 60
  ) STORED,
  
  -- Player information
  player_count INTEGER CHECK (player_count >= 1 AND player_count <= 4) DEFAULT 2,
  players JSONB DEFAULT '[]', -- Array of player objects {name, phone, email}
  skill_level TEXT CHECK (skill_level IN ('débutant', 'intermédiaire', 'avancé', 'expert')),
  
  -- Pricing information
  base_price DECIMAL(8,2) NOT NULL,
  taxes DECIMAL(8,2) DEFAULT 0,
  discount DECIMAL(8,2) DEFAULT 0,
  total_price DECIMAL(8,2) NOT NULL,
  currency TEXT DEFAULT 'EUR',
  
  -- Booking status
  status TEXT CHECK (status IN (
    'pending',      -- Just created, awaiting payment
    'confirmed',    -- Payment received, booking confirmed
    'paid',         -- Alternative status for confirmed bookings
    'cancelled',    -- Cancelled by user or center
    'completed',    -- Booking has been played
    'no_show',      -- User didn't show up
    'refunded'      -- Booking was refunded
  )) DEFAULT 'pending',
  
  -- Payment information
  payment_status TEXT CHECK (payment_status IN (
    'pending',
    'processing',
    'paid',
    'failed',
    'refunded',
    'cancelled'
  )) DEFAULT 'pending',
  payment_method TEXT, -- 'card', 'paypal', 'apple_pay', etc.
  payment_id TEXT, -- Stripe payment intent ID or similar
  payment_date TIMESTAMP WITH TIME ZONE,
  
  -- Additional services
  equipment_rental JSONB DEFAULT '{}', -- {rackets: 2, balls: 1, etc.}
  additional_services JSONB DEFAULT '{}', -- coaching, towels, etc.
  
  -- Special requests and notes
  special_requests TEXT,
  internal_notes TEXT, -- Only visible to center managers
  public_notes TEXT, -- Visible to users
  
  -- Cancellation information
  cancelled_at TIMESTAMP WITH TIME ZONE,
  cancelled_by UUID REFERENCES public.user_profiles(id),
  cancellation_reason TEXT,
  cancellation_fee DECIMAL(6,2) DEFAULT 0,
  
  -- Check-in information
  checked_in_at TIMESTAMP WITH TIME ZONE,
  checked_in_by UUID REFERENCES public.user_profiles(id),
  
  -- Reminder and notification tracking
  reminder_sent_at TIMESTAMP WITH TIME ZONE,
  confirmation_sent_at TIMESTAMP WITH TIME ZONE,
  
  -- Rating and review (filled after completion)
  user_rating INTEGER CHECK (user_rating >= 1 AND user_rating <= 5),
  user_review TEXT,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Constraints
  CHECK (end_time > start_time),
  CHECK (booking_date >= CURRENT_DATE),
  CHECK (total_price >= 0),
  UNIQUE(court_id, booking_date, start_time) -- Prevent double bookings
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_court_id ON public.bookings(court_id);
CREATE INDEX IF NOT EXISTS idx_bookings_center_id ON public.bookings(center_id);
CREATE INDEX IF NOT EXISTS idx_bookings_date_time ON public.bookings(booking_date, start_time);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_payment_status ON public.bookings(payment_status);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON public.bookings(created_at);
CREATE INDEX IF NOT EXISTS idx_bookings_payment_id ON public.bookings(payment_id);

-- Enable Row Level Security
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Create policies for bookings
-- Users can view their own bookings
CREATE POLICY "Users can view own bookings" ON public.bookings
  FOR SELECT USING (auth.uid() = user_id);

-- Center managers can view bookings for their centers
CREATE POLICY "Center managers can view their bookings" ON public.bookings
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.centers 
      WHERE centers.id = bookings.center_id 
      AND centers.manager_user_id = auth.uid()
    )
  );

-- Users can create their own bookings
CREATE POLICY "Users can create own bookings" ON public.bookings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own bookings (limited fields)
CREATE POLICY "Users can update own bookings" ON public.bookings
  FOR UPDATE USING (
    auth.uid() = user_id 
    AND status IN ('pending', 'confirmed', 'paid')
  );

-- Center managers can update bookings for their centers
CREATE POLICY "Center managers can update their bookings" ON public.bookings
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.centers 
      WHERE centers.id = bookings.center_id 
      AND centers.manager_user_id = auth.uid()
    )
  );

-- Function to validate booking availability
CREATE OR REPLACE FUNCTION public.validate_booking_availability()
RETURNS TRIGGER AS $$
DECLARE
  is_available BOOLEAN;
  court_active BOOLEAN;
  center_active BOOLEAN;
BEGIN
  -- Check if court and center are active
  SELECT c.is_active, centers.is_active 
  INTO court_active, center_active
  FROM public.courts c
  JOIN public.centers centers ON centers.id = c.center_id
  WHERE c.id = NEW.court_id;
  
  IF NOT court_active OR NOT center_active THEN
    RAISE EXCEPTION 'Court or center is not active';
  END IF;
  
  -- Check availability using our function
  is_available := public.is_court_available(
    NEW.court_id,
    NEW.booking_date,
    NEW.start_time,
    NEW.end_time
  );
  
  IF NOT is_available THEN
    RAISE EXCEPTION 'Court is not available for the requested time slot';
  END IF;
  
  -- Set center_id from court if not provided
  IF NEW.center_id IS NULL THEN
    SELECT center_id INTO NEW.center_id FROM public.courts WHERE id = NEW.court_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to validate booking availability
DROP TRIGGER IF EXISTS validate_booking_availability ON public.bookings;
CREATE TRIGGER validate_booking_availability
  BEFORE INSERT OR UPDATE OF court_id, booking_date, start_time, end_time ON public.bookings
  FOR EACH ROW EXECUTE PROCEDURE public.validate_booking_availability();

-- Function to calculate total price
CREATE OR REPLACE FUNCTION public.calculate_booking_total()
RETURNS TRIGGER AS $$
DECLARE
  calculated_base_price DECIMAL;
  equipment_cost DECIMAL := 0;
  services_cost DECIMAL := 0;
BEGIN
  -- Calculate base price using court pricing
  calculated_base_price := public.calculate_court_price(
    NEW.court_id,
    NEW.booking_date,
    NEW.start_time,
    NEW.duration_minutes::DECIMAL / 60
  );
  
  -- Set base price if not provided
  IF NEW.base_price IS NULL THEN
    NEW.base_price := calculated_base_price;
  END IF;
  
  -- Calculate equipment and services costs (simplified)
  -- In a real implementation, you'd have separate pricing tables
  
  -- Calculate total
  NEW.total_price := NEW.base_price + NEW.taxes - NEW.discount + equipment_cost + services_cost;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to calculate total price
DROP TRIGGER IF EXISTS calculate_booking_total ON public.bookings;
CREATE TRIGGER calculate_booking_total
  BEFORE INSERT OR UPDATE ON public.bookings
  FOR EACH ROW EXECUTE PROCEDURE public.calculate_booking_total();

-- Trigger to update time slots when booking changes
DROP TRIGGER IF EXISTS update_slot_booking_status ON public.bookings;
CREATE TRIGGER update_slot_booking_status
  AFTER INSERT OR UPDATE OR DELETE ON public.bookings
  FOR EACH ROW EXECUTE PROCEDURE public.update_slot_booking_status();

-- Function to automatically update booking status based on payment
CREATE OR REPLACE FUNCTION public.update_booking_status()
RETURNS TRIGGER AS $$
BEGIN
  -- Auto-confirm booking when payment is successful
  IF NEW.payment_status = 'paid' AND OLD.payment_status != 'paid' THEN
    NEW.status := 'confirmed';
    NEW.payment_date := TIMEZONE('utc'::text, NOW());
  END IF;
  
  -- Mark as cancelled if payment failed after certain time
  IF NEW.payment_status = 'failed' THEN
    NEW.status := 'cancelled';
    NEW.cancelled_at := TIMEZONE('utc'::text, NOW());
    NEW.cancellation_reason := 'Payment failed';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update booking status based on payment
DROP TRIGGER IF EXISTS update_booking_status ON public.bookings;
CREATE TRIGGER update_booking_status
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE PROCEDURE public.update_booking_status();

-- Trigger to automatically update updated_at
DROP TRIGGER IF EXISTS handle_updated_at ON public.bookings;
CREATE TRIGGER handle_updated_at
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- Grant necessary permissions
GRANT ALL ON public.bookings TO authenticated;
-- No read access for anonymous users (booking data is private)