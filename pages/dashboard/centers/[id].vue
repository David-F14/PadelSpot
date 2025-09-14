<template>
  <div class="min-h-screen bg-background">
    <!-- Header -->
    <header class="border-b border-border bg-card">
      <div class="container mx-auto px-4 py-4">
        <nav class="flex items-center justify-between">
          <div class="flex items-center space-x-4">
            <UiButton variant="ghost" size="sm" @click="navigateTo('/dashboard')">
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
              Paramètres du centre
            </div>
          </div>
        </nav>
      </div>
    </header>

    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center py-20">
      <Loader2 class="h-8 w-8 animate-spin text-primary" />
      <span class="ml-2 text-muted-foreground">Chargement des informations...</span>
    </div>

    <!-- Not Found -->
    <div v-else-if="!center" class="text-center py-20">
      <Building2 class="h-12 w-12 text-muted-foreground mx-auto mb-4" />
      <h2 class="text-2xl font-semibold text-foreground mb-2">Centre introuvable</h2>
      <p class="text-muted-foreground mb-6">
        Le centre demandé n'existe pas ou vous n'avez pas les permissions pour y accéder.
      </p>
      <UiButton @click="navigateTo('/dashboard')">
        Retour au dashboard
      </UiButton>
    </div>

    <!-- Center Settings -->
    <div v-else class="container mx-auto px-4 py-8">
      <div class="max-w-4xl mx-auto">
        <!-- Header with actions -->
        <div class="flex items-center justify-between mb-8">
          <div>
            <h1 class="text-3xl font-bold text-foreground">{{ center.name }}</h1>
            <p class="text-muted-foreground">Gérez les paramètres de votre centre</p>
          </div>
          <div class="flex space-x-3">
            <UiButton variant="outline" @click="navigateTo(`/centers/${center.id}`)">
              <Eye class="mr-2 h-4 w-4" />
              Voir la page
            </UiButton>
            <UiButton @click="saveCenter" :disabled="saving">
              <Loader2 v-if="saving" class="mr-2 h-4 w-4 animate-spin" />
              <Save v-else class="mr-2 h-4 w-4" />
              Enregistrer
            </UiButton>
          </div>
        </div>

        <div class="space-y-8">
          <!-- Basic Information -->
          <UiCard>
            <UiCardHeader>
              <UiCardTitle>Informations générales</UiCardTitle>
            </UiCardHeader>
            <UiCardContent class="space-y-6">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label class="block text-sm font-medium mb-2">Nom du centre *</label>
                  <UiInput v-model="center.name" required />
                </div>
                <div>
                  <label class="block text-sm font-medium mb-2">Email</label>
                  <UiInput v-model="center.email" type="email" />
                </div>
                <div>
                  <label class="block text-sm font-medium mb-2">Téléphone</label>
                  <UiInput v-model="center.phone" />
                </div>
                <div>
                  <label class="block text-sm font-medium mb-2">Site web</label>
                  <UiInput v-model="center.website" type="url" />
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium mb-2">Description</label>
                <textarea 
                  v-model="center.description"
                  class="flex min-h-[100px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                  placeholder="Décrivez votre centre..."
                ></textarea>
              </div>
            </UiCardContent>
          </UiCard>

          <!-- Address Information -->
          <UiCard>
            <UiCardHeader>
              <UiCardTitle>Adresse</UiCardTitle>
            </UiCardHeader>
            <UiCardContent class="space-y-6">
              <div>
                <label class="block text-sm font-medium mb-2">Adresse ligne 1 *</label>
                <UiInput v-model="center.address_line1" required />
              </div>
              <div>
                <label class="block text-sm font-medium mb-2">Adresse ligne 2</label>
                <UiInput v-model="center.address_line2" />
              </div>
              <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                  <label class="block text-sm font-medium mb-2">Ville *</label>
                  <UiInput v-model="center.city" required />
                </div>
                <div>
                  <label class="block text-sm font-medium mb-2">Code postal *</label>
                  <UiInput v-model="center.postal_code" required />
                </div>
                <div>
                  <label class="block text-sm font-medium mb-2">Pays</label>
                  <UiInput v-model="center.country" />
                </div>
              </div>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label class="block text-sm font-medium mb-2">Latitude</label>
                  <UiInput v-model="center.latitude" type="number" step="0.000001" />
                </div>
                <div>
                  <label class="block text-sm font-medium mb-2">Longitude</label>
                  <UiInput v-model="center.longitude" type="number" step="0.000001" />
                </div>
              </div>
            </UiCardContent>
          </UiCard>

          <!-- Opening Hours -->
          <UiCard>
            <UiCardHeader>
              <UiCardTitle>Horaires d'ouverture</UiCardTitle>
            </UiCardHeader>
            <UiCardContent>
              <div class="space-y-4">
                <div 
                  v-for="(day, key) in daysOfWeek" 
                  :key="key"
                  class="flex items-center space-x-4 py-2"
                >
                  <div class="w-20 text-sm font-medium capitalize">{{ day }}</div>
                  <div class="flex items-center space-x-4 flex-1">
                    <label class="flex items-center">
                      <input 
                        v-model="center.opening_hours[key].closed"
                        type="checkbox"
                        class="mr-2"
                      />
                      <span class="text-sm">Fermé</span>
                    </label>
                    <template v-if="!center.opening_hours[key].closed">
                      <UiInput
                        v-model="center.opening_hours[key].open"
                        type="time"
                        class="w-32"
                      />
                      <span class="text-sm text-muted-foreground">à</span>
                      <UiInput
                        v-model="center.opening_hours[key].close"
                        type="time"
                        class="w-32"
                      />
                    </template>
                  </div>
                </div>
              </div>
            </UiCardContent>
          </UiCard>

          <!-- Settings -->
          <UiCard>
            <UiCardHeader>
              <UiCardTitle>Paramètres</UiCardTitle>
            </UiCardHeader>
            <UiCardContent class="space-y-6">
              <div class="flex items-center justify-between">
                <div>
                  <div class="font-medium">Centre actif</div>
                  <div class="text-sm text-muted-foreground">
                    Le centre est visible et peut recevoir des réservations
                  </div>
                </div>
                <label class="relative inline-flex items-center cursor-pointer">
                  <input v-model="center.is_active" type="checkbox" class="sr-only peer" />
                  <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>
              
              <div class="flex items-center justify-between">
                <div>
                  <div class="font-medium">Réservations en ligne</div>
                  <div class="text-sm text-muted-foreground">
                    Accepter les réservations via PadelSpot
                  </div>
                </div>
                <label class="relative inline-flex items-center cursor-pointer">
                  <input v-model="center.accepts_online_booking" type="checkbox" class="sr-only peer" />
                  <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                </label>
              </div>

              <div>
                <label class="block text-sm font-medium mb-2">Réservation à l'avance (jours)</label>
                <UiInput
                  v-model="center.booking_advance_days"
                  type="number"
                  min="1"
                  max="365"
                  class="w-32"
                />
              </div>

              <div>
                <label class="block text-sm font-medium mb-2">Politique d'annulation</label>
                <textarea 
                  v-model="center.cancellation_policy"
                  class="flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                  placeholder="Décrivez votre politique d'annulation..."
                ></textarea>
              </div>
            </UiCardContent>
          </UiCard>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { 
  ArrowLeft, Building2, Eye, Save, Loader2
} from 'lucide-vue-next'

