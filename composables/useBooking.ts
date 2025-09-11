export interface TimeSlot {
  id: string
  court_id: string
  court_name: string
  start_time: string
  end_time: string
  final_price: number
  surface_type: string
  booking_date: string
  is_available: boolean
}

export interface Booking {
  id: string
  user_id: string
  court_id: string
  center_id: string
  booking_date: string
  start_time: string
  end_time: string
  player_count: number
  base_price: number
  total_price: number
  status: 'pending' | 'confirmed' | 'paid' | 'completed' | 'cancelled' | 'no_show'
  payment_status: 'pending' | 'paid' | 'failed' | 'refunded'
  payment_intent_id?: string
  special_requests?: string
  created_at: string
  updated_at: string
  court?: {
    id: string
    name: string
    surface_type: string
    court_type: string
  }
  center?: {
    id: string
    name: string
    address_line1: string
    city: string
    phone?: string
  }
}

export interface BookingRequest {
  court_id: string
  center_id: string
  booking_date: string
  start_time: string
  end_time: string
  player_count: number
  total_price: number
  special_requests?: string
}

export const useBooking = () => {
  const supabase = useSupabaseClient()
  const { user } = useAuth()
  
  // State
  const bookings = ref<Booking[]>([])
  const availableSlots = ref<TimeSlot[]>([])
  const selectedSlot = ref<TimeSlot | null>(null)
  const loading = ref(false)
  const loadingSlots = ref(false)
  const error = ref<string | null>(null)
  
  // Methods
  const getAvailableSlots = async (centerId: string, bookingDate: string, startTime = '08:00:00', endTime = '22:00:00') => {
    loadingSlots.value = true
    error.value = null
    
    try {
      const { data, error: slotsError } = await supabase.rpc('get_available_courts', {
        p_center_id: centerId,
        p_booking_date: bookingDate,
        p_start_time: startTime,
        p_end_time: endTime
      })
      
      if (slotsError) throw slotsError
      
      // Transform data to time slots
      const slots: TimeSlot[] = []
      const timeSlots = ['08:00', '09:30', '11:00', '12:30', '14:00', '15:30', '17:00', '18:30', '20:00', '21:30']
      
      data?.forEach((court: any) => {
        timeSlots.forEach(time => {
          const endHour = parseInt(time.split(':')[0]) + 1
          const endMinutes = parseInt(time.split(':')[1]) + 30
          const endTimeFormatted = `${endHour.toString().padStart(2, '0')}:${endMinutes.toString().padStart(2, '0')}:00`
          
          slots.push({
            id: `${court.court_id}-${time}`,
            court_id: court.court_id,
            court_name: court.court_name,
            start_time: time + ':00',
            end_time: endTimeFormatted,
            final_price: court.calculated_price || court.base_price,
            surface_type: court.surface_type,
            booking_date: bookingDate,
            is_available: true
          })
        })
      })
      
      availableSlots.value = slots
      return slots
    } catch (err) {
      console.error('Error fetching slots:', err)
      error.value = err instanceof Error ? err.message : 'Erreur lors du chargement des créneaux'
      availableSlots.value = []
      return []
    } finally {
      loadingSlots.value = false
    }
  }
  
  const createBooking = async (bookingRequest: BookingRequest) => {
    if (!user.value) {
      error.value = 'Vous devez être connecté pour réserver'
      throw new Error('User not authenticated')
    }
    
    loading.value = true
    error.value = null
    
    try {
      const { data, error: bookingError } = await supabase
        .from('bookings')
        .insert({
          user_id: user.value.id,
          ...bookingRequest,
          status: 'pending',
          payment_status: 'pending'
        })
        .select(`
          *,
          court:courts(id, name, surface_type, court_type),
          center:centers(id, name, address_line1, city, phone)
        `)
        .single()
      
      if (bookingError) throw bookingError
      
      return data as Booking
    } catch (err) {
      console.error('Error creating booking:', err)
      error.value = err instanceof Error ? err.message : 'Erreur lors de la création de la réservation'
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const getUserBookings = async (limit = 20) => {
    if (!user.value) {
      bookings.value = []
      return []
    }
    
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('bookings')
        .select(`
          *,
          court:courts(id, name, surface_type, court_type),
          center:centers(id, name, address_line1, city, phone)
        `)
        .eq('user_id', user.value.id)
        .order('booking_date', { ascending: false })
        .order('start_time', { ascending: false })
        .limit(limit)
      
      if (fetchError) throw fetchError
      
      bookings.value = data as Booking[]
      return data as Booking[]
    } catch (err) {
      console.error('Error fetching bookings:', err)
      error.value = err instanceof Error ? err.message : 'Erreur lors du chargement des réservations'
      return []
    } finally {
      loading.value = false
    }
  }
  
  const getBookingById = async (bookingId: string) => {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: fetchError } = await supabase
        .from('bookings')
        .select(`
          *,
          court:courts(id, name, surface_type, court_type),
          center:centers(id, name, address_line1, city, phone)
        `)
        .eq('id', bookingId)
        .single()
      
      if (fetchError) throw fetchError
      
      return data as Booking
    } catch (err) {
      console.error('Error fetching booking:', err)
      error.value = err instanceof Error ? err.message : 'Erreur lors du chargement de la réservation'
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const updateBookingStatus = async (bookingId: string, status: Booking['status'], paymentStatus?: Booking['payment_status']) => {
    loading.value = true
    error.value = null
    
    try {
      const updateData: any = {
        status,
        updated_at: new Date().toISOString()
      }
      
      if (paymentStatus) {
        updateData.payment_status = paymentStatus
      }
      
      const { data, error: updateError } = await supabase
        .from('bookings')
        .update(updateData)
        .eq('id', bookingId)
        .select()
        .single()
      
      if (updateError) throw updateError
      
      // Update local bookings array
      const index = bookings.value.findIndex(b => b.id === bookingId)
      if (index !== -1) {
        bookings.value[index] = { ...bookings.value[index], ...updateData }
      }
      
      return data as Booking
    } catch (err) {
      console.error('Error updating booking:', err)
      error.value = err instanceof Error ? err.message : 'Erreur lors de la mise à jour'
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const cancelBooking = async (bookingId: string) => {
    return updateBookingStatus(bookingId, 'cancelled')
  }
  
  const confirmBooking = async (bookingId: string) => {
    return updateBookingStatus(bookingId, 'confirmed', 'paid')
  }
  
  const selectSlot = (slot: TimeSlot) => {
    selectedSlot.value = slot
  }
  
  const clearSelectedSlot = () => {
    selectedSlot.value = null
  }
  
  const clearError = () => {
    error.value = null
  }
  
  // Computed
  const upcomingBookings = computed(() => {
    const now = new Date()
    return bookings.value.filter(booking => {
      const bookingDateTime = new Date(`${booking.booking_date}T${booking.start_time}`)
      return bookingDateTime > now && booking.status !== 'cancelled'
    })
  })
  
  const pastBookings = computed(() => {
    const now = new Date()
    return bookings.value.filter(booking => {
      const bookingDateTime = new Date(`${booking.booking_date}T${booking.start_time}`)
      return bookingDateTime <= now || booking.status === 'completed'
    })
  })
  
  const cancelledBookings = computed(() => {
    return bookings.value.filter(booking => booking.status === 'cancelled')
  })
  
  return {
    // State
    bookings: readonly(bookings),
    availableSlots: readonly(availableSlots),
    selectedSlot: readonly(selectedSlot),
    loading: readonly(loading),
    loadingSlots: readonly(loadingSlots),
    error: readonly(error),
    
    // Computed
    upcomingBookings,
    pastBookings,
    cancelledBookings,
    
    // Methods
    getAvailableSlots,
    createBooking,
    getUserBookings,
    getBookingById,
    updateBookingStatus,
    cancelBooking,
    confirmBooking,
    selectSlot,
    clearSelectedSlot,
    clearError
  }
}