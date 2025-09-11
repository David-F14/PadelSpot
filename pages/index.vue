<template>
  <div class="min-h-screen bg-background">
    <!-- Header -->
    <header class="border-b border-border">
      <div class="container mx-auto px-4 py-4">
        <nav class="flex items-center justify-between">
          <div class="flex items-center space-x-2">
            <NuxtLink to="/" class="flex items-center space-x-2">
              <div class="h-8 w-8 bg-primary rounded-md flex items-center justify-center">
                <span class="text-primary-foreground font-bold text-lg">P</span>
              </div>
              <h1 class="text-xl font-bold text-foreground">PadelSpot</h1>
            </NuxtLink>
          </div>
          
          <div class="flex items-center space-x-4">
            <UiButton v-if="!user" variant="outline" @click="navigateTo('/auth/login')">
              Connexion
            </UiButton>
            <UiButton v-if="!user" @click="navigateTo('/auth/register')">
              S'inscrire
            </UiButton>
            <UiButton v-if="user" variant="outline" @click="handleLogout">
              Déconnexion
            </UiButton>
          </div>
        </nav>
      </div>
    </header>

    <!-- Search Section -->
    <section class="py-8 bg-muted/30">
      <div class="container mx-auto px-4">
        <div class="max-w-4xl mx-auto">
          <h2 class="text-3xl font-bold text-foreground text-center mb-8">
            Trouvez votre terrain de padel
          </h2>
          
          <!-- Search Form -->
          <div class="bg-card rounded-lg p-6 shadow-sm">
            <div class="grid md:grid-cols-3 gap-4">
              <!-- Location Search -->
              <div>
                <label class="block text-sm font-medium text-foreground mb-2">
                  Où ?
                </label>
                <div class="relative">
                  <UiInput
                    v-model="searchQuery"
                    placeholder="Ville ou code postal"
                    class="pl-10"
                    @keyup.enter="searchCenters"
                  />
                  <MapPin class="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                </div>
              </div>
              
              <!-- Date -->
              <div>
                <label class="block text-sm font-medium text-foreground mb-2">
                  Date
                </label>
                <UiInput
                  v-model="selectedDate"
                  type="date"
                  :min="today"
                />
              </div>
              
              <!-- Time -->
              <div>
                <label class="block text-sm font-medium text-foreground mb-2">
                  Heure
                </label>
                <select 
                  v-model="selectedTime"
                  class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                >
                  <option value="">Toute la journée</option>
                  <option v-for="time in timeOptions" :key="time" :value="time">
                    {{ time }}
                  </option>
                </select>
              </div>
            </div>
            
            <div class="flex flex-col sm:flex-row gap-4 mt-6">
              <UiButton @click="searchCenters" class="flex-1">
                <Search class="mr-2 h-4 w-4" />
                Rechercher
              </UiButton>
              
              <UiButton 
                variant="outline" 
                @click="getUserLocation" 
                :disabled="gettingLocation"
              >
                <MapPin class="mr-2 h-4 w-4" />
                {{ gettingLocation ? 'Localisation en cours...' : 'Ma position' }}
              </UiButton>
            </div>
            
            <!-- Location permissions message -->
            <p v-if="locationError" class="text-sm text-destructive mt-2">
              {{ locationError }}
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Filters Section -->
    <section class="py-4 border-b border-border">
      <div class="container mx-auto px-4">
        <div class="flex flex-wrap gap-3 items-center">
          <span class="text-sm font-medium text-foreground">Filtres :</span>
          
          <!-- Surface Type Filter -->
          <select 
            v-model="surfaceFilter"
            class="text-sm rounded-md border border-input bg-background px-3 py-1 min-w-[160px]"
            @change="applyFilters"
          >
            <option value="">Toutes surfaces</option>
            <option value="gazon_synthetique">Gazon synthétique</option>
            <option value="terre_battue">Terre battue</option>
            <option value="beton_poreux">Béton poreux</option>
            <option value="resine">Résine</option>
          </select>
          
          <!-- Court Type Filter -->
          <select 
            v-model="courtTypeFilter"
            class="text-sm rounded-md border border-input bg-background px-3 py-1 min-w-[140px]"
            @change="applyFilters"
          >
            <option value="">Tous types</option>
            <option value="interieur">Intérieur</option>
            <option value="exterieur">Extérieur</option>
            <option value="semi_couvert">Semi-couvert</option>
          </select>
          
          <!-- Price Range -->
          <select 
            v-model="priceFilter"
            class="text-sm rounded-md border border-input bg-background px-3 py-1 min-w-[110px]"
            @change="applyFilters"
          >
            <option value="">Tous prix</option>
            <option value="0-20">0€ - 20€</option>
            <option value="20-30">20€ - 30€</option>
            <option value="30-40">30€ - 40€</option>
            <option value="40+">40€+</option>
          </select>
          
          <!-- Sort -->
          <select 
            v-model="sortBy"
            class="text-sm rounded-md border border-input bg-background px-3 py-1 min-w-[100px]"
            @change="applyFilters"
          >
            <option value="distance">Distance</option>
            <option value="rating">Note</option>
            <option value="price_low">Prix croissant</option>
            <option value="price_high">Prix décroissant</option>
          </select>
          
          <UiButton variant="ghost" size="sm" @click="clearFilters">
            <X class="mr-1 h-3 w-3" />
            Effacer
          </UiButton>
        </div>
      </div>
    </section>

    <!-- Results Section -->
    <section class="py-8">
      <div class="container mx-auto px-4">
        <!-- Results Header -->
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-xl font-semibold text-foreground">
            {{ filteredCenters.length }} centre(s) trouvé(s)
            <span v-if="searchQuery" class="text-muted-foreground">
              près de "{{ searchQuery }}"
            </span>
            <span v-if="hasActiveFilters" class="text-sm text-primary">
              (filtré)
            </span>
          </h3>
          
          <div class="flex items-center space-x-2">
            <UiButton 
              variant="outline" 
              size="sm"
              :class="{ 'bg-primary text-primary-foreground': viewMode === 'grid' }"
              @click="viewMode = 'grid'"
            >
              <Grid class="h-4 w-4" />
            </UiButton>
            <UiButton 
              variant="outline" 
              size="sm"
              :class="{ 'bg-primary text-primary-foreground': viewMode === 'list' }"
              @click="viewMode = 'list'"
            >
              <List class="h-4 w-4" />
            </UiButton>
          </div>
        </div>

        <!-- No Results -->
        <div v-if="!loading && filteredCenters.length === 0" class="text-center py-12">
          <MapPin class="h-12 w-12 text-muted-foreground mx-auto mb-4" />
          <h3 class="text-lg font-medium text-foreground mb-2">Aucun centre trouvé</h3>
          <p class="text-muted-foreground mb-4">
            Essayez d'élargir votre recherche ou de modifier vos filtres.
          </p>
          <UiButton variant="outline" @click="clearFilters">
            Effacer les filtres
          </UiButton>
        </div>

        <!-- Centers Grid -->
        <div 
          v-if="filteredCenters.length > 0"
          :class="viewMode === 'grid' ? 'grid md:grid-cols-2 lg:grid-cols-3 gap-4' : 'space-y-2'"
        >
          <UiCard 
            v-for="center in filteredCenters" 
            :key="center.id"
            :class="[
              'overflow-hidden hover:shadow-lg transition-shadow cursor-pointer',
              viewMode === 'list' ? 'flex-row flex' : ''
            ]"
            @click="navigateTo(`/centers/${center.id}`)"
          >
            <!-- Center Image -->
            <div :class="viewMode === 'list' ? 'w-48 h-32 flex-shrink-0 bg-muted relative' : 'h-32 bg-muted relative'">
              <img 
                v-if="center.cover_image_url"
                :src="center.cover_image_url"
                :alt="center.name"
                class="w-full h-full object-cover"
              />
              <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
              <!-- Titre et ville seulement en mode grid -->
              <div v-if="viewMode === 'grid'" class="absolute bottom-4 left-4 text-white">
                <h4 class="text-lg font-semibold">{{ center.name }}</h4>
                <p class="text-sm opacity-90">{{ center.city }}</p>
              </div>
              
              <!-- Distance Badge -->
              <div v-if="center.distance_km" class="absolute top-2 right-2 bg-black/70 text-white px-2 py-1 rounded text-xs">
                {{ center.distance_km }}km
              </div>
              
              <!-- Availability Badge -->
              <div class="absolute top-2 left-2 bg-green-500 text-white px-2 py-1 rounded text-xs font-medium">
                ✓ Disponible
              </div>
            </div>

            <UiCardContent :class="viewMode === 'list' ? 'p-4 flex-1 flex flex-col justify-between' : 'p-3'">
              <div>
                <!-- Titre et ville en mode liste -->
                <div v-if="viewMode === 'list'" class="mb-2">
                  <h4 class="text-lg font-semibold">{{ center.name }}</h4>
                  <p class="text-sm text-muted-foreground">{{ center.city }}</p>
                </div>

                <!-- Rating et adresse sur une ligne en mode liste -->
                <div :class="viewMode === 'list' ? 'flex items-center justify-between mb-2' : 'mb-2'">
                  <div class="flex items-center space-x-2">
                    <div class="flex items-center">
                      <Star class="h-4 w-4 text-yellow-400 fill-current" />
                      <span class="text-sm font-medium ml-1">{{ center.average_rating || 'N/A' }}</span>
                    </div>
                    <span class="text-sm text-muted-foreground">({{ center.total_reviews || 0 }} avis)</span>
                  </div>
                  
                  <div v-if="viewMode === 'list'" class="text-xs text-muted-foreground">
                    {{ center.address_line1 }}
                  </div>
                </div>

                <!-- Address complet en mode grid -->
                <p v-if="viewMode === 'grid'" class="text-sm text-muted-foreground mb-2">
                  {{ center.address_line1 }}
                </p>

                <!-- Amenities compacts -->
                <div v-if="viewMode === 'grid'" class="flex flex-wrap gap-1 mb-2">
                  <span 
                    v-for="amenity in (center.amenities || []).slice(0, 3)" 
                    :key="amenity"
                    class="text-xs bg-muted px-2 py-1 rounded"
                  >
                    {{ amenity.replace('_', ' ') }}
                  </span>
                  <span 
                    v-if="(center.amenities || []).length > 3"
                    class="text-xs bg-muted px-2 py-1 rounded"
                  >
                    +{{ (center.amenities || []).length - 3 }}
                  </span>
                </div>
              </div>

              <!-- Availability Info -->
              <div class="flex items-center justify-between mb-1">
                <div class="text-sm text-green-600 font-medium">
                  {{ selectedDate && selectedTime ? '3 créneaux disponibles' : '8 terrains disponibles' }}
                </div>
                <div class="text-xs text-muted-foreground">
                  {{ selectedDate ? formatDate(selectedDate) : 'Aujourd\'hui' }}
                </div>
              </div>

              <!-- Price Range -->
              <div class="flex items-center justify-between">
                <div class="text-sm text-muted-foreground">
                  À partir de
                </div>
                <div class="text-lg font-bold text-primary">
                  {{ center.min_price || 25 }}€<span class="text-sm font-normal text-muted-foreground">/h</span>
                </div>
              </div>
            </UiCardContent>
          </UiCard>
        </div>

        <!-- Load More -->
        <div v-if="filteredCenters.length > 0 && hasMore" class="text-center mt-8">
          <UiButton variant="outline" @click="loadMore" :disabled="loading">
            Voir plus de centres
          </UiButton>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { MapPin, Search, X, Grid, List, Star, Loader2 } from 'lucide-vue-next'

