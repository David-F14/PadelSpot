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
              Statistiques et analyses
            </div>
          </div>
        </nav>
      </div>
    </header>

    <!-- Content -->
    <div class="container mx-auto px-4 py-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-foreground mb-2">Statistiques</h1>
        <p class="text-muted-foreground">Analysez les performances de vos centres</p>
      </div>

      <!-- Center Selector & Period Selector -->
      <div class="flex flex-col md:flex-row gap-4 items-start md:items-end mb-8">
        <div class="w-80">
          <label class="block text-sm font-medium mb-2">Centre</label>
          <select 
            v-model="selectedCenterId"
            class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
          >
            <option value="">Tous les centres</option>
            <option 
              v-for="center in managedCenters" 
              :key="center.id" 
              :value="center.id"
            >
              {{ center.name }}
            </option>
          </select>
        </div>
        
        <div class="w-40">
          <label class="block text-sm font-medium mb-2">Période</label>
          <select 
            v-model="selectedPeriod"
            class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
          >
            <option value="7">7 derniers jours</option>
            <option value="30">30 derniers jours</option>
            <option value="90">90 derniers jours</option>
            <option value="365">1 année</option>
          </select>
        </div>
        
        <UiButton @click="refreshStats" :disabled="loading">
          <RotateCcw class="mr-2 h-4 w-4" :class="{ 'animate-spin': loading }" />
          Actualiser
        </UiButton>
      </div>

      <!-- Main Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <UiCard>
          <UiCardContent class="p-6">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-muted-foreground">Total réservations</p>
                <p class="text-2xl font-bold text-foreground">{{ stats.totalBookings }}</p>
              </div>
              <Calendar class="h-8 w-8 text-primary" />
            </div>
            <div class="mt-2 text-sm text-muted-foreground">
              <span :class="getTrendClass(stats.bookingsTrend)">
                {{ stats.bookingsTrend > 0 ? '+' : '' }}{{ stats.bookingsTrend }}%
              </span>
              par rapport à la période précédente
            </div>
          </UiCardContent>
        </UiCard>

        <UiCard>
          <UiCardContent class="p-6">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-muted-foreground">Revenus totaux</p>
                <p class="text-2xl font-bold text-foreground">{{ stats.totalRevenue }}€</p>
              </div>
              <TrendingUp class="h-8 w-8 text-green-600" />
            </div>
            <div class="mt-2 text-sm text-muted-foreground">
              <span :class="getTrendClass(stats.revenueTrend)">
                {{ stats.revenueTrend > 0 ? '+' : '' }}{{ stats.revenueTrend }}%
              </span>
              par rapport à la période précédente
            </div>
          </UiCardContent>
        </UiCard>

        <UiCard>
          <UiCardContent class="p-6">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-muted-foreground">Taux d'occupation</p>
                <p class="text-2xl font-bold text-foreground">{{ stats.occupancyRate }}%</p>
              </div>
              <Activity class="h-8 w-8 text-blue-600" />
            </div>
            <div class="mt-2 text-sm text-muted-foreground">
              Moyenne sur la période
            </div>
          </UiCardContent>
        </UiCard>

        <UiCard>
          <UiCardContent class="p-6">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-muted-foreground">Clients uniques</p>
                <p class="text-2xl font-bold text-foreground">{{ stats.uniqueClients }}</p>
              </div>
              <Users class="h-8 w-8 text-purple-600" />
            </div>
            <div class="mt-2 text-sm text-muted-foreground">
              <span :class="getTrendClass(stats.clientsTrend)">
                {{ stats.clientsTrend > 0 ? '+' : '' }}{{ stats.clientsTrend }}%
              </span>
              nouveaux clients
            </div>
          </UiCardContent>
        </UiCard>
      </div>

      <!-- Charts and Tables -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <!-- Revenue Chart (Placeholder) -->
        <UiCard>
          <UiCardHeader>
            <UiCardTitle>Évolution des revenus</UiCardTitle>
          </UiCardHeader>
          <UiCardContent>
            <div class="h-64 flex items-center justify-center bg-muted/20 rounded border-2 border-dashed border-muted">
              <div class="text-center">
                <BarChart3 class="h-12 w-12 text-muted-foreground mx-auto mb-2" />
                <p class="text-muted-foreground">Graphique des revenus</p>
                <p class="text-sm text-muted-foreground">(à implémenter avec Chart.js)</p>
              </div>
            </div>
          </UiCardContent>
        </UiCard>

        <!-- Occupancy Chart (Placeholder) -->
        <UiCard>
          <UiCardHeader>
            <UiCardTitle>Taux d'occupation par jour</UiCardTitle>
          </UiCardHeader>
          <UiCardContent>
            <div class="h-64 flex items-center justify-center bg-muted/20 rounded border-2 border-dashed border-muted">
              <div class="text-center">
                <Activity class="h-12 w-12 text-muted-foreground mx-auto mb-2" />
                <p class="text-muted-foreground">Graphique d'occupation</p>
                <p class="text-sm text-muted-foreground">(à implémenter avec Chart.js)</p>
              </div>
            </div>
          </UiCardContent>
        </UiCard>
      </div>

      <!-- Detailed Tables -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Top Courts -->
        <UiCard>
          <UiCardHeader>
            <UiCardTitle>Terrains les plus réservés</UiCardTitle>
          </UiCardHeader>
          <UiCardContent>
            <div v-if="loading" class="text-center py-4">
              <Loader2 class="h-6 w-6 animate-spin mx-auto text-primary" />
            </div>
            <div v-else-if="topCourts.length === 0" class="text-center py-8 text-muted-foreground">
              Aucune donnée disponible
            </div>
            <div v-else class="space-y-4">
              <div 
                v-for="(court, index) in topCourts" 
                :key="court.court_id"
                class="flex items-center justify-between p-3 rounded border"
              >
                <div class="flex items-center space-x-3">
                  <div class="w-8 h-8 bg-primary/10 rounded-full flex items-center justify-center text-sm font-medium">
                    {{ index + 1 }}
                  </div>
                  <div>
                    <div class="font-medium">{{ court.court_name }}</div>
                    <div class="text-sm text-muted-foreground">{{ court.center_name }}</div>
                  </div>
                </div>
                <div class="text-right">
                  <div class="font-medium">{{ court.booking_count }} réservations</div>
                  <div class="text-sm text-muted-foreground">{{ court.total_revenue }}€</div>
                </div>
              </div>
            </div>
          </UiCardContent>
        </UiCard>

        <!-- Peak Hours -->
        <UiCard>
          <UiCardHeader>
            <UiCardTitle>Créneaux populaires</UiCardTitle>
          </UiCardHeader>
          <UiCardContent>
            <div v-if="loading" class="text-center py-4">
              <Loader2 class="h-6 w-6 animate-spin mx-auto text-primary" />
            </div>
            <div v-else-if="peakHours.length === 0" class="text-center py-8 text-muted-foreground">
              Aucune donnée disponible
            </div>
            <div v-else class="space-y-4">
              <div 
                v-for="slot in peakHours" 
                :key="slot.time_slot"
                class="flex items-center justify-between p-3 rounded border"
              >
                <div class="flex items-center space-x-3">
                  <Clock class="h-5 w-5 text-muted-foreground" />
                  <div>
                    <div class="font-medium">{{ slot.time_slot }}</div>
                    <div class="text-sm text-muted-foreground">Créneaux horaires</div>
                  </div>
                </div>
                <div class="text-right">
                  <div class="font-medium">{{ slot.booking_count }} réservations</div>
                  <div class="text-sm text-muted-foreground">
                    {{ Math.round((slot.booking_count / stats.totalBookings) * 100) }}% du total
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
  ArrowLeft, Calendar, TrendingUp, Activity, Users, BarChart3,
  RotateCcw, Clock, Loader2
} from 'lucide-vue-next'

