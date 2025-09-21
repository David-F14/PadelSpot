<template>
  <div>

    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center py-20">
      <Loader2 class="h-8 w-8 animate-spin text-primary" />
      <span class="ml-2 text-muted-foreground">Chargement du dashboard...</span>
    </div>

    <!-- No Centers Message -->
    <div v-else-if="managedCenters.length === 0" class="text-center py-20">
      <Building2 class="h-12 w-12 text-muted-foreground mx-auto mb-4" />
      <h2 class="text-2xl font-semibold text-foreground mb-2">Aucun centre géré</h2>
      <p class="text-muted-foreground mb-6">
        Vous ne gérez actuellement aucun centre de padel.
      </p>
      <UiButton @click="navigateTo('/dashboard/centers/create')">
        <Plus class="mr-2 h-4 w-4" />
        Créer un centre
      </UiButton>
    </div>

    <!-- Dashboard Content -->
    <div v-else class="container mx-auto px-4 py-8">
      <!-- Center Selector -->
      <div class="mb-8">
        <div class="w-80">
          <label class="block text-sm font-medium mb-2">Centre sélectionné</label>
          <select 
            v-model="selectedCenterId"
            class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
          >
            <option value="">Sélectionner un centre</option>
            <option 
              v-for="center in managedCenters" 
              :key="center.id" 
              :value="center.id"
            >
              {{ center.name }}
            </option>
          </select>
        </div>
      </div>

      <div v-if="selectedCenter" class="space-y-8">
        <!-- Quick Stats -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <UiCard>
            <UiCardContent class="p-6">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-muted-foreground">Réservations aujourd'hui</p>
                  <p class="text-2xl font-bold text-foreground">{{ todayBookings }}</p>
                </div>
                <Calendar class="h-8 w-8 text-primary" />
              </div>
            </UiCardContent>
          </UiCard>

          <UiCard>
            <UiCardContent class="p-6">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-muted-foreground">Revenus du mois</p>
                  <p class="text-2xl font-bold text-foreground">{{ monthlyRevenue }}€</p>
                </div>
                <TrendingUp class="h-8 w-8 text-green-600" />
              </div>
            </UiCardContent>
          </UiCard>

          <UiCard>
            <UiCardContent class="p-6">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-muted-foreground">Taux d'occupation</p>
                  <p class="text-2xl font-bold text-foreground">{{ occupancyRate }}%</p>
                </div>
                <Activity class="h-8 w-8 text-blue-600" />
              </div>
            </UiCardContent>
          </UiCard>

          <UiCard>
            <UiCardContent class="p-6">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-sm font-medium text-muted-foreground">Note moyenne</p>
                  <p class="text-2xl font-bold text-foreground">{{ selectedCenter.average_rating || 0 }}/5</p>
                </div>
                <Star class="h-8 w-8 text-yellow-600" />
              </div>
            </UiCardContent>
          </UiCard>
        </div>

        <!-- Quick Actions -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <UiButton @click="navigateTo(`/dashboard/bookings?center=${selectedCenterId}`)" class="h-16">
            <div class="text-center">
              <Calendar class="h-5 w-5 mx-auto mb-1" />
              <div class="text-sm">Réservations</div>
            </div>
          </UiButton>

          <UiButton @click="navigateTo(`/dashboard/centers/${selectedCenterId}`)" variant="outline" class="h-16">
            <div class="text-center">
              <Settings class="h-5 w-5 mx-auto mb-1" />
              <div class="text-sm">Paramètres</div>
            </div>
          </UiButton>

          <UiButton @click="navigateTo(`/dashboard/courts?center=${selectedCenterId}`)" variant="outline" class="h-16">
            <div class="text-center">
              <MapPin class="h-5 w-5 mx-auto mb-1" />
              <div class="text-sm">Terrains</div>
            </div>
          </UiButton>

          <UiButton @click="navigateTo(`/dashboard/analytics?center=${selectedCenterId}`)" variant="outline" class="h-16">
            <div class="text-center">
              <BarChart3 class="h-5 w-5 mx-auto mb-1" />
              <div class="text-sm">Statistiques</div>
            </div>
          </UiButton>
        </div>

        <!-- Recent Bookings -->
        <UiCard>
          <UiCardHeader>
            <div class="flex items-center justify-between">
              <UiCardTitle>Réservations récentes</UiCardTitle>
              <UiButton variant="outline" size="sm" @click="navigateTo(`/dashboard/bookings?center=${selectedCenterId}`)">
                Voir tout
              </UiButton>
            </div>
          </UiCardHeader>
          <UiCardContent>
            <div v-if="loadingBookings" class="text-center py-4">
              <Loader2 class="h-6 w-6 animate-spin mx-auto text-primary" />
            </div>
            <div v-else-if="recentBookings.length === 0" class="text-center py-8 text-muted-foreground">
              Aucune réservation récente
            </div>
            <div v-else class="space-y-4">
              <div 
                v-for="booking in recentBookings" 
                :key="booking.id"
                class="flex items-center justify-between p-4 border rounded-lg hover:bg-muted/50 transition-colors"
              >
                <div class="flex items-center space-x-4">
                  <div class="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center">
                    <User class="h-5 w-5 text-primary" />
                  </div>
                  <div>
                    <div class="font-medium">{{ formatBookingUser(booking) }}</div>
                    <div class="text-sm text-muted-foreground">
                      {{ formatDate(booking.booking_date) }} à {{ booking.start_time.slice(0, 5) }}
                    </div>
                  </div>
                </div>
                <div class="text-right">
                  <div class="font-medium">{{ booking.total_price }}€</div>
                  <div class="text-sm" :class="getStatusClass(booking.status)">
                    {{ getStatusText(booking.status) }}
                  </div>
                </div>
              </div>
            </div>
          </UiCardContent>
        </UiCard>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { 
  Building2, Plus, Calendar, TrendingUp, Activity, Star, 
  Settings, MapPin, BarChart3, User, Loader2
} from 'lucide-vue-next'