// SEO
useHead({
  title: 'Centres de padel - PadelSpot',
  meta: [
    { name: 'description', content: 'Découvrez tous les centres de padel près de chez vous. Réservez facilement vos terrains favoris.' },
  ],
})

// Auth
const user = useSupabaseUser()
const supabase = useSupabaseClient()

// Get route params
const route = useRoute()

// Reactive data  
const searchQuery = ref('')
const selectedDate = ref('')
const selectedTime = ref('')
const surfaceFilter = ref('')
const courtTypeFilter = ref('')
const priceFilter = ref('')
const sortBy = ref('distance')
const viewMode = ref('grid')

const loading = ref(false)
const gettingLocation = ref(false)
const locationError = ref('')
const userLocation = ref<{ lat: number; lng: number } | null>(null)

const centers = ref<any[]>([])
const hasMore = ref(true)
const page = ref(1)

// Debounce timer for search
let searchTimer: NodeJS.Timeout | null = null
const isInitialized = ref(false)

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

// Watchers
watch(searchQuery, (newValue, oldValue) => {
  // Skip automatic search during initialization
  if (!isInitialized.value) return
  
  // If user is manually typing a new city, clear GPS coordinates to prioritize text search
  if (newValue !== oldValue && userLocation.value) {
    userLocation.value = null
    locationError.value = '' // Clear any geolocation errors when switching to text search
  }
  
  // Clear existing timer
  if (searchTimer) {
    clearTimeout(searchTimer)
  }
  
  // Set new timer for 500ms delay
  searchTimer = setTimeout(() => {
    searchCenters()
  }, 500)
})

