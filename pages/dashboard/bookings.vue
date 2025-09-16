<template>
  <div class="min-h-screen bg-background">
    <!-- Header -->
    <header class="border-b border-border bg-card">
      <div class="container mx-auto px-4 py-4">
        <nav class="flex items-center justify-between">
          <div class="flex items-center space-x-4">
            <UiButton variant="ghost" size="sm" @click="navigateTo('/dashboard/manager')">
              <ArrowLeft class="mr-2 h-4 w-4" />
              Dashboard
            </UiButton>
            
            <NuxtLink to="/" class="flex items-center space-x-2">
              <div class="h-8 w-8 bg-primary rounded-md flex items-center justify-center">
                <span class="text-primary-foreground font-bold text-lg">P</span>
              </div>
              <h1 class="text-xl font-bold text-foreground">PadelSpot</h1>
            </NuxtLink>
          </div>
          
          <div class="flex items-center space-x-4">
            <div class="text-sm text-muted-foreground">
              Gestion des réservations
            </div>
          </div>
        </nav>
      </div>
    </header>

    <!-- Content -->
    <div class="container mx-auto px-4 py-8">
      <!-- Filters and Search -->
      <div class="mb-8 flex flex-col md:flex-row gap-4 items-start md:items-end">
        <div class="flex-1">
          <label class="block text-sm font-medium mb-2">Rechercher</label>
          <UiInput
            v-model="searchQuery"
            placeholder="Rechercher par nom, email..."
            class="max-w-sm"
          />
        </div>
        
        <div>
          <label class="block text-sm font-medium mb-2">Date</label>
          <UiInput
            v-model="filterDate"
            type="date"
            class="w-40"
          />
        </div>
        
        <div>
          <label class="block text-sm font-medium mb-2">Statut</label>
          <select 
            v-model="filterStatus"
            class="flex h-10 w-32 rounded-md border border-input bg-background px-3 py-2 text-sm"
          >
            <option value="">Tous</option>
            <option value="confirmed">Confirmées</option>
            <option value="pending">En attente</option>
            <option value="cancelled">Annulées</option>
          </select>
        </div>
        
        <UiButton @click="clearFilters" variant="outline">
          <X class="mr-2 h-4 w-4" />
          Effacer
        </UiButton>
      </div>

      <!-- Stats Summary -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <UiCard>
          <UiCardContent class="p-4">
            <div class="text-sm text-muted-foreground">Total réservations</div>
            <div class="text-2xl font-bold">{{ filteredBookings.length }}</div>
          </UiCardContent>
        </UiCard>
        
        <UiCard>
          <UiCardContent class="p-4">
            <div class="text-sm text-muted-foreground">Confirmées</div>
            <div class="text-2xl font-bold text-green-600">{{ confirmedCount }}</div>
          </UiCardContent>
        </UiCard>
        
        <UiCard>
          <UiCardContent class="p-4">
            <div class="text-sm text-muted-foreground">En attente</div>
            <div class="text-2xl font-bold text-yellow-600">{{ pendingCount }}</div>
          </UiCardContent>
        </UiCard>
        
        <UiCard>
          <UiCardContent class="p-4">
            <div class="text-sm text-muted-foreground">Revenus</div>
            <div class="text-2xl font-bold text-primary">{{ totalRevenue }}€</div>
          </UiCardContent>
        </UiCard>
      </div>

      <!-- Bookings Table -->
      <UiCard>
        <UiCardHeader>
          <div class="flex items-center justify-between">
            <UiCardTitle>Réservations</UiCardTitle>
            <div class="text-sm text-muted-foreground">
              {{ filteredBookings.length }} résultat(s)
            </div>
          </div>
        </UiCardHeader>
        <UiCardContent>
          <div v-if="loading" class="text-center py-8">
            <Loader2 class="h-6 w-6 animate-spin mx-auto text-primary" />
            <p class="mt-2 text-muted-foreground">Chargement des réservations...</p>
          </div>
          
          <div v-else-if="filteredBookings.length === 0" class="text-center py-8">
            <Calendar class="h-12 w-12 text-muted-foreground mx-auto mb-4" />
            <p class="text-muted-foreground">Aucune réservation trouvée</p>
          </div>
          
          <div v-else class="overflow-x-auto">
            <table class="w-full">
              <thead>
                <tr class="border-b">
                  <th class="text-left py-3 px-2">Client</th>
                  <th class="text-left py-3 px-2">Date</th>
                  <th class="text-left py-3 px-2">Heure</th>
                  <th class="text-left py-3 px-2">Terrain</th>
                  <th class="text-left py-3 px-2">Joueurs</th>
                  <th class="text-left py-3 px-2">Prix</th>
                  <th class="text-left py-3 px-2">Statut</th>
                  <th class="text-left py-3 px-2">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr 
                  v-for="booking in paginatedBookings" 
                  :key="booking.id"
                  class="border-b hover:bg-muted/50 transition-colors"
                >
                  <td class="py-3 px-2">
                    <div class="flex items-center space-x-3">
                      <div class="w-8 h-8 bg-primary/10 rounded-full flex items-center justify-center">
                        <User class="h-4 w-4 text-primary" />
                      </div>
                      <div>
                        <div class="font-medium">{{ formatBookingUser(booking) }}</div>
                        <div class="text-xs text-muted-foreground">{{ booking.user_profiles?.email }}</div>
                      </div>
                    </div>
                  </td>
                  <td class="py-3 px-2">
                    <div class="font-medium">{{ formatDate(booking.booking_date) }}</div>
                  </td>
                  <td class="py-3 px-2">
                    <div class="font-mono text-sm">{{ booking.start_time.slice(0, 5) }}</div>
                  </td>
                  <td class="py-3 px-2">
                    <div class="text-sm">{{ booking.courts?.court_name }}</div>
                  </td>
                  <td class="py-3 px-2">
                    <div class="text-center">{{ booking.player_count }}</div>
                  </td>
                  <td class="py-3 px-2">
                    <div class="font-medium">{{ booking.total_price }}€</div>
                  </td>
                  <td class="py-3 px-2">
                    <UiBadge :variant="getStatusVariant(booking.status)">
                      {{ getStatusText(booking.status) }}
                    </UiBadge>
                  </td>
                  <td class="py-3 px-2">
                    <div class="flex items-center space-x-2">
                      <UiButton 
                        size="sm" 
                        variant="ghost"
                        @click="viewBooking(booking)"
                      >
                        <Eye class="h-4 w-4" />
                      </UiButton>
                      <UiButton 
                        size="sm" 
                        variant="ghost"
                        @click="editBooking(booking)"
                      >
                        <Edit class="h-4 w-4" />
                      </UiButton>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          
          <!-- Pagination -->
          <div v-if="totalPages > 1" class="mt-6 flex items-center justify-between">
            <div class="text-sm text-muted-foreground">
              Page {{ currentPage }} sur {{ totalPages }}
            </div>
            <div class="flex space-x-2">
              <UiButton 
                size="sm" 
                variant="outline" 
                :disabled="currentPage === 1"
                @click="currentPage--"
              >
                Précédent
              </UiButton>
              <UiButton 
                size="sm" 
                variant="outline"
                :disabled="currentPage === totalPages"
                @click="currentPage++"
              >
                Suivant
              </UiButton>
            </div>
          </div>
        </UiCardContent>
      </UiCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { 
  ArrowLeft, Calendar, User, Eye, Edit, X, Loader2
} from 'lucide-vue-next'

