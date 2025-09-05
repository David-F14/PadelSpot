export interface Court {
  id: string
  name: string
  center_id: string
  type: 'indoor' | 'outdoor'
  surface: 'glass' | 'concrete' | 'artificial_grass'
  price_per_hour: number
  amenities: string[]
  is_active: boolean
}

export interface Center {
  id: string
  name: string
  address: string
  city: string
  postal_code: string
  latitude: number
  longitude: number
  phone?: string
  email?: string
  website?: string
  opening_hours: Record<string, { open: string; close: string } | null>
  courts: Court[]
}

export interface TimeSlot {
  id: string
  court_id: string
  start_time: string
  end_time: string
  date: string
  price: number
  is_available: boolean
  booking_id?: string
}

export interface Booking {
  id: string
  user_id: string
  court_id: string
  time_slot_id: string
  date: string
  start_time: string
  end_time: string
  total_price: number
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed'
  payment_status: 'pending' | 'paid' | 'refunded'
  created_at: string
  updated_at: string
  court?: Court
  center?: Center
}

export const useBooking = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const selectedCenter = ref<Center | null>(null)
  const selectedCourt = ref<Court | null>(null)
  const selectedDate = ref<string>(new Date().toISOString().split('T')[0])
  const selectedTimeSlot = ref<TimeSlot | null>(null)
  
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // Search centers by location
  const searchCenters = async (query: string, latitude?: number, longitude?: number) => {
    isLoading.value = true
    error.value = null

    try {
      let queryBuilder = supabase
        .from('centers')
        .select('*, courts(*)')
        .eq('is_active', true)

      if (query) {
        queryBuilder = queryBuilder.or(`name.ilike.%${query}%,city.ilike.%${query}%`)
      }

      const { data, error: fetchError } = await queryBuilder

      if (fetchError) throw fetchError

      // Sort by distance if coordinates provided
      if (latitude && longitude && data) {
        data.sort((a, b) => {
          const distA = Math.sqrt(
            Math.pow(a.latitude - latitude, 2) + Math.pow(a.longitude - longitude, 2)
          )
          const distB = Math.sqrt(
            Math.pow(b.latitude - latitude, 2) + Math.pow(b.longitude - longitude, 2)
          )
          return distA - distB
        })
      }

      return data as Center[]
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors de la recherche'
      return []
    } finally {
      isLoading.value = false
    }
  }

  // Get available time slots for a court and date
  const getAvailableSlots = async (courtId: string, date: string) => {
    isLoading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('time_slots')
        .select('*')
        .eq('court_id', courtId)
        .eq('date', date)
        .eq('is_available', true)
        .order('start_time')

      if (fetchError) throw fetchError

      return data as TimeSlot[]
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors du chargement des créneaux'
      return []
    } finally {
      isLoading.value = false
    }
  }

  // Create a booking
  const createBooking = async (timeSlotId: string) => {
    if (!user.value) {
      error.value = 'Vous devez être connecté pour réserver'
      return null
    }

    isLoading.value = true
    error.value = null

    try {
      // First, get the time slot details
      const { data: timeSlot, error: slotError } = await supabase
        .from('time_slots')
        .select('*, court:courts(*)')
        .eq('id', timeSlotId)
        .single()

      if (slotError) throw slotError
      if (!timeSlot.is_available) {
        throw new Error('Ce créneau n\'est plus disponible')
      }

      // Create the booking
      const bookingData = {
        user_id: user.value.id,
        court_id: timeSlot.court_id,
        time_slot_id: timeSlotId,
        date: timeSlot.date,
        start_time: timeSlot.start_time,
        end_time: timeSlot.end_time,
        total_price: timeSlot.price,
        status: 'pending',
        payment_status: 'pending'
      }

      const { data: booking, error: bookingError } = await supabase
        .from('bookings')
        .insert(bookingData)
        .select('*')
        .single()

      if (bookingError) throw bookingError

      // Mark time slot as unavailable
      await supabase
        .from('time_slots')
        .update({ is_available: false, booking_id: booking.id })
        .eq('id', timeSlotId)

      return booking as Booking
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors de la réservation'
      return null
    } finally {
      isLoading.value = false
    }
  }

  // Get user bookings
  const getUserBookings = async () => {
    if (!user.value) return []

    isLoading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('bookings')
        .select(`
          *,
          court:courts(*),
          center:courts(center:centers(*))
        `)
        .eq('user_id', user.value.id)
        .order('date', { ascending: false })
        .order('start_time', { ascending: false })

      if (fetchError) throw fetchError

      return data as Booking[]
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors du chargement des réservations'
      return []
    } finally {
      isLoading.value = false
    }
  }

  // Cancel a booking
  const cancelBooking = async (bookingId: string) => {
    isLoading.value = true
    error.value = null

    try {
      // Get booking details
      const { data: booking, error: bookingError } = await supabase
        .from('bookings')
        .select('time_slot_id')
        .eq('id', bookingId)
        .single()

      if (bookingError) throw bookingError

      // Update booking status
      await supabase
        .from('bookings')
        .update({ status: 'cancelled' })
        .eq('id', bookingId)

      // Make time slot available again
      await supabase
        .from('time_slots')
        .update({ is_available: true, booking_id: null })
        .eq('id', booking.time_slot_id)

      return true
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors de l\'annulation'
      return false
    } finally {
      isLoading.value = false
    }
  }

  return {
    // State
    selectedCenter,
    selectedCourt,
    selectedDate,
    selectedTimeSlot,
    isLoading: readonly(isLoading),
    error: readonly(error),

    // Actions
    searchCenters,
    getAvailableSlots,
    createBooking,
    getUserBookings,
    cancelBooking,

    // Helpers
    clearError: () => { error.value = null },
    resetSelection: () => {
      selectedCenter.value = null
      selectedCourt.value = null
      selectedTimeSlot.value = null
    }
  }
}