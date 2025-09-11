-- =============================================
-- Migration: 006_rls_policies_and_functions
-- Description: Additional RLS policies and utility functions
-- Author: Claude Code
-- Date: 2024-12-14
-- =============================================

-- Create role enum for better user management
CREATE TYPE public.user_role AS ENUM ('player', 'manager', 'admin');

-- Add role column to user_profiles
ALTER TABLE public.user_profiles 
ADD COLUMN IF NOT EXISTS role public.user_role DEFAULT 'player';

-- Create index on role
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);

-- Function to check if user is center manager
CREATE OR REPLACE FUNCTION public.is_center_manager(center_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.centers 
    WHERE centers.id = center_id 
    AND centers.manager_user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_profiles 
    WHERE id = auth.uid() 
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enhanced policies for centers table
DROP POLICY IF EXISTS "Admins can manage all centers" ON public.centers;
CREATE POLICY "Admins can manage all centers" ON public.centers
  FOR ALL USING (public.is_admin());

-- Enhanced policies for courts table  
DROP POLICY IF EXISTS "Admins can manage all courts" ON public.courts;
CREATE POLICY "Admins can manage all courts" ON public.courts
  FOR ALL USING (public.is_admin());

-- Enhanced policies for time_slots table
DROP POLICY IF EXISTS "Admins can manage all time slots" ON public.time_slots;
CREATE POLICY "Admins can manage all time slots" ON public.time_slots
  FOR ALL USING (public.is_admin());

-- Enhanced policies for bookings table
DROP POLICY IF EXISTS "Admins can manage all bookings" ON public.bookings;
CREATE POLICY "Admins can manage all bookings" ON public.bookings
  FOR ALL USING (public.is_admin());

-- Function to get available courts for a date/time range
CREATE OR REPLACE FUNCTION public.get_available_courts(
  p_center_id UUID,
  p_booking_date DATE,
  p_start_time TIME,
  p_end_time TIME
)
RETURNS TABLE (
  court_id UUID,
  court_name TEXT,
  surface_type TEXT,
  court_type TEXT,
  base_price DECIMAL,
  calculated_price DECIMAL,
  has_lighting BOOLEAN,
  image_urls TEXT[]
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    c.surface_type,
    c.court_type,
    c.base_price_per_hour,
    public.calculate_court_price(
      c.id,
      p_booking_date,
      p_start_time,
      EXTRACT(EPOCH FROM (p_end_time - p_start_time)) / 3600
    ),
    c.has_lighting,
    c.image_urls
  FROM public.courts c
  WHERE c.center_id = p_center_id
    AND c.is_active = true
    AND c.is_maintenance = false
    AND public.is_court_available(c.id, p_booking_date, p_start_time, p_end_time);
END;
$$ LANGUAGE plpgsql;

-- Function to search centers by location
CREATE OR REPLACE FUNCTION public.search_centers_by_location(
  p_latitude DECIMAL DEFAULT NULL,
  p_longitude DECIMAL DEFAULT NULL,
  p_city TEXT DEFAULT NULL,
  p_radius_km INTEGER DEFAULT 50,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  description TEXT,
  address_line1 TEXT,
  city TEXT,
  postal_code TEXT,
  phone TEXT,
  website TEXT,
  latitude DECIMAL,
  longitude DECIMAL,
  average_rating DECIMAL,
  total_reviews INTEGER,
  logo_url TEXT,
  cover_image_url TEXT,
  amenities TEXT[],
  distance_km DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    c.description,
    c.address_line1,
    c.city,
    c.postal_code,
    c.phone,
    c.website,
    c.latitude,
    c.longitude,
    c.average_rating,
    c.total_reviews,
    c.logo_url,
    c.cover_image_url,
    c.amenities,
    CASE 
      WHEN p_latitude IS NOT NULL AND p_longitude IS NOT NULL AND c.latitude IS NOT NULL AND c.longitude IS NOT NULL
      THEN ROUND(
        (6371 * acos(
          cos(radians(p_latitude)) * 
          cos(radians(c.latitude)) * 
          cos(radians(c.longitude) - radians(p_longitude)) + 
          sin(radians(p_latitude)) * 
          sin(radians(c.latitude))
        ))::DECIMAL, 2
      )
      ELSE NULL
    END AS distance_km
  FROM public.centers c
  WHERE c.is_active = true
    AND c.is_verified = true
    AND (
      p_city IS NULL 
      OR LOWER(c.city) LIKE LOWER('%' || p_city || '%')
    )
    AND (
      p_latitude IS NULL 
      OR p_longitude IS NULL 
      OR c.latitude IS NULL 
      OR c.longitude IS NULL
      OR (
        6371 * acos(
          cos(radians(p_latitude)) * 
          cos(radians(c.latitude)) * 
          cos(radians(c.longitude) - radians(p_longitude)) + 
          sin(radians(p_latitude)) * 
          sin(radians(c.latitude))
        )
      ) <= p_radius_km
    )
  ORDER BY 
    CASE WHEN p_latitude IS NOT NULL THEN distance_km END ASC,
    c.average_rating DESC,
    c.name ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Function to get user booking statistics
CREATE OR REPLACE FUNCTION public.get_user_booking_stats(p_user_id UUID)
RETURNS TABLE (
  total_bookings INTEGER,
  completed_bookings INTEGER,
  cancelled_bookings INTEGER,
  total_spent DECIMAL,
  favorite_center_id UUID,
  favorite_center_name TEXT,
  average_rating DECIMAL
) AS $$
DECLARE
  favorite_center RECORD;
BEGIN
  -- Get favorite center (most bookings)
  SELECT c.id, c.name INTO favorite_center
  FROM public.bookings b
  JOIN public.centers c ON c.id = b.center_id
  WHERE b.user_id = p_user_id AND b.status IN ('completed', 'confirmed', 'paid')
  GROUP BY c.id, c.name
  ORDER BY COUNT(*) DESC
  LIMIT 1;

  RETURN QUERY
  SELECT 
    COUNT(*)::INTEGER AS total_bookings,
    COUNT(CASE WHEN status = 'completed' THEN 1 END)::INTEGER AS completed_bookings,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END)::INTEGER AS cancelled_bookings,
    COALESCE(SUM(CASE WHEN status IN ('completed', 'confirmed', 'paid') THEN total_price END), 0) AS total_spent,
    favorite_center.id,
    favorite_center.name,
    AVG(CASE WHEN user_rating IS NOT NULL THEN user_rating::DECIMAL END) AS average_rating
  FROM public.bookings
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get center booking statistics
CREATE OR REPLACE FUNCTION public.get_center_booking_stats(
  p_center_id UUID,
  p_start_date DATE DEFAULT NULL,
  p_end_date DATE DEFAULT NULL
)
RETURNS TABLE (
  total_bookings INTEGER,
  confirmed_bookings INTEGER,
  completed_bookings INTEGER,
  cancelled_bookings INTEGER,
  total_revenue DECIMAL,
  average_rating DECIMAL,
  occupancy_rate DECIMAL
) AS $$
DECLARE
  date_filter_start DATE;
  date_filter_end DATE;
BEGIN
  date_filter_start := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '30 days');
  date_filter_end := COALESCE(p_end_date, CURRENT_DATE);

  RETURN QUERY
  WITH booking_stats AS (
    SELECT 
      COUNT(*)::INTEGER AS total_bookings,
      COUNT(CASE WHEN status = 'confirmed' OR status = 'paid' THEN 1 END)::INTEGER AS confirmed_bookings,
      COUNT(CASE WHEN status = 'completed' THEN 1 END)::INTEGER AS completed_bookings,
      COUNT(CASE WHEN status = 'cancelled' THEN 1 END)::INTEGER AS cancelled_bookings,
      COALESCE(SUM(CASE WHEN status IN ('completed', 'confirmed', 'paid') THEN total_price END), 0) AS total_revenue,
      AVG(CASE WHEN user_rating IS NOT NULL THEN user_rating::DECIMAL END) AS average_rating
    FROM public.bookings
    WHERE center_id = p_center_id
      AND booking_date BETWEEN date_filter_start AND date_filter_end
  ),
  occupancy_stats AS (
    SELECT 
      COUNT(ts.id) AS total_slots,
      COUNT(CASE WHEN ts.is_booked THEN 1 END) AS booked_slots
    FROM public.time_slots ts
    JOIN public.courts c ON c.id = ts.court_id
    WHERE c.center_id = p_center_id
      AND ts.slot_date BETWEEN date_filter_start AND date_filter_end
  )
  SELECT 
    bs.total_bookings,
    bs.confirmed_bookings,
    bs.completed_bookings,
    bs.cancelled_bookings,
    bs.total_revenue,
    bs.average_rating,
    CASE 
      WHEN os.total_slots > 0 
      THEN ROUND((os.booked_slots::DECIMAL / os.total_slots::DECIMAL) * 100, 2)
      ELSE 0
    END AS occupancy_rate
  FROM booking_stats bs
  CROSS JOIN occupancy_stats os;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up expired pending bookings
CREATE OR REPLACE FUNCTION public.cleanup_expired_bookings()
RETURNS INTEGER AS $$
DECLARE
  expired_count INTEGER;
BEGIN
  -- Cancel bookings that have been pending for more than 30 minutes
  UPDATE public.bookings 
  SET 
    status = 'cancelled',
    cancelled_at = TIMEZONE('utc'::text, NOW()),
    cancellation_reason = 'Payment timeout'
  WHERE status = 'pending' 
    AND created_at < TIMEZONE('utc'::text, NOW()) - INTERVAL '30 minutes';
  
  GET DIAGNOSTICS expired_count = ROW_COUNT;
  
  RETURN expired_count;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION public.is_center_manager(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_available_courts(UUID, DATE, TIME, TIME) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.search_centers_by_location(DECIMAL, DECIMAL, TEXT, INTEGER, INTEGER) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_user_booking_stats(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_center_booking_stats(UUID, DATE, DATE) TO authenticated;
GRANT EXECUTE ON FUNCTION public.cleanup_expired_bookings() TO authenticated;

-- Create a scheduled job to clean up expired bookings (requires pg_cron extension)
-- This would typically be set up manually in the Supabase dashboard
-- SELECT cron.schedule('cleanup-expired-bookings', '*/5 * * * *', 'SELECT public.cleanup_expired_bookings();');