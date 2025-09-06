-- =============================================
-- Migration: 007_sample_data
-- Description: Sample data for development and testing
-- Author: Claude Code
-- Date: 2024-12-14
-- =============================================

-- WARNING: This file contains sample data for development only
-- DO NOT run this in production!

-- Insert sample centers (you'll need to replace manager_user_id with actual UUIDs)
INSERT INTO public.centers (
  id,
  name,
  description,
  address_line1,
  city,
  postal_code,
  latitude,
  longitude,
  phone,
  email,
  website,
  amenities,
  is_active,
  is_verified,
  average_rating,
  total_reviews
) VALUES 
(
  '550e8400-e29b-41d4-a716-446655440001',
  'Padel Center Paris',
  'Le plus grand centre de padel de Paris avec 6 terrains couverts et extérieurs. Équipements modernes et ambiance conviviale.',
  '15 Avenue des Champs-Élysées',
  'Paris',
  '75008',
  48.8566,
  2.3522,
  '+33 1 42 56 78 90',
  'contact@padelcenterparis.fr',
  'https://padelcenterparis.fr',
  '{"parking", "vestiaires", "douches", "restaurant", "location_materiel", "pro_shop"}',
  true,
  true,
  4.8,
  124
),
(
  '550e8400-e29b-41d4-a716-446655440002',
  'Club Padel Lyon',
  'Centre de padel premium à Lyon avec terrains panoramiques et services haut de gamme.',
  '20 Place Bellecour',
  'Lyon',
  '69002',
  45.7640,
  4.8357,
  '+33 4 78 42 56 78',
  'info@clubpadellyon.fr',
  'https://clubpadellyon.fr',
  '{"parking", "vestiaires", "douches", "sauna", "location_materiel", "cours_particuliers"}',
  true,
  true,
  4.6,
  89
),
(
  '550e8400-e29b-41d4-a716-446655440003',
  'Marseille Padel Club',
  'Club de padel en bord de mer avec vue imprenable et terrains de qualité professionnelle.',
  '30 Quai du Port',
  'Marseille',
  '13002',
  43.2965,
  5.3698,
  '+33 4 91 56 78 90',
  'contact@marseillepadel.fr',
  'https://marseillepadel.fr',
  '{"parking", "vestiaires", "douches", "bar", "location_materiel", "wifi"}',
  true,
  true,
  4.7,
  156
),
(
  '550e8400-e29b-41d4-a716-446655440004',
  'Padel Club Toulouse',
  'Centre moderne avec 4 terrains et académie de formation pour tous niveaux.',
  '45 Rue de Metz',
  'Toulouse',
  '31000',
  43.6047,
  1.4442,
  '+33 5 61 23 45 67',
  'hello@padeltoulouse.fr',
  'https://padeltoulouse.fr',
  '{"parking", "vestiaires", "douches", "location_materiel", "ecole_padel"}',
  true,
  true,
  4.5,
  67
);

-- Insert sample courts for each center
INSERT INTO public.courts (
  id,
  center_id,
  name,
  court_number,
  surface_type,
  court_type,
  base_price_per_hour,
  peak_hours_multiplier,
  weekend_multiplier,
  has_lighting,
  has_heating,
  is_active,
  condition_rating
) VALUES 
-- Paris courts
('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Court Central', 1, 'gazon_synthetique', 'interieur', 30.00, 1.2, 1.1, true, true, true, 5),
('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Court 2', 2, 'gazon_synthetique', 'interieur', 28.00, 1.2, 1.1, true, true, true, 5),
('650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'Court 3', 3, 'gazon_synthetique', 'exterieur', 25.00, 1.2, 1.1, true, false, true, 4),
('650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001', 'Court 4', 4, 'terre_battue', 'exterieur', 25.00, 1.2, 1.1, true, false, true, 4),

-- Lyon courts  
('650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440002', 'Court Panoramique', 1, 'gazon_synthetique', 'semi_couvert', 32.00, 1.3, 1.2, true, true, true, 5),
('650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440002', 'Court Premium', 2, 'gazon_synthetique', 'interieur', 30.00, 1.3, 1.2, true, true, true, 5),
('650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440002', 'Court 3', 3, 'gazon_synthetique', 'exterieur', 26.00, 1.3, 1.2, true, false, true, 4),

-- Marseille courts
('650e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440003', 'Court Mer', 1, 'gazon_synthetique', 'exterieur', 28.00, 1.1, 1.3, true, false, true, 5),
('650e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440003', 'Court Soleil', 2, 'terre_battue', 'exterieur', 26.00, 1.1, 1.3, true, false, true, 4),
('650e8400-e29b-41d4-a716-44665544000a', '550e8400-e29b-41d4-a716-446655440003', 'Court Central', 3, 'gazon_synthetique', 'semi_couvert', 30.00, 1.1, 1.3, true, false, true, 5),

-- Toulouse courts
('650e8400-e29b-41d4-a716-44665544000b', '550e8400-e29b-41d4-a716-446655440004', 'Court Academy', 1, 'gazon_synthetique', 'interieur', 24.00, 1.2, 1.1, true, true, true, 5),
('650e8400-e29b-41d4-a716-44665544000c', '550e8400-e29b-41d4-a716-446655440004', 'Court Training', 2, 'gazon_synthetique', 'interieur', 24.00, 1.2, 1.1, true, true, true, 4),
('650e8400-e29b-41d4-a716-44665544000d', '550e8400-e29b-41d4-a716-446655440004', 'Court Outdoor', 3, 'terre_battue', 'exterieur', 20.00, 1.2, 1.1, true, false, true, 4);

-- Function to generate sample time slots for the next 30 days
CREATE OR REPLACE FUNCTION public.generate_sample_time_slots()
RETURNS TEXT AS $$
DECLARE
  court_record RECORD;
  slots_created INTEGER := 0;
  total_slots INTEGER := 0;
BEGIN
  -- Generate time slots for all courts for the next 30 days
  FOR court_record IN SELECT id FROM public.courts WHERE is_active = true LOOP
    slots_created := public.generate_time_slots_for_court(
      court_record.id,
      CURRENT_DATE,
      (CURRENT_DATE + INTERVAL '30 days')::DATE,
      90 -- 90-minute slots
    );
    total_slots := total_slots + slots_created;
  END LOOP;
  
  RETURN 'Generated ' || total_slots || ' time slots for all courts';
END;
$$ LANGUAGE plpgsql;

-- Generate the sample time slots
SELECT public.generate_sample_time_slots();

-- NOTE: User profiles will be created automatically when real users sign up
-- through Supabase Auth. For now, we'll create centers without managers
-- and you can assign them later when you create real user accounts.

-- For development, you can create users manually via:
-- 1. Supabase Dashboard > Authentication > Users > "Add user"
-- 2. Or sign up through your app once it's running
-- 3. Then update centers with the real user IDs

-- COMMENTED OUT: Sample user data (requires real auth.users entries)
--
-- To test with real users, follow these steps:
-- 1. Go to Supabase Dashboard > Authentication > Users
-- 2. Click "Add user" and create test accounts:
--    - manager.paris@email.com (password: test123456)
--    - manager.lyon@email.com (password: test123456)
--    - manager.marseille@email.com (password: test123456)
--    - admin@padelspot.fr (password: admin123456)
-- 3. Copy their UUIDs and run these updates:
--
-- UPDATE public.centers SET manager_user_id = 'PASTE_PARIS_MANAGER_UUID_HERE' WHERE id = '550e8400-e29b-41d4-a716-446655440001';
-- UPDATE public.centers SET manager_user_id = 'PASTE_LYON_MANAGER_UUID_HERE' WHERE id = '550e8400-e29b-41d4-a716-446655440002';
-- UPDATE public.centers SET manager_user_id = 'PASTE_MARSEILLE_MANAGER_UUID_HERE' WHERE id = '550e8400-e29b-41d4-a716-446655440003';
-- UPDATE public.centers SET manager_user_id = 'PASTE_ADMIN_UUID_HERE' WHERE id = '550e8400-e29b-41d4-a716-446655440004';
--
-- Then update their roles:
-- UPDATE public.user_profiles SET role = 'manager' WHERE id IN ('UUID1', 'UUID2', 'UUID3');
-- UPDATE public.user_profiles SET role = 'admin' WHERE id = 'ADMIN_UUID';

-- NOTE: Sample bookings commented out as they require real user accounts
-- You can create test bookings after setting up real users through authentication

-- COMMENTED OUT: Sample bookings (require real user_ids from auth.users)
--
-- After creating real users, you can add sample bookings like this:
-- INSERT INTO public.bookings (user_id, court_id, center_id, booking_date, start_time, end_time, player_count, base_price, total_price, status, payment_status)
-- VALUES ('REAL_USER_UUID', 'COURT_UUID', 'CENTER_UUID', CURRENT_DATE + 1, '10:00:00', '11:30:00', 2, 30.00, 30.00, 'confirmed', 'paid');

-- Clean up the temporary function
DROP FUNCTION IF EXISTS public.generate_sample_time_slots();

-- Create a view for easy querying of available courts with center info
CREATE OR REPLACE VIEW public.courts_with_centers AS
SELECT 
  c.id as court_id,
  c.name as court_name,
  c.court_number,
  c.surface_type,
  c.court_type,
  c.base_price_per_hour,
  c.has_lighting,
  c.has_heating,
  c.is_active as court_active,
  centers.id as center_id,
  centers.name as center_name,
  centers.city,
  centers.address_line1,
  centers.latitude,
  centers.longitude,
  centers.average_rating,
  centers.amenities,
  centers.is_active as center_active,
  centers.is_verified as center_verified
FROM public.courts c
JOIN public.centers centers ON centers.id = c.center_id;

-- Grant access to the view
GRANT SELECT ON public.courts_with_centers TO authenticated, anon;

-- Success message
SELECT 'Sample data successfully inserted! You can now test the application with realistic data.' as message;