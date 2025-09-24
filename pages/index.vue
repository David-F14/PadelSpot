<template>
  <div>

    <!-- Search Section -->
    <section class="py-8 bg-muted/30">
      <div class="container mx-auto px-4">
        <div class="max-w-4xl mx-auto">
          <h2 class="text-3xl font-bold text-foreground text-center mb-8">
            Trouvez votre terrain de padel
          </h2>
          
          <!-- Search Form -->
          <div class="bg-card rounded-lg p-6 shadow-sm">
            <div class="grid md:grid-cols-4 gap-4">
              <!-- Location Search -->
              <div class="md:col-span-3">
                <label class="block text-sm font-medium text-foreground mb-2">
                  Où ?
                </label>
                <div class="relative">
                  <UiInput
                    v-model="searchQuery"
                    placeholder="Ville ou code postal"
                    class="pl-10 pr-20"
                    @input="onSearchInput"
                    @keyup.enter="searchCenters"
                  />
                  <button
                    @click="getUserLocation"
                    :disabled="gettingLocation"
                    class="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground hover:text-primary transition-colors cursor-pointer"
                    :class="{ 'animate-pulse text-primary': gettingLocation }"
                    title="Utiliser ma position"
                  >
                    <MapPin class="h-4 w-4" />
                  </button>

                  <div class="absolute right-3 top-1/2 transform -translate-y-1/2 flex items-center gap-2">
                    <button
                      v-if="searchQuery"
                      @click="clearLocation"
                      class="h-4 w-4 text-muted-foreground hover:text-foreground transition-colors"
                      title="Effacer"
                    >
                      <X class="h-4 w-4" />
                    </button>
                  </div>
                </div>
              </div>

              <!-- Date -->
              <div>
                <label class="block text-sm font-medium text-foreground mb-2">
                  Date
                </label>
                <div class="relative">
                  <UiInput
                    ref="dateInput"
                    v-model="selectedDate"
                    type="date"
                    :min="today"
                    class="pr-10"
                  />
                  <button
                    @click="openDatePicker"
                    class="absolute right-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground hover:text-primary transition-colors cursor-pointer"
                    title="Choisir une date"
                  >
                    <Calendar class="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>

            <!-- Location permissions message -->
            <p v-if="locationError" class="text-sm text-destructive mt-4">
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
          >
            <option value="">Tous prix</option>
            <option value="0-20">0€ - 20€</option>
            <option value="20-30">20€ - 30€</option>
            <option value="30-40">30€ - 40€</option>
            <option value="40+">40€+</option>
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
                  {{ selectedDate ? '3 créneaux disponibles' : '8 terrains disponibles' }}
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
import { ref, watch, onMounted, onUnmounted, nextTick } from 'vue'
import { MapPin, Search, X, Grid, List, Star, LayoutDashboard, Calendar } from 'lucide-vue-next'

// SEO
useHead({
  title: 'Centres de padel - PadelSpot',
  meta: [
    { name: 'description', content: 'Découvrez tous les centres de padel près de chez vous. Réservez facilement vos terrains favoris.' },
  ],
})

// Composables
const { user, signOut } = useAuth()
const {
  // State
  loading,
  
  // Filters
  searchQuery,
  selectedDate,
  surfaceFilter,
  courtTypeFilter,
  priceFilter,

  // Location
  gettingLocation,
  locationError,
  
  // Pagination
  hasMore,
  
  // Computed
  today,
  timeOptions,
  hasActiveFilters,
  filteredCenters,
  
  // Methods
  searchCenters,
  getUserLocation,
  clearFilters,
  clearLocation,
  formatDate,
  initialize
} = useCenters()

// User status
const { isManager, isPlayer } = useUser()

// Get route params
const route = useRoute()

// UI State
const viewMode = ref('grid')

// Debounce timer for search
let searchTimer: NodeJS.Timeout | null = null
const isInitialized = ref(false)

// Date input reference
const dateInput = ref<HTMLInputElement | null>(null)

// Local methods
const onSearchInput = () => {
  // The search is automatically triggered by the searchQuery watcher with debounce
  // This function is here for the @input event but the actual logic is in the watcher
}

const openDatePicker = () => {
  // Focus on the date input to trigger the native date picker
  nextTick(() => {
    if (dateInput.value) {
      // Try to access the underlying input element
      let inputElement = dateInput.value

      // If it's a Vue component, try to get the underlying DOM element
      if (dateInput.value.$el) {
        inputElement = dateInput.value.$el
      }

      // If it's still not a DOM element, try to find the input within
      if (!inputElement.focus && inputElement.querySelector) {
        inputElement = inputElement.querySelector('input[type="date"]')
      }

      // Now try to focus and show picker
      if (inputElement && typeof inputElement.focus === 'function') {
        inputElement.focus()
        if (inputElement.showPicker) {
          inputElement.showPicker()
        }
      }
    }
  })
}

// Watchers
watch(searchQuery, (newValue, oldValue) => {
  // Skip automatic search during initialization
  if (!isInitialized.value) return
  
  // If field becomes empty, clear location immediately
  if (!newValue && oldValue) {
    clearLocation()
    return
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


const loadMore = () => {
  // Implementation would go here for pagination
}


// Initialize
onMounted(() => {
  initialize(route.query)
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