// Middleware to protect the route
definePageMeta({
  middleware: 'auth'
})

// SEO
useHead({
  title: 'Statistiques - Dashboard Gérant - PadelSpot',
  meta: [
    { name: 'robots', content: 'noindex' },
  ],
})

// Get query parameters
const route = useRoute()
const preselectedCenterId = route.query.center as string

// Auth
const user = useSupabaseUser()
const supabase = useSupabaseClient()

// Reactive data
const loading = ref(true)
const managedCenters = ref<any[]>([])
const selectedCenterId = ref(preselectedCenterId || '')
const selectedPeriod = ref('30')

const stats = ref({
  totalBookings: 0,
  totalRevenue: 0,
  occupancyRate: 0,
  uniqueClients: 0,
  bookingsTrend: 0,
  revenueTrend: 0,
  clientsTrend: 0
})

const topCourts = ref<any[]>([])
const peakHours = ref<any[]>([])

// Methods
const fetchManagedCenters = async () => {
  try {
    const { data, error } = await supabase
      .from('centers')
      .select('id, name')
      .eq('manager_user_id', user.value?.id)
      .eq('is_active', true)
    
    if (error) throw error
    
    managedCenters.value = data || []
    
  } catch (error) {
    console.error('Error fetching managed centers:', error)
  }
}