// Middleware to protect the route
definePageMeta({
  middleware: 'auth'
})

// SEO
useHead({
  title: 'Paramètres Centre - Dashboard Gérant - PadelSpot',
  meta: [
    { name: 'robots', content: 'noindex' },
  ],
})

// Get route params
const route = useRoute()
const centerId = route.params.id as string

// Auth
const user = useSupabaseUser()
const supabase = useSupabaseClient()

// Reactive data
const loading = ref(true)
const saving = ref(false)
const center = ref<any>(null)

const daysOfWeek = {
  monday: 'Lundi',
  tuesday: 'Mardi', 
  wednesday: 'Mercredi',
  thursday: 'Jeudi',
  friday: 'Vendredi',
  saturday: 'Samedi',
  sunday: 'Dimanche'
}

// Methods
const fetchCenter = async () => {
  loading.value = true
  
  try {
    const { data, error } = await supabase
      .from('centers')
      .select('*')
      .eq('id', centerId)
      .eq('manager_user_id', user.value?.id)
      .single()
    
    if (error) throw error
    
    center.value = data
    
    // Ensure opening_hours has the correct structure
    if (!center.value.opening_hours) {
      center.value.opening_hours = {
        monday: { open: '08:00', close: '22:00', closed: false },
        tuesday: { open: '08:00', close: '22:00', closed: false },
        wednesday: { open: '08:00', close: '22:00', closed: false },
        thursday: { open: '08:00', close: '22:00', closed: false },
        friday: { open: '08:00', close: '22:00', closed: false },
        saturday: { open: '08:00', close: '22:00', closed: false },
        sunday: { open: '09:00', close: '21:00', closed: false }
      }
    }
    
  } catch (error) {
    console.error('Error fetching center:', error)
    center.value = null
  } finally {
    loading.value = false
  }
}

const saveCenter = async () => {
  if (!center.value) return
  
  saving.value = true
  
  try {
    const { error } = await supabase
      .from('centers')
      .update({
        name: center.value.name,
        description: center.value.description,
        email: center.value.email,
        phone: center.value.phone,
        website: center.value.website,
        address_line1: center.value.address_line1,
        address_line2: center.value.address_line2,
        city: center.value.city,
        postal_code: center.value.postal_code,
        country: center.value.country,
        latitude: center.value.latitude ? parseFloat(center.value.latitude) : null,
        longitude: center.value.longitude ? parseFloat(center.value.longitude) : null,
        opening_hours: center.value.opening_hours,
        is_active: center.value.is_active,
        accepts_online_booking: center.value.accepts_online_booking,
        booking_advance_days: parseInt(center.value.booking_advance_days) || 30,
        cancellation_policy: center.value.cancellation_policy,
        updated_at: new Date().toISOString()
      })
      .eq('id', centerId)
    
    if (error) throw error
    
    // Show success message (you could add a toast notification here)
    console.log('Center updated successfully')
    
  } catch (error) {
    console.error('Error saving center:', error)
    // Show error message
  } finally {
    saving.value = false
  }
}

// Initialize
onMounted(() => {
  fetchCenter()
})
</script>