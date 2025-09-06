-- =============================================
-- Migration: 004_create_time_slots
-- Description: Create time_slots table for available booking slots
-- Author: Claude Code
-- Date: 2024-12-14
-- =============================================

-- Create time_slots table
CREATE TABLE IF NOT EXISTS public.time_slots (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  court_id UUID NOT NULL REFERENCES public.courts(id) ON DELETE CASCADE,
  
  -- Time slot information
  slot_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_minutes INTEGER GENERATED ALWAYS AS (
    EXTRACT(EPOCH FROM (end_time - start_time)) / 60
  ) STORED,
  
  -- Pricing for this specific slot (can override court default)
  price_override DECIMAL(6,2), -- If null, use court's calculated price
  final_price DECIMAL(6,2) NOT NULL, -- The actual price for this slot
  
  -- Availability status
  is_available BOOLEAN DEFAULT true,
  is_blocked BOOLEAN DEFAULT false, -- Manually blocked by center manager
  block_reason TEXT, -- Reason for blocking (maintenance, event, etc.)
  
  -- Booking information
  is_booked BOOLEAN DEFAULT false,
  booking_id UUID, -- Will be filled when booking is created
  
  -- Special slot types
  slot_type TEXT CHECK (slot_type IN ('regular', 'peak', 'off_peak', 'special_event')) DEFAULT 'regular',
  special_notes TEXT,
  
  -- Recurring slot information
  is_recurring BOOLEAN DEFAULT false,
  recurrence_pattern TEXT, -- 'daily', 'weekly', 'monthly'
  recurrence_end_date DATE,
  parent_slot_id UUID REFERENCES public.time_slots(id),
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  -- Constraints
  CHECK (end_time > start_time),
  CHECK (duration_minutes > 0),
  UNIQUE(court_id, slot_date, start_time)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_time_slots_court_id ON public.time_slots(court_id);
CREATE INDEX IF NOT EXISTS idx_time_slots_date_time ON public.time_slots(slot_date, start_time);
CREATE INDEX IF NOT EXISTS idx_time_slots_is_available ON public.time_slots(is_available);
CREATE INDEX IF NOT EXISTS idx_time_slots_is_booked ON public.time_slots(is_booked);
CREATE INDEX IF NOT EXISTS idx_time_slots_booking_id ON public.time_slots(booking_id);
CREATE INDEX IF NOT EXISTS idx_time_slots_recurring ON public.time_slots(is_recurring, parent_slot_id);

-- Enable Row Level Security
ALTER TABLE public.time_slots ENABLE ROW LEVEL SECURITY;

-- Create policies for time_slots
-- Everyone can view available time slots from active courts/centers
CREATE POLICY "Everyone can view available time slots" ON public.time_slots
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.courts 
      JOIN public.centers ON centers.id = courts.center_id
      WHERE courts.id = time_slots.court_id 
      AND centers.is_active = true
      AND courts.is_active = true
    )
  );

-- Center managers can view all time slots for their courts
CREATE POLICY "Center managers can view their time slots" ON public.time_slots
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.courts 
      JOIN public.centers ON centers.id = courts.center_id
      WHERE courts.id = time_slots.court_id 
      AND centers.manager_user_id = auth.uid()
    )
  );

-- Center managers can manage time slots for their courts
CREATE POLICY "Center managers can manage their time slots" ON public.time_slots
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.courts 
      JOIN public.centers ON centers.id = courts.center_id
      WHERE courts.id = time_slots.court_id 
      AND centers.manager_user_id = auth.uid()
    )
  );

-- Function to generate standard time slots for a court
CREATE OR REPLACE FUNCTION public.generate_time_slots_for_court(
  p_court_id UUID,
  p_start_date DATE,
  p_end_date DATE,
  p_slot_duration_minutes INTEGER DEFAULT 90
)
RETURNS INTEGER AS $$
DECLARE
  loop_date DATE;
  loop_time TIME;
  end_time TIME;
  court_record RECORD;
  center_record RECORD;
  opening_hours JSONB;
  day_name TEXT;
  day_hours JSONB;
  open_time TIME;
  close_time TIME;
  is_closed BOOLEAN;
  calculated_price DECIMAL;
  slots_created INTEGER := 0;