// Middleware to protect the route
definePageMeta({
  middleware: 'auth'
})

// SEO
useHead({
  title: 'Réservations - Dashboard Gérant - PadelSpot',
  meta: [
    { name: 'robots', content: 'noindex' },
  ],
})

// Get query parameters
const route = useRoute()
const centerId = route.query.center as string

// Auth
const user = useSupabaseUser()
const supabase = useSupabaseClient()

// Reactive data
const loading = ref(true)
const bookings = ref<any[]>([])
const searchQuery = ref('')
const filterDate = ref('')
const filterStatus = ref('')
const currentPage = ref(1)
const itemsPerPage = 20

// Computed
const filteredBookings = computed(() => {
  let filtered = bookings.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(booking => {
      const user = booking.user_profiles
      const email = user?.email?.toLowerCase() || ''
      const fullName = `${user?.first_name || ''} ${user?.last_name || ''}`.toLowerCase()
      return email.includes(query) || fullName.includes(query)
    })
  }

  if (filterDate.value) {
    filtered = filtered.filter(booking => booking.booking_date === filterDate.value)
  }

  if (filterStatus.value) {
    filtered = filtered.filter(booking => booking.status === filterStatus.value)
  }

  return filtered.sort((a, b) => new Date(b.booking_date).getTime() - new Date(a.booking_date).getTime())
})