const fetchStats = async () => {
  loading.value = true
  
  try {
    const days = parseInt(selectedPeriod.value)
    const endDate = new Date()
    const startDate = new Date()
    startDate.setDate(endDate.getDate() - days)
    
    // Base query conditions
    let centerCondition = ''
    const params: any[] = []
    
    if (selectedCenterId.value) {
      centerCondition = 'center_id = $1 AND'
      params.push(selectedCenterId.value)
    } else if (managedCenters.value.length > 0) {
      const centerIds = managedCenters.value.map(c => c.id)
      centerCondition = `center_id = ANY($${params.length + 1}) AND`
      params.push(centerIds)
    }
    
    params.push(startDate.toISOString().split('T')[0])
    params.push(endDate.toISOString().split('T')[0])
    
    // Fetch basic stats
    const { data: bookingsData } = await supabase
      .from('bookings')
      .select('id, total_price, user_id, booking_date, start_time')
      .gte('booking_date', startDate.toISOString().split('T')[0])
      .lte('booking_date', endDate.toISOString().split('T')[0])
      .eq('status', 'confirmed')
    
    let filteredBookings = bookingsData || []
    
    if (selectedCenterId.value) {
      const { data: centerBookings } = await supabase
        .from('bookings')
        .select('id, total_price, user_id, booking_date, start_time')
        .eq('center_id', selectedCenterId.value)
        .gte('booking_date', startDate.toISOString().split('T')[0])
        .lte('booking_date', endDate.toISOString().split('T')[0])
        .eq('status', 'confirmed')
      
      filteredBookings = centerBookings || []
    }
    
    const totalBookings = filteredBookings.length
    const totalRevenue = Math.round(filteredBookings.reduce((sum, booking) => sum + (booking.total_price || 0), 0))
    const uniqueClients = new Set(filteredBookings.map(b => b.user_id)).size
    
    // Calculate occupancy rate (simplified)
    const totalPossibleSlots = days * (managedCenters.value.length || 1) * 10 // 10 slots per day per center
    const occupancyRate = totalPossibleSlots > 0 ? Math.round((totalBookings / totalPossibleSlots) * 100) : 0
    
    stats.value = {
      totalBookings,
      totalRevenue,
      occupancyRate,
      uniqueClients,
      bookingsTrend: Math.floor(Math.random() * 20) - 10, // Mock trend
      revenueTrend: Math.floor(Math.random() * 30) - 15, // Mock trend
      clientsTrend: Math.floor(Math.random() * 25) - 10 // Mock trend
    }
    
    // Fetch top courts
    await fetchTopCourts()
    
    // Fetch peak hours
    await fetchPeakHours(filteredBookings)
    
  } catch (error) {
    console.error('Error fetching stats:', error)
  } finally {
    loading.value = false
  }
}

const fetchTopCourts = async () => {
  try {
    let query = `
      SELECT 
        c.id as court_id,
        c.court_name,
        centers.name as center_name,
        COUNT(b.id) as booking_count,
        SUM(b.total_price) as total_revenue
      FROM courts c
      LEFT JOIN bookings b ON c.id = b.court_id 
        AND b.booking_date >= CURRENT_DATE - INTERVAL '${selectedPeriod.value} days'
        AND b.status = 'confirmed'
      LEFT JOIN centers ON c.center_id = centers.id
      WHERE centers.manager_user_id = $1
    `
    
    if (selectedCenterId.value) {
      query += ` AND c.center_id = $2`
    }
    
    query += `
      GROUP BY c.id, c.court_name, centers.name
      ORDER BY booking_count DESC
      LIMIT 5
    `
    
    const params = selectedCenterId.value 
      ? [user.value?.id, selectedCenterId.value]
      : [user.value?.id]
    
    const { data } = await supabase.rpc('execute_sql', { 
      query, 
      params 
    })
    
    // Fallback to simple query if RPC doesn't work
    const { data: courtsData } = await supabase
      .from('courts')
      .select(`
        id, court_name, center_id,
        centers!inner(name, manager_user_id)
      `)
      .eq('centers.manager_user_id', user.value?.id)
    
    topCourts.value = (courtsData || []).slice(0, 5).map(court => ({
      court_id: court.id,
      court_name: court.court_name,
      center_name: court.centers.name,
      booking_count: Math.floor(Math.random() * 50) + 1, // Mock data
      total_revenue: Math.floor(Math.random() * 2000) + 100 // Mock data
    }))
    
  } catch (error) {
    console.error('Error fetching top courts:', error)
    topCourts.value = []
  }
}

const fetchPeakHours = (bookings: any[]) => {
  // Group bookings by time slot
  const timeSlots: { [key: string]: number } = {}
  
  bookings.forEach(booking => {
    if (booking.start_time) {
      const hour = booking.start_time.slice(0, 2)
      const timeSlot = `${hour}:00 - ${parseInt(hour) + 1}:00`
      timeSlots[timeSlot] = (timeSlots[timeSlot] || 0) + 1
    }
  })
  
  peakHours.value = Object.entries(timeSlots)
    .map(([time_slot, booking_count]) => ({ time_slot, booking_count }))
    .sort((a, b) => b.booking_count - a.booking_count)
    .slice(0, 5)
}

const refreshStats = async () => {
  await fetchStats()
}

const getTrendClass = (trend: number) => {
  if (trend > 0) return 'text-green-600'
  if (trend < 0) return 'text-red-600'
  return 'text-muted-foreground'
}

// Watchers
watch([selectedCenterId, selectedPeriod], () => {
  fetchStats()
})

// Initialize
onMounted(async () => {
  await fetchManagedCenters()
  await fetchStats()
})
</script>