BEGIN
  -- Get court information
  SELECT c.* INTO court_record
  FROM public.courts c
  WHERE c.id = p_court_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Court not found';
  END IF;
  
  -- Get center opening hours
  SELECT centers.opening_hours INTO opening_hours
  FROM public.centers centers 
  WHERE centers.id = court_record.center_id;
  
  -- Loop through each date
  loop_date := p_start_date;
  WHILE loop_date <= p_end_date LOOP
    -- Get day name
    day_name := LOWER(TO_CHAR(loop_date, 'Day'));
    day_name := TRIM(day_name);
    
    -- Get opening hours for this day
    day_hours := opening_hours->day_name;
    
    IF day_hours IS NOT NULL THEN
      is_closed := (day_hours->>'closed')::BOOLEAN;
      
      IF NOT is_closed THEN
        open_time := (day_hours->>'open')::TIME;
        close_time := (day_hours->>'close')::TIME;
        
        -- Generate slots for this day
        loop_time := open_time;
        WHILE loop_time + INTERVAL '1 minute' * p_slot_duration_minutes <= close_time LOOP
          end_time := loop_time + INTERVAL '1 minute' * p_slot_duration_minutes;
          
          -- Calculate price for this slot
          calculated_price := public.calculate_court_price(
            p_court_id,
            loop_date,
            loop_time,
            p_slot_duration_minutes::DECIMAL / 60
          );
          
          -- Insert time slot if it doesn't exist
          INSERT INTO public.time_slots (
            court_id,
            slot_date,
            start_time,
            end_time,
            final_price,
            slot_type
          )
          VALUES (
            p_court_id,
            loop_date,
            loop_time,
            end_time,
            calculated_price,
            CASE 
              WHEN EXTRACT(DOW FROM loop_date) IN (0, 6) THEN 'peak'
              WHEN loop_time >= TIME '18:00' AND loop_time < TIME '21:00' THEN 'peak'
              ELSE 'regular'
            END
          )
          ON CONFLICT (court_id, slot_date, start_time) DO NOTHING;
          
          IF FOUND THEN
            slots_created := slots_created + 1;
          END IF;
          
          -- Move to next time slot
          loop_time := loop_time + INTERVAL '1 minute' * p_slot_duration_minutes;
        END LOOP;
      END IF;
    END IF;
    
    -- Move to next date
    loop_date := loop_date + INTERVAL '1 day';
  END LOOP;
  
  RETURN slots_created;
END;
$$ LANGUAGE plpgsql;

-- Function to automatically set final price if not provided
CREATE OR REPLACE FUNCTION public.handle_time_slot_price()
RETURNS TRIGGER AS $$
BEGIN
  -- Set final price if not provided or if price_override is set
  IF NEW.price_override IS NOT NULL THEN
    NEW.final_price := NEW.price_override;
  ELSIF NEW.final_price IS NULL THEN
    NEW.final_price := public.calculate_court_price(
      NEW.court_id,
      NEW.slot_date,
      NEW.start_time,
      NEW.duration_minutes::DECIMAL / 60
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically set final price
DROP TRIGGER IF EXISTS handle_time_slot_price ON public.time_slots;
CREATE TRIGGER handle_time_slot_price
  BEFORE INSERT OR UPDATE ON public.time_slots
  FOR EACH ROW EXECUTE PROCEDURE public.handle_time_slot_price();

-- Function to update slot availability when booking status changes
CREATE OR REPLACE FUNCTION public.update_slot_booking_status()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    -- Update time slot when booking is created or updated
    UPDATE public.time_slots
    SET 
      is_booked = CASE WHEN NEW.status IN ('confirmed', 'paid') THEN true ELSE false END,
      booking_id = CASE WHEN NEW.status IN ('confirmed', 'paid') THEN NEW.id ELSE NULL END,
      is_available = CASE WHEN NEW.status IN ('confirmed', 'paid') THEN false ELSE true END
    WHERE court_id = NEW.court_id 
      AND slot_date = NEW.booking_date 
      AND start_time = NEW.start_time;
      
    RETURN NEW;
  END IF;
  
  IF TG_OP = 'DELETE' THEN
    -- Update time slot when booking is deleted
    UPDATE public.time_slots
    SET 
      is_booked = false,
      booking_id = NULL,
      is_available = true
    WHERE booking_id = OLD.id;
    
    RETURN OLD;
  END IF;
  
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
DROP TRIGGER IF EXISTS handle_updated_at ON public.time_slots;
CREATE TRIGGER handle_updated_at
  BEFORE UPDATE ON public.time_slots
  FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- Grant necessary permissions
GRANT ALL ON public.time_slots TO authenticated;
GRANT SELECT ON public.time_slots TO anon;