const paginatedBookings = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return filteredBookings.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredBookings.value.length / itemsPerPage)
})

const confirmedCount = computed(() => {
  return filteredBookings.value.filter(b => b.status === 'confirmed').length
})

const pendingCount = computed(() => {
  return filteredBookings.value.filter(b => b.status === 'pending').length
})

const totalRevenue = computed(() => {
  return Math.round(filteredBookings.value
    .filter(b => b.payment_status === 'paid')
    .reduce((sum, b) => sum + b.total_price, 0))
})

// Methods
const fetchBookings = async () => {
  loading.value = true
  
  try {
    let query = supabase
      .from('bookings')
      .select(`
        *,
        user_profiles!inner(first_name, last_name, email),
        courts!inner(court_name)
      `)
      .order('booking_date', { ascending: false })
    
    if (centerId) {
      query = query.eq('center_id', centerId)
    } else {
      // Get all centers managed by user
      const { data: centers } = await supabase
        .from('centers')
        .select('id')
        .eq('manager_user_id', user.value?.id)
      
      if (centers && centers.length > 0) {
        const centerIds = centers.map(c => c.id)
        query = query.in('center_id', centerIds)
      }
    }
    
    const { data, error } = await query
    
    if (error) throw error
    
    bookings.value = data || []
    
  } catch (error) {
    console.error('Error fetching bookings:', error)
  } finally {
    loading.value = false
  }
}

const formatBookingUser = (booking: any) => {
  const profile = booking.user_profiles
  if (profile?.first_name && profile?.last_name) {
    return `${profile.first_name} ${profile.last_name}`
  }
  return profile?.email || 'Utilisateur inconnu'
}

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString('fr-FR', { 
    weekday: 'short',
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  })
}

const getStatusVariant = (status: string): 'default' | 'secondary' | 'destructive' | 'outline' => {
  switch (status) {
    case 'confirmed': return 'default'
    case 'pending': return 'secondary' 
    case 'cancelled': return 'destructive'
    default: return 'outline'
  }
}

const getStatusText = (status: string) => {
  switch (status) {
    case 'confirmed': return 'Confirmée'
    case 'pending': return 'En attente'
    case 'cancelled': return 'Annulée'
    default: return status
  }
}

const viewBooking = (booking: any) => {
  // Navigate to booking detail page
  navigateTo(`/dashboard/bookings/${booking.id}`)
}

const editBooking = (booking: any) => {
  // Navigate to booking edit page
  navigateTo(`/dashboard/bookings/${booking.id}/edit`)
}

const clearFilters = () => {
  searchQuery.value = ''
  filterDate.value = ''
  filterStatus.value = ''
  currentPage.value = 1
}

// Watchers
watch([searchQuery, filterDate, filterStatus], () => {
  currentPage.value = 1
})

// Initialize
onMounted(() => {
  fetchBookings()
})
</script>