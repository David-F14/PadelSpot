export interface Center {
  id: string
  name: string
  description?: string
  address_line1: string
  city: string
  postal_code: string
  phone?: string
  website?: string
  latitude?: number
  longitude?: number
  average_rating?: number
  total_reviews?: number
  logo_url?: string
  cover_image_url?: string
  amenities?: string[]
  distance_km?: number
  courts?: Court[]
  min_price?: number
  surface_types?: string[]
  court_types?: string[]
}

export interface Court {
  center_id: string
  surface_type: string
  court_type: string
  base_price_per_hour: number
}

export interface SearchFilters {
  surfaceFilter: string
  courtTypeFilter: string
  priceFilter: string
  sortBy: string
}

export interface SearchParams {
  query: string
  date: string
  time: string
  latitude?: number
  longitude?: number
}

export const useCenters = () => {
  const supabase = useSupabaseClient()
  
  // State
  const centers = ref<Center[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  
  // Search filters
  const searchQuery = ref('')
  const selectedDate = ref('')
  const selectedTime = ref('')
  const surfaceFilter = ref('')
  const courtTypeFilter = ref('')
  const priceFilter = ref('')
  const sortBy = ref('distance')
  
  // Location
  const userLocation = ref<{ lat: number; lng: number } | null>(null)
  const gettingLocation = ref(false)
  const locationError = ref('')
  
  // Pagination
  const hasMore = ref(true)
  const page = ref(1)
  
  // Computed
  const today = computed(() => {
    return new Date().toISOString().split('T')[0]
  })

  const timeOptions = computed(() => {
    const times = []
    for (let hour = 8; hour <= 22; hour++) {
      times.push(`${hour.toString().padStart(2, '0')}:00`)
      if (hour < 22) times.push(`${hour.toString().padStart(2, '0')}:30`)
    }
    return times
  })

  const hasActiveFilters = computed(() => {
    return !!(surfaceFilter.value || courtTypeFilter.value || priceFilter.value)
  })

  const filteredCenters = computed(() => {
    let filtered = [...centers.value]
    
    // Filter by surface type
    if (surfaceFilter.value) {
      filtered = filtered.filter(center => 
        center.surface_types && center.surface_types.includes(surfaceFilter.value)
      )
    }
    
    // Filter by court type
    if (courtTypeFilter.value) {
      filtered = filtered.filter(center => 
        center.court_types && center.court_types.includes(courtTypeFilter.value)
      )
    }
    
    // Filter by price range
    if (priceFilter.value) {
      if (priceFilter.value === '40+') {
        filtered = filtered.filter(center => (center.min_price || 0) >= 40)
      } else {
        const [min, max] = priceFilter.value.split('-').map(p => parseInt(p))
        filtered = filtered.filter(center => {
          const price = center.min_price || 0
          return price >= min && price <= max
        })
      }
    }
    
    // Apply sorting
    if (sortBy.value === 'rating') {
      filtered.sort((a, b) => (b.average_rating || 0) - (a.average_rating || 0))
    } else if (sortBy.value === 'price_low') {
      filtered.sort((a, b) => (a.min_price || 999) - (b.min_price || 999))
    } else if (sortBy.value === 'price_high') {
      filtered.sort((a, b) => (b.min_price || 0) - (a.min_price || 0))
    } else if (sortBy.value === 'distance' && userLocation.value) {
      filtered.sort((a, b) => (a.distance_km || 999) - (b.distance_km || 999))
    }
    
    return filtered
  })

  // Methods
  const searchCenters = async () => {
    loading.value = true
    error.value = null
    
    try {
      // Call our Supabase function to search centers
      const { data: centerData, error: searchError } = await supabase.rpc('search_centers_by_location', {
        p_latitude: userLocation.value?.lat || null,
        p_longitude: userLocation.value?.lng || null,
        p_city: searchQuery.value || null,
        p_radius_km: 50,
        p_limit: 20
      })
      
      if (searchError) throw searchError
      
      // Get courts data for each center to enable filtering
      if (centerData && centerData.length > 0) {
        const centerIds = centerData.map((center: any) => center.id)
        
        const { data: courtsData, error: courtsError } = await supabase
          .from('courts')
          .select('center_id, surface_type, court_type, base_price_per_hour')
          .in('center_id', centerIds)
          .eq('is_active', true)
        
        if (courtsError) throw courtsError
        
        // Attach courts to centers and calculate min price
        centers.value = centerData.map((center: any) => {
          const centerCourts = courtsData?.filter((court: any) => court.center_id === center.id) || []
          const minPrice = centerCourts.length > 0 
            ? Math.min(...centerCourts.map((court: any) => court.base_price_per_hour))
            : 25
          
          return {
            ...center,
            courts: centerCourts,
            min_price: minPrice,
            surface_types: [...new Set(centerCourts.map((court: any) => court.surface_type))],
            court_types: [...new Set(centerCourts.map((court: any) => court.court_type))]
          }
        })
      } else {
        centers.value = []
      }
    } catch (err) {
      console.error('Search error:', err)
      error.value = err instanceof Error ? err.message : 'Erreur lors de la recherche'
      centers.value = []
    } finally {
      loading.value = false
    }
  }

  const getCityFromCoordinates = async (lat: number, lng: number) => {
    try {
      // Using OpenStreetMap Nominatim API (free, no API key needed)
      const response = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=10&addressdetails=1`)
      const data = await response.json()
      
      if (data && data.address) {
        // Try to get city from different possible fields
        const city = data.address.city || 
                     data.address.town || 
                     data.address.village || 
                     data.address.municipality || 
                     data.address.hamlet ||
                     data.display_name?.split(',')[1]?.trim()
        
        if (city) {
          searchQuery.value = city
        }
      }
    } catch (error) {
      console.error('Error getting city from coordinates:', error)
      // Don't show error to user, just continue without city name
    }
  }

  const getUserLocation = async () => {
    if (!navigator.geolocation) {
      locationError.value = 'La géolocalisation n\'est pas supportée par votre navigateur'
      return
    }
    
    gettingLocation.value = true
    locationError.value = ''
    
    navigator.geolocation.getCurrentPosition(
      async (position) => {
        userLocation.value = {
          lat: position.coords.latitude,
          lng: position.coords.longitude
        }
        
        // Try to get city name from coordinates
        await getCityFromCoordinates(position.coords.latitude, position.coords.longitude)
        
        gettingLocation.value = false
        searchCenters()
      },
      (error) => {
        gettingLocation.value = false
        switch (error.code) {
          case error.PERMISSION_DENIED:
            locationError.value = 'Permission de géolocalisation refusée'
            break
          case error.POSITION_UNAVAILABLE:
            locationError.value = 'Position indisponible'
            break
          case error.TIMEOUT:
            locationError.value = 'Délai de géolocalisation dépassé'
            break
          default:
            locationError.value = 'Erreur de géolocalisation'
        }
      }
    )
  }

  const clearFilters = () => {
    surfaceFilter.value = ''
    courtTypeFilter.value = ''
    priceFilter.value = ''
    sortBy.value = 'distance'
  }

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr)
    return date.toLocaleDateString('fr-FR', { 
      weekday: 'short', 
      month: 'short', 
      day: 'numeric' 
    })
  }

  // Initialize
  const initialize = (routeQuery?: Record<string, any>) => {
    selectedDate.value = today.value
    
    // Get search parameters from URL params if available
    if (routeQuery?.location) {
      searchQuery.value = decodeURIComponent(routeQuery.location as string)
    }
    
    if (routeQuery?.date) {
      selectedDate.value = routeQuery.date as string
    }
    
    if (routeQuery?.time) {
      selectedTime.value = routeQuery.time as string
    }
  }

  return {
    // State
    centers: readonly(centers),
    loading: readonly(loading),
    error: readonly(error),
    
    // Filters
    searchQuery,
    selectedDate,
    selectedTime,
    surfaceFilter,
    courtTypeFilter,
    priceFilter,
    sortBy,
    
    // Location
    userLocation: readonly(userLocation),
    gettingLocation: readonly(gettingLocation),
    locationError: readonly(locationError),
    
    // Pagination
    hasMore: readonly(hasMore),
    page: readonly(page),
    
    // Computed
    today,
    timeOptions,
    hasActiveFilters,
    filteredCenters,
    
    // Methods
    searchCenters,
    getUserLocation,
    clearFilters,
    formatDate,
    initialize
  }
}