<template>
  <div class="min-h-screen bg-background">
    <!-- Header -->
    <header class="border-b border-border">
      <div class="container mx-auto px-4 py-4">
        <nav class="flex items-center justify-between">
          <div class="flex items-center space-x-4">            
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
            <UiButton v-if="user" variant="outline" @click="handleLogout">
              Déconnexion
            </UiButton>
          </div>
        </nav>
      </div>
    </header>

    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center py-20">
      <Loader2 class="h-8 w-8 animate-spin text-primary" />
      <span class="ml-2 text-muted-foreground">Chargement du centre...</span>
    </div>

    <!-- Center Not Found -->
    <div v-else-if="!center" class="text-center py-20">
      <MapPin class="h-12 w-12 text-muted-foreground mx-auto mb-4" />
      <h2 class="text-2xl font-semibold text-foreground mb-2">Centre non trouvé</h2>
      <p class="text-muted-foreground mb-4">
        Le centre que vous recherchez n'existe pas ou n'est plus disponible.
      </p>
      <UiButton @click="navigateTo('/')">
        Retour à l'accueil
      </UiButton>
    </div>

    <!-- Center Details -->
    <div v-else>
      <!-- Hero Section -->
      <section class="relative">
        <div class="h-96 bg-muted relative overflow-hidden">
          <img 
            v-if="center.cover_image_url"
            :src="center.cover_image_url"
            :alt="center.name"
            class="w-full h-full object-cover"
          />
          <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />
          
          <!-- Center Info Overlay -->
          <div class="absolute inset-0 p-8 text-white flex flex-col justify-between">
            <div class="container mx-auto">
              <!-- Gallery Thumbnails moved to top-right -->
              <div v-if="center.gallery_images && center.gallery_images.length > 0" class="flex justify-end mb-4">
                <div class="flex space-x-2">
                  <div 
                    v-for="(image, index) in center.gallery_images.slice(0, 4)" 
                    :key="index"
                    class="w-16 h-16 bg-black/50 rounded border-2 border-white/50 overflow-hidden cursor-pointer hover:border-white transition-all"
                    @click="openGallery(index)"
                  >
                    <img :src="image" :alt="`Photo ${index + 1}`" class="w-full h-full object-cover" />
                  </div>
                  <div 
                    v-if="center.gallery_images.length > 4"
                    class="w-16 h-16 bg-black/70 rounded border-2 border-white/50 flex items-center justify-center text-white text-xs font-semibold cursor-pointer"
                    @click="openGallery(4)"
                  >
                    +{{ center.gallery_images.length - 4 }}
                  </div>
                </div>
              </div>
            </div>

            <!-- Center info moved to middle-left -->
            <div class="container mx-auto">
              <div class="flex items-center justify-between">
                <div class="max-w-2xl">
                  <h1 class="text-4xl font-bold mb-3">{{ center.name }}</h1>
                  <div class="flex items-center space-x-4 mb-3">
                    <div class="flex items-center">
                      <Star class="h-5 w-5 text-yellow-400 fill-current" />
                      <span class="ml-1 font-semibold">{{ center.average_rating || 'N/A' }}</span>
                      <span class="ml-1 opacity-80">({{ center.total_reviews || 0 }} avis)</span>
                    </div>
                    <div class="flex items-center">
                      <MapPin class="h-4 w-4 opacity-80" />
                      <span class="ml-1 opacity-80">{{ center.city }}</span>
                    </div>
                  </div>
                  <p class="text-lg opacity-90 leading-relaxed">{{ center.description }}</p>
                </div>
                
                <!-- Quick Book Button -->
                <UiButton 
                  size="lg" 
                  @click="scrollToBooking"
                  class="bg-primary hover:bg-primary/90"
                >
                  <Calendar class="mr-2 h-5 w-5" />
                  Réserver
                </UiButton>
              </div>
            </div>

            <!-- Empty div for spacing at bottom -->
            <div></div>
          </div>
        </div>

      </section>

      <!-- Main Content -->
      <div class="container mx-auto px-4 py-8">
        <div class="grid lg:grid-cols-3 gap-8">
          <!-- Left Column - Details -->
          <div class="lg:col-span-2 space-y-8">
            <!-- Quick Info -->
            <UiCard>
              <UiCardHeader>
                <h3 class="text-xl font-semibold">Informations pratiques</h3>
              </UiCardHeader>
              <UiCardContent>
                <div class="grid md:grid-cols-2 gap-6">
                  <!-- Contact -->
                  <div>
                    <h4 class="font-medium mb-3">Contact</h4>
                    <div class="space-y-2 text-sm">
                      <div class="flex items-center">
                        <MapPin class="h-4 w-4 text-muted-foreground mr-2" />
                        <span>{{ center.address_line1 }}, {{ center.city }} {{ center.postal_code }}</span>
                      </div>
                      <div v-if="center.phone" class="flex items-center">
                        <Phone class="h-4 w-4 text-muted-foreground mr-2" />
                        <span>{{ center.phone }}</span>
                      </div>
                      <div v-if="center.email" class="flex items-center">
                        <Mail class="h-4 w-4 text-muted-foreground mr-2" />
                        <span>{{ center.email }}</span>
                      </div>
                      <div v-if="center.website" class="flex items-center">
                        <ExternalLink class="h-4 w-4 text-muted-foreground mr-2" />
                        <a :href="center.website" target="_blank" class="text-primary hover:underline">
                          Site web
                        </a>
                      </div>
                    </div>
                  </div>

                  <!-- Opening Hours -->
                  <div>
                    <h4 class="font-medium mb-3">Horaires d'ouverture</h4>
                    <div class="space-y-1 text-sm">
                      <div v-for="(hours, day) in center.opening_hours" :key="day" class="flex justify-between">
                        <span class="capitalize">{{ translateDay(day) }}</span>
                        <span v-if="hours.closed" class="text-muted-foreground">Fermé</span>
                        <span v-else>{{ hours.open }} - {{ hours.close }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </UiCardContent>
            </UiCard>

            <!-- Amenities -->
            <UiCard v-if="center.amenities && center.amenities.length > 0">
              <UiCardHeader>
                <h3 class="text-xl font-semibold">Équipements et services</h3>
              </UiCardHeader>
              <UiCardContent>
                <div class="grid grid-cols-2 md:grid-cols-3 gap-3">
                  <div 
                    v-for="amenity in center.amenities" 
                    :key="amenity"
                    class="flex items-center space-x-2"
                  >
                    <div class="w-2 h-2 bg-primary rounded-full"></div>
                    <span class="text-sm capitalize">{{ amenity.replace('_', ' ') }}</span>
                  </div>
                </div>
              </UiCardContent>
            </UiCard>

            <!-- Courts -->
            <UiCard>
              <UiCardHeader>
                <h3 class="text-xl font-semibold">Nos terrains ({{ courts.length }})</h3>
              </UiCardHeader>
              <UiCardContent>
                <div class="grid gap-4">
                  <div 
                    v-for="court in courts" 
                    :key="court.court_id"
                    class="border rounded-lg p-4 hover:bg-muted/50 transition-colors"
                  >
                    <div class="flex items-center justify-between mb-2">
                      <h4 class="font-medium">{{ court.court_name }}</h4>
                      <div class="text-right">
                        <div class="text-lg font-bold text-primary">
                          {{ court.base_price }}€<span class="text-sm font-normal text-muted-foreground">/h</span>
                        </div>
                      </div>
                    </div>
                    
                    <div class="flex items-center space-x-4 text-sm text-muted-foreground">
                      <span class="capitalize">{{ court.surface_type.replace('_', ' ') }}</span>
                      <span class="capitalize">{{ court.court_type.replace('_', ' ') }}</span>
                      <span v-if="court.has_lighting" class="flex items-center">
                        <Lightbulb class="h-3 w-3 mr-1" />
                        Éclairage
                      </span>
                      <span v-if="court.has_heating" class="flex items-center">
                        <Thermometer class="h-3 w-3 mr-1" />
                        Chauffage
                      </span>
                    </div>
                  </div>
                </div>
              </UiCardContent>
            </UiCard>
          </div>

          <!-- Right Column - Booking -->
          <div class="lg:col-span-1">
            <div class="sticky top-8">
              <UiCard id="booking-section">
                <UiCardHeader>
                  <h3 class="text-xl font-semibold">Réserver un créneau</h3>
                </UiCardHeader>
                <UiCardContent>
                  <!-- Date Selection -->
                  <div class="mb-6">
                    <label class="block text-sm font-medium mb-2">Date</label>
                    <UiInput
                      v-model="selectedDate"
                      type="date"
                      :min="today"
                      class="w-full"
                    />
                  </div>

                  <!-- Time Slots -->
                  <div class="mb-6">
                    <div class="flex items-center justify-between mb-2">
                      <label class="block text-sm font-medium">Créneaux disponibles</label>
                      <UiButton
                        variant="ghost"
                        size="sm"
                        @click="toggleSlotsView"
                        class="text-xs"
                      >
                        {{ slotsViewMode === 'grouped' ? 'Vue compacte' : 'Vue par terrain' }}
                      </UiButton>
                    </div>
                    <div v-if="loadingSlotsBooking" class="text-center py-4">
                      <Loader2 class="h-6 w-6 animate-spin mx-auto text-primary" />
                    </div>
                    <div v-else-if="availableSlotsBooking.length === 0" class="text-center py-4 text-muted-foreground">
                      Aucun créneau disponible pour cette date
                    </div>
                    <div v-else>
                      <!-- Grouped view by court -->
                      <div v-if="slotsViewMode === 'grouped'">
                        <div v-for="court in availableCourtSlots" :key="court.courtId" class="mb-4 last:mb-0">
                          <div class="flex items-center justify-between mb-2">
                            <div class="text-sm font-medium text-muted-foreground">
                              {{ court.courtName }}
                            </div>
                            <div class="text-xs text-muted-foreground capitalize">
                              {{ court.slots[0]?.surface_type?.replace('_', ' ') }}
                            </div>
                          </div>
                          <div class="grid grid-cols-3 gap-2">
                            <UiButton
                              v-for="slot in court.slots"
                              :key="`${slot.court_id}-${slot.start_time}`"
                              :variant="selectedSlotBooking?.id === slot.id ? 'default' : 'outline'"
                              size="sm"
                              class="justify-center h-12"
                              @click="selectSlotBooking(slot)"
                            >
                              <div class="text-center">
                                <div class="font-medium text-xs">{{ slot.start_time.slice(0, 5) }}</div>
                                <div class="text-xs opacity-75">{{ slot.final_price }}€</div>
                              </div>
                            </UiButton>
                          </div>
                        </div>
                      </div>
                      
                      <!-- Compact view - all slots together -->
                      <div v-else class="grid grid-cols-2 gap-2">
                        <UiButton
                          v-for="slot in sortedSlotsForCompactView"
                          :key="`${slot.court_id}-${slot.start_time}`"
                          :variant="selectedSlotBooking?.id === slot.id ? 'default' : 'outline'"
                          size="sm"
                          class="justify-start h-12"
                          @click="selectSlotBooking(slot)"
                        >
                          <div class="text-left">
                            <div class="font-medium text-xs">{{ slot.start_time.slice(0, 5) }}</div>
                            <div class="text-xs opacity-75">{{ slot.court_name.slice(0, 8) }} • {{ slot.final_price }}€</div>
                          </div>
                        </UiButton>
                      </div>
                    </div>
                  </div>

                  <!-- Selected Slot -->
                  <div v-if="selectedSlotBooking" class="mb-4 p-3 bg-primary/10 rounded-lg">
                    <div class="text-sm font-medium text-primary">Créneau sélectionné</div>
                    <div class="text-sm">
                      {{ formatDate(selectedDate) }} à {{ selectedSlotBooking.start_time.slice(0, 5) }}
                    </div>
                    <div class="text-sm">
                      Terrain: {{ selectedSlotBooking.court_name }}
                    </div>
                    <div class="text-sm font-medium">{{ selectedSlotBooking.final_price }}€</div>
                  </div>

                  <!-- Book Button -->
                  <UiButton 
                    class="w-full" 
                    :disabled="!selectedSlotBooking || !user"
                    @click="proceedToBooking"
                  >
                    {{ !user ? 'Connectez-vous pour réserver' : 'Réserver ce créneau' }}
                  </UiButton>
                </UiCardContent>
              </UiCard>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { 
  ArrowLeft, MapPin, Star, Calendar, Phone, Mail, ExternalLink,
  Lightbulb, Thermometer, Loader2
} from 'lucide-vue-next'

// Get route params
const route = useRoute()
const centerId = route.params.id as string

// SEO will be set dynamically once center is loaded
useHead({
  title: 'Centre de padel - PadelSpot',
})

// Auth
const user = useSupabaseUser()
const supabase = useSupabaseClient()

// Booking composable
const {
  availableSlots: availableSlotsBooking,
  selectedSlot: selectedSlotBooking,
  loadingSlots: loadingSlotsBooking,
  getAvailableSlots,
  selectSlot: selectSlotBooking,
  clearSelectedSlot
} = useBooking()

// Reactive data
const loading = ref(true)
const center = ref<any>(null)
const courts = ref<any[]>([])
const selectedDate = ref('')
const slotsViewMode = ref<'grouped' | 'compact'>('grouped')

// Computed
const today = computed(() => {
  return new Date().toISOString().split('T')[0]
})

const availableCourtSlots = computed(() => {
  if (!availableSlotsBooking.value.length) return []
  
  // Group slots by court
  const courtGroups = availableSlotsBooking.value.reduce((groups: any, slot: any) => {
    const courtId = slot.court_id
    if (!groups[courtId]) {
      groups[courtId] = {
        courtId,
        courtName: slot.court_name,
        slots: []
      }
    }
    groups[courtId].slots.push(slot)
    return groups
  }, {})
  
  // Sort slots within each court by time
  Object.values(courtGroups).forEach((group: any) => {
    group.slots.sort((a: any, b: any) => a.start_time.localeCompare(b.start_time))
  })
  
  return Object.values(courtGroups)
})

const sortedSlotsForCompactView = computed(() => {
  return [...availableSlotsBooking.value].sort((a: any, b: any) => 
    a.start_time.localeCompare(b.start_time)
  )
})

// Methods
const fetchCenter = async () => {
  loading.value = true
  
  try {
    const { data: centerData, error: centerError } = await supabase
      .from('centers')
      .select('*')
      .eq('id', centerId)
      .eq('is_active', true)
      .single()
    
    if (centerError) throw centerError
    
    center.value = centerData
    
    // Update SEO
    useHead({
      title: `${centerData.name} - PadelSpot`,
      meta: [
        { name: 'description', content: centerData.description || `Réservez vos terrains de padel au ${centerData.name} à ${centerData.city}` },
      ],
    })
    
    // Fetch courts
    const { data: courtsData, error: courtsError } = await supabase
      .from('courts_with_centers')
      .select('*')
      .eq('center_id', centerId)
      .eq('court_active', true)
    
    if (courtsError) throw courtsError
    
    courts.value = courtsData || []
    
  } catch (error) {
    console.error('Error fetching center:', error)
    center.value = null
  } finally {
    loading.value = false
  }
}

const fetchAvailableSlots = async () => {
  if (!selectedDate.value || !center.value) return
  
  await getAvailableSlots(centerId, selectedDate.value)
}

const toggleSlotsView = () => {
  slotsViewMode.value = slotsViewMode.value === 'grouped' ? 'compact' : 'grouped'
}

const proceedToBooking = () => {
  if (!selectedSlotBooking.value || !user.value) return
  
  // Navigate to booking page with selected slot
  navigateTo({
    path: '/booking',
    query: {
      center: centerId,
      court: selectedSlotBooking.value.court_id,
      date: selectedDate.value,
      time: selectedSlotBooking.value.start_time,
      price: selectedSlotBooking.value.final_price
    }
  })
}

const scrollToBooking = () => {
  document.getElementById('booking-section')?.scrollIntoView({ behavior: 'smooth' })
}

const translateDay = (day: string) => {
  const translations: Record<string, string> = {
    'monday': 'Lundi',
    'tuesday': 'Mardi', 
    'wednesday': 'Mercredi',
    'thursday': 'Jeudi',
    'friday': 'Vendredi',
    'saturday': 'Samedi',
    'sunday': 'Dimanche'
  }
  return translations[day] || day
}

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString('fr-FR', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  })
}

const openGallery = (index: number) => {
  // Would open a gallery modal
  console.log('Open gallery at index:', index)
}

const handleLogout = async () => {
  await supabase.auth.signOut()
  navigateTo('/')
}

// Watchers
watch(selectedDate, fetchAvailableSlots)

// Initialize
onMounted(() => {
  selectedDate.value = today.value
  fetchCenter()
})
</script>