// Middleware to protect the route
definePageMeta({
  layout: 'default'
})

// SEO
useHead({
  title: 'Dashboard Gérant - PadelSpot',
  meta: [
    { name: 'description', content: 'Gérez vos centres de padel avec PadelSpot.' },
    { name: 'robots', content: 'noindex' },
  ],
})

// Auth
const user = useSupabaseUser()
const supabase = useSupabaseClient()

// Reactive data
const loading = ref(true)
const loadingBookings = ref(false)
const managedCenters = ref<any[]>([])
const selectedCenterId = ref('')
const recentBookings = ref<any[]>([])
const dashboardStats = ref({
  todayBookings: 0,
  monthlyRevenue: 0,
  occupancyRate: 0
})

// Computed
const selectedCenter = computed(() => {
  return managedCenters.value.find(center => center.id === selectedCenterId.value)
})

const todayBookings = computed(() => dashboardStats.value.todayBookings)
const monthlyRevenue = computed(() => dashboardStats.value.monthlyRevenue)
const occupancyRate = computed(() => dashboardStats.value.occupancyRate)

// Methods
const fetchManagedCenters = async () => {
  loading.value = true
  
  try {
    const { data, error } = await supabase
      .from('centers')
      .select('*')
      .eq('manager_user_id', user.value?.id)
      .eq('is_active', true)
    
    if (error) throw error
    
    managedCenters.value = data || []
    
    // Select first center by default
    if (managedCenters.value.length > 0 && !selectedCenterId.value) {
      selectedCenterId.value = managedCenters.value[0].id
    }
    
  } catch (error) {
    console.error('Error fetching managed centers:', error)
  } finally {
    loading.value = false
  }
}

const fetchDashboardStats = async (centerId: string) => {
  if (!centerId) return
  
  try {
    const today = new Date().toISOString().split('T')[0]
    const currentMonth = new Date().toISOString().slice(0, 7)
    
    // Today's bookings
    const { data: todayBookingsData } = await supabase
      .from('bookings')
      .select('id')
      .eq('center_id', centerId)
      .eq('booking_date', today)
      .eq('status', 'confirmed')
    
    // Monthly revenue
    const { data: monthlyBookings } = await supabase
      .from('bookings')
      .select('total_price')
      .eq('center_id', centerId)
      .gte('booking_date', currentMonth + '-01')
      .eq('payment_status', 'paid')
    
    const monthlyRevenue = monthlyBookings?.reduce((sum, booking) => sum + booking.total_price, 0) || 0
    
    // Occupancy rate (simplified calculation)
    const { data: courtsData } = await supabase
      .from('courts')
      .select('id')
      .eq('center_id', centerId)
      .eq('is_active', true)
    
    const totalSlots = (courtsData?.length || 0) * 10 // Assuming 10 slots per day per court
    const occupiedSlots = todayBookingsData?.length || 0
    const occupancyRate = totalSlots > 0 ? Math.round((occupiedSlots / totalSlots) * 100) : 0
    
    dashboardStats.value = {
      todayBookings: todayBookingsData?.length || 0,
      monthlyRevenue: Math.round(monthlyRevenue),
      occupancyRate
    }
    
  } catch (error) {
    console.error('Error fetching dashboard stats:', error)
  }
}

const fetchRecentBookings = async (centerId: string) => {
  if (!centerId) return
  
  loadingBookings.value = true
  
  try {
    const { data, error } = await supabase
      .from('bookings')
      .select(`
        *,
        user_profiles!inner(first_name, last_name, email),
        courts!inner(court_name)
      `)
      .eq('center_id', centerId)
      .order('created_at', { ascending: false })
      .limit(5)
    
    if (error) throw error
    
    recentBookings.value = data || []
    
  } catch (error) {
    console.error('Error fetching recent bookings:', error)
  } finally {
    loadingBookings.value = false
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
    month: 'short'
  })
}

const getStatusClass = (status: string) => {
  switch (status) {
    case 'confirmed': return 'text-green-600'
    case 'pending': return 'text-yellow-600'
    case 'cancelled': return 'text-red-600'
    default: return 'text-muted-foreground'
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


// Watchers
watch(selectedCenterId, (newCenterId) => {
  if (newCenterId) {
    fetchDashboardStats(newCenterId)
    fetchRecentBookings(newCenterId)
  }
})

// Initialize
onMounted(() => {
  fetchManagedCenters()
})
</script>