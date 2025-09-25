<template>
  <div>

    <!-- Content -->
    <div class="container mx-auto px-4 py-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-foreground mb-2">Mes réservations</h1>
        <p class="text-muted-foreground">
          Retrouvez toutes vos réservations de terrains de padel
        </p>
      </div>

      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <UiCard>
          <UiCardContent class="p-6">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-muted-foreground">Total réservations</p>
                <p class="text-2xl font-bold text-foreground">{{ totalBookings }}</p>
              </div>
              <Calendar class="h-8 w-8 text-primary" />
            </div>
          </UiCardContent>
        </UiCard>

        <UiCard>
          <UiCardContent class="p-6">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-muted-foreground">Prochaine réservation</p>
                <p class="text-lg font-bold text-foreground">
                  {{ nextBooking ? formatDate(nextBooking.booking_date) : 'Aucune' }}
                </p>
              </div>
              <Clock class="h-8 w-8 text-blue-600" />
            </div>
          </UiCardContent>
        </UiCard>

        <UiCard>
          <UiCardContent class="p-6">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-muted-foreground">Matchs joués</p>
                <p class="text-2xl font-bold text-foreground">{{ matchsPlayed }}</p>
              </div>
              <Trophy class="h-8 w-8 text-green-600" />
            </div>
          </UiCardContent>
        </UiCard>
      </div>

      <!-- Filters -->
      <div class="mb-6 flex flex-col md:flex-row gap-4 items-start md:items-end">
        <div>
          <label class="block text-sm font-medium mb-2">Statut</label>
          <select
            v-model="filterStatus"
            class="flex h-10 w-40 rounded-md border border-input bg-background px-3 py-2 text-sm"
          >
            <option value="">Toutes</option>
            <option value="confirmed">Confirmées</option>
            <option value="pending">En attente</option>
            <option value="cancelled">Annulées</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium mb-2">Période</label>
          <select
            v-model="filterPeriod"
            class="flex h-10 w-40 rounded-md border border-input bg-background px-3 py-2 text-sm"
          >
            <option value="all">Toutes</option>
            <option value="upcoming">À venir</option>
            <option value="past">Passées</option>
            <option value="month">Ce mois</option>
          </select>
        </div>

        <UiButton @click="clearFilters" variant="outline">
          <X class="mr-2 h-4 w-4" />
          Effacer
        </UiButton>
      </div>

      <!-- Bookings List -->
      <div v-if="loading" class="text-center py-20">
        <Loader2 class="h-8 w-8 animate-spin mx-auto text-primary" />
        <p class="mt-2 text-muted-foreground">Chargement de vos réservations...</p>
      </div>

      <div v-else-if="filteredBookings.length === 0" class="text-center py-20">
        <Calendar class="h-12 w-12 text-muted-foreground mx-auto mb-4" />
        <h2 class="text-2xl font-semibold text-foreground mb-2">Aucune réservation</h2>
        <p class="text-muted-foreground mb-6">
          Vous n'avez pas encore de réservation. Trouvez un centre près de chez vous !
        </p>
        <UiButton @click="navigateTo('/')">
          <Search class="mr-2 h-4 w-4" />
          Rechercher un centre
        </UiButton>
      </div>

      <div v-else class="space-y-4">
        <UiCard
          v-for="booking in filteredBookings"
          :key="booking.id"
          class="hover:shadow-md transition-shadow"
        >
          <UiCardContent class="p-6">
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <div class="flex items-center space-x-4 mb-3">
                  <div>
                    <h3 class="font-semibold text-lg">{{ booking.centers?.name }}</h3>
                    <p class="text-sm text-muted-foreground">{{ booking.courts?.name }}</p>
                  </div>
                  <UiBadge :variant="getStatusVariant(booking.status)">
                    {{ getStatusText(booking.status) }}
                  </UiBadge>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                  <div>
                    <div class="text-muted-foreground">Date</div>
                    <div class="font-medium">{{ formatDate(booking.booking_date) }}</div>
                  </div>
                  <div>
                    <div class="text-muted-foreground">Heure</div>
                    <div class="font-medium">{{ booking.start_time.slice(0, 5) }} - {{ booking.end_time.slice(0, 5) }}</div>
                  </div>
                  <div>
                    <div class="text-muted-foreground">Joueurs</div>
                    <div class="font-medium">{{ booking.player_count }} joueur(s)</div>
                  </div>
                </div>


                <div v-if="booking.special_requests" class="mt-3">
                  <div class="text-sm text-muted-foreground">Demandes particulières :</div>
                  <div class="text-sm">{{ booking.special_requests }}</div>
                </div>
              </div>

              <div class="text-right ml-4">
                <div class="text-2xl font-bold text-primary mb-2">{{ booking.total_price }}€</div>
                <div class="space-y-2">
                  <UiButton
                    v-if="canCancel(booking)"
                    variant="outline"
                    size="sm"
                    @click="cancelBooking(booking)"
                  >
                    <X class="mr-1 h-3 w-3" />
                    Annuler
                  </UiButton>
                  <UiButton
                    variant="outline"
                    size="sm"
                    @click="viewCenter(booking.centers?.id)"
                  >
                    <MapPin class="mr-1 h-3 w-3" />
                    Voir le centre
                  </UiButton>
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
import { ref, computed, onMounted } from 'vue'
import {
  ArrowLeft, Calendar, Clock, Trophy, X, Loader2, Search, MapPin
} from 'lucide-vue-next'