// Methods
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

const searchCenters = async () => {
  loading.value = true
  
  try {
    // Call our Supabase function to search centers
    const { data: centerData, error } = await supabase.rpc('search_centers_by_location', {
      p_latitude: userLocation.value?.lat || null,
      p_longitude: userLocation.value?.lng || null,
      p_city: searchQuery.value || null,
      p_radius_km: 50,
      p_limit: 20
    })
    
    if (error) throw error
    
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
  } catch (error) {
    console.error('Search error:', error)
    centers.value = []
  } finally {
    loading.value = false
  }
}

const applyFilters = () => {
  // Filters are applied via computed property
}

const clearFilters = () => {
  surfaceFilter.value = ''
  courtTypeFilter.value = ''
  priceFilter.value = ''
  sortBy.value = 'distance'
}

const loadMore = () => {
  page.value++
  // Implement pagination
}

const formatDate = (dateStr: string) => {
  const date = new Date(dateStr)
  return date.toLocaleDateString('fr-FR', { 
    weekday: 'short', 
    month: 'short', 
    day: 'numeric' 
  })
}

const handleLogout = async () => {
  await supabase.auth.signOut()
  navigateTo('/')
}

// Initialize
onMounted(() => {
  selectedDate.value = today.value
  
  // Get location from URL params if available
  if (route.query.location) {
    searchQuery.value = decodeURIComponent(route.query.location as string)
  }
  
  searchCenters()
  
  // Enable automatic search after initialization
  isInitialized.value = true
})

// Cleanup
onUnmounted(() => {
  if (searchTimer) {
    clearTimeout(searchTimer)
  }
})
</script>