// Middleware to protect the route
definePageMeta({
  layout: 'default'
})

// SEO
useHead({
  title: 'Mes réservations - PadelSpot',
  meta: [
    { name: 'description', content: 'Consultez toutes vos réservations de terrains de padel.' },
    { name: 'robots', content: 'noindex' },
  ],
})

// Auth
const user = useSupabaseUser()
const supabase = useSupabaseClient()

// Reactive data
const loading = ref(true)
const bookings = ref<any[]>([])
const filterStatus = ref('')
const filterPeriod = ref('all')

// Computed
const filteredBookings = computed(() => {
  let filtered = bookings.value

  if (filterStatus.value) {
    filtered = filtered.filter(booking => booking.status === filterStatus.value)
  }

  if (filterPeriod.value !== 'all') {
    const now = new Date()
    const today = now.toISOString().split('T')[0]
    const thisMonth = now.toISOString().slice(0, 7)

    switch (filterPeriod.value) {
      case 'upcoming':
        filtered = filtered.filter(booking => booking.booking_date >= today)
        break
      case 'past':
        filtered = filtered.filter(booking => booking.booking_date < today)
        break
      case 'month':
        filtered = filtered.filter(booking => booking.booking_date.startsWith(thisMonth))
        break
    }
  }

  return filtered.sort((a, b) => new Date(b.booking_date).getTime() - new Date(a.booking_date).getTime())
})

const totalBookings = computed(() => bookings.value.length)

const nextBooking = computed(() => {
  const upcoming = bookings.value
    .filter(b => b.booking_date >= new Date().toISOString().split('T')[0] && b.status === 'confirmed')
    .sort((a, b) => new Date(a.booking_date).getTime() - new Date(b.booking_date).getTime())
  return upcoming[0] || null
})

const matchsPlayed = computed(() => {
  const today = new Date().toISOString().split('T')[0]
  return bookings.value
    .filter(b => b.status === 'confirmed' && b.booking_date < today)
    .length
})

// Methods
const fetchBookings = async () => {
  loading.value = true

  try {
    const { data, error } = await supabase
      .from('bookings')
      .select(`
        *,
        centers!inner(id, name),
        courts!inner(name)
      `)
      .eq('user_id', user.value?.id)
      .order('booking_date', { ascending: false })

    if (error) throw error

    bookings.value = data || []

  } catch (error) {
    console.error('Error fetching bookings:', error)
  } finally {
    loading.value = false
  }
}

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString('fr-FR', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
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

const canCancel = (booking: any) => {
  const bookingDateTime = new Date(`${booking.booking_date}T${booking.start_time}`)
  const now = new Date()
  const hoursUntilBooking = (bookingDateTime.getTime() - now.getTime()) / (1000 * 60 * 60)

  return booking.status === 'confirmed' && hoursUntilBooking > 24
}

const cancelBooking = async (booking: any) => {
  if (!confirm('Êtes-vous sûr de vouloir annuler cette réservation ?')) return

  try {
    const { error } = await supabase
      .from('bookings')
      .update({ status: 'cancelled' })
      .eq('id', booking.id)

    if (error) throw error

    await fetchBookings()

  } catch (error) {
    console.error('Error cancelling booking:', error)
    alert('Erreur lors de l\'annulation. Veuillez réessayer.')
  }
}

const viewCenter = (centerId: string) => {
  if (centerId) {
    navigateTo(`/centers/${centerId}`)
  }
}

const clearFilters = () => {
  filterStatus.value = ''
  filterPeriod.value = 'all'
}


// Initialize
onMounted(() => {
  fetchBookings()
})
</script>