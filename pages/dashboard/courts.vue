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
              Gestion des terrains
            </div>
          </div>
        </nav>
      </div>
    </header>

    <!-- Content -->
    <div class="container mx-auto px-4 py-8">
      <!-- Header with actions -->
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-3xl font-bold text-foreground">Terrains</h1>
          <p class="text-muted-foreground">Gérez les terrains de vos centres</p>
        </div>
        <UiButton @click="showCreateModal = true">
          <Plus class="mr-2 h-4 w-4" />
          Ajouter un terrain
        </UiButton>
      </div>

      <!-- Center Selector -->
      <div class="mb-8 w-80">
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

      <!-- Courts Grid -->
      <div v-if="loading" class="text-center py-20">
        <Loader2 class="h-8 w-8 animate-spin mx-auto text-primary" />
        <p class="mt-2 text-muted-foreground">Chargement des terrains...</p>
      </div>
      
      <div v-else-if="filteredCourts.length === 0" class="text-center py-20">
        <MapPin class="h-12 w-12 text-muted-foreground mx-auto mb-4" />
        <h2 class="text-2xl font-semibold text-foreground mb-2">Aucun terrain</h2>
        <p class="text-muted-foreground mb-6">
          {{ selectedCenterId ? 'Ce centre n\'a pas encore de terrain.' : 'Vous n\'avez pas encore créé de terrain.' }}
        </p>
        <UiButton @click="showCreateModal = true">
          <Plus class="mr-2 h-4 w-4" />
          Créer le premier terrain
        </UiButton>
      </div>
      
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <UiCard 
          v-for="court in filteredCourts" 
          :key="court.id"
          class="hover:shadow-md transition-shadow"
        >
          <UiCardHeader class="pb-3">
            <div class="flex items-start justify-between">
              <div>
                <UiCardTitle class="text-lg">{{ court.name }}</UiCardTitle>
                <div class="text-sm text-muted-foreground">{{ court.center_name }}</div>
              </div>
              <div class="flex space-x-1">
                <UiButton size="sm" variant="ghost" @click="editCourt(court)">
                  <Edit class="h-4 w-4" />
                </UiButton>
                <UiButton size="sm" variant="ghost" @click="deleteCourt(court)">
                  <Trash2 class="h-4 w-4 text-destructive" />
                </UiButton>
              </div>
            </div>
          </UiCardHeader>
          <UiCardContent class="space-y-4">
            <div class="grid grid-cols-2 gap-4 text-sm">
              <div>
                <div class="text-muted-foreground">Surface</div>
                <div class="capitalize font-medium">{{ court.surface_type.replace('_', ' ') }}</div>
              </div>
              <div>
                <div class="text-muted-foreground">Type</div>
                <div class="capitalize font-medium">{{ court.court_type.replace('_', ' ') }}</div>
              </div>
              <div>
                <div class="text-muted-foreground">Prix de base</div>
                <div class="font-bold text-primary">{{ court.base_price_per_hour }}€/h</div>
              </div>
              <div>
                <div class="text-muted-foreground">Statut</div>
                <UiBadge :variant="court.is_active ? 'default' : 'secondary'">
                  {{ court.is_active ? 'Actif' : 'Inactif' }}
                </UiBadge>
              </div>
            </div>
            
            <div class="flex flex-wrap gap-2">
              <UiBadge v-if="court.has_lighting" variant="outline" class="text-xs">
                <Lightbulb class="h-3 w-3 mr-1" />
                Éclairage
              </UiBadge>
              <UiBadge v-if="court.has_heating" variant="outline" class="text-xs">
                <Thermometer class="h-3 w-3 mr-1" />
                Chauffage
              </UiBadge>
              <UiBadge v-if="court.has_air_conditioning" variant="outline" class="text-xs">
                <Wind class="h-3 w-3 mr-1" />
                Climatisation
              </UiBadge>
            </div>
          </UiCardContent>
        </UiCard>
      </div>
    </div>

    <!-- Create/Edit Court Modal -->
    <div 
      v-if="showCreateModal || editingCourt" 
      class="fixed inset-0 bg-black/50 flex items-center justify-center z-50"
      @click.self="closeModal"
    >
      <div class="bg-background rounded-lg w-full max-w-md mx-4 max-h-[90vh] overflow-y-auto">
        <div class="p-6">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-xl font-semibold">
              {{ editingCourt ? 'Modifier le terrain' : 'Nouveau terrain' }}
            </h2>
            <UiButton variant="ghost" size="sm" @click="closeModal">
              <X class="h-4 w-4" />
            </UiButton>
          </div>
          
          <form @submit.prevent="saveCourt" class="space-y-4">
            <div>
              <label class="block text-sm font-medium mb-2">Centre *</label>
              <select 
                v-model="courtForm.center_id"
                class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                required
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
            
            <div>
              <label class="block text-sm font-medium mb-2">Nom du terrain *</label>
              <UiInput v-model="courtForm.name" placeholder="Ex: Court Central" required />
            </div>
            
            <div>
              <label class="block text-sm font-medium mb-2">Numéro du terrain *</label>
              <UiInput 
                v-model="courtForm.court_number" 
                type="number" 
                min="1"
                placeholder="1"
                required 
              />
            </div>
            
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium mb-2">Type de surface *</label>
                <select 
                  v-model="courtForm.surface_type"
                  class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  required
                >
                  <option value="">Choisir</option>
                  <option value="gazon_synthetique">Gazon synthétique</option>
                  <option value="terre_battue">Terre battue</option>
                  <option value="beton_poreux">Béton poreux</option>
                  <option value="resine">Résine</option>
                </select>
              </div>
              
              <div>
                <label class="block text-sm font-medium mb-2">Type de terrain *</label>
                <select 
                  v-model="courtForm.court_type"
                  class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  required
                >
                  <option value="">Choisir</option>
                  <option value="interieur">Intérieur</option>
                  <option value="exterieur">Extérieur</option>
                  <option value="semi_couvert">Semi-couvert</option>
                </select>
              </div>
            </div>
            
            <div>
              <label class="block text-sm font-medium mb-2">Prix de base (€/h) *</label>
              <UiInput 
                v-model="courtForm.base_price_per_hour" 
                type="number" 
                step="0.01" 
                min="0"
                required 
              />
            </div>
            
            <div>
              <label class="block text-sm font-medium mb-2">Description</label>
              <textarea 
                v-model="courtForm.description"
                class="flex min-h-[60px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                placeholder="Description du terrain..."
              ></textarea>
            </div>
            
            <div class="space-y-3">
              <label class="flex items-center">
                <input v-model="courtForm.has_lighting" type="checkbox" class="mr-2" />
                <span class="text-sm">Éclairage</span>
              </label>
              <label class="flex items-center">
                <input v-model="courtForm.has_heating" type="checkbox" class="mr-2" />
                <span class="text-sm">Chauffage</span>
              </label>
              <label class="flex items-center">
                <input v-model="courtForm.has_air_conditioning" type="checkbox" class="mr-2" />
                <span class="text-sm">Climatisation</span>
              </label>
              <label class="flex items-center">
                <input v-model="courtForm.is_active" type="checkbox" class="mr-2" />
                <span class="text-sm">Terrain actif</span>
              </label>
            </div>
            
            <div class="flex space-x-3 pt-4">
              <UiButton type="button" variant="outline" @click="closeModal" class="flex-1">
                Annuler
              </UiButton>
              <UiButton type="submit" :disabled="saving" class="flex-1">
                <Loader2 v-if="saving" class="mr-2 h-4 w-4 animate-spin" />
                {{ editingCourt ? 'Modifier' : 'Créer' }}
              </UiButton>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { 
  ArrowLeft, Plus, MapPin, Edit, Trash2, X, Loader2,
  Lightbulb, Thermometer, Home, Wind
} from 'lucide-vue-next'

// Middleware to protect the route
definePageMeta({
  middleware: 'auth'
})

// SEO
useHead({
  title: 'Terrains - Dashboard Gérant - PadelSpot',
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
const saving = ref(false)
const managedCenters = ref<any[]>([])
const courts = ref<any[]>([])
const selectedCenterId = ref(preselectedCenterId || '')
const showCreateModal = ref(false)
const editingCourt = ref<any>(null)

const courtForm = ref({
  center_id: preselectedCenterId || '',
  name: '',
  court_number: 1,
  description: '',
  surface_type: '',
  court_type: '',
  base_price_per_hour: 0,
  has_lighting: false,
  has_heating: false,
  has_air_conditioning: false,
  is_active: true
})

// Computed
const filteredCourts = computed(() => {
  if (!selectedCenterId.value) return courts.value
  return courts.value.filter(court => court.center_id === selectedCenterId.value)
})

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

const fetchCourts = async () => {
  loading.value = true
  
  try {
    const { data, error } = await supabase
      .from('courts_with_centers')
      .select('*')
      .in('center_id', managedCenters.value.map(c => c.id))
    
    if (error) throw error
    
    courts.value = data || []
    
  } catch (error) {
    console.error('Error fetching courts:', error)
  } finally {
    loading.value = false
  }
}

const editCourt = (court: any) => {
  editingCourt.value = court
  courtForm.value = {
    center_id: court.center_id,
    name: court.name,
    court_number: court.court_number,
    description: court.description || '',
    surface_type: court.surface_type,
    court_type: court.court_type,
    base_price_per_hour: court.base_price_per_hour,
    has_lighting: court.has_lighting,
    has_heating: court.has_heating,
    has_air_conditioning: court.has_air_conditioning,
    is_active: court.is_active
  }
}

const deleteCourt = async (court: any) => {
  if (!confirm(`Êtes-vous sûr de vouloir supprimer le terrain "${court.name}" ?`)) return
  
  try {
    const { error } = await supabase
      .from('courts')
      .delete()
      .eq('id', court.court_id)
    
    if (error) throw error
    
    await fetchCourts()
    
  } catch (error) {
    console.error('Error deleting court:', error)
  }
}

const saveCourt = async () => {
  saving.value = true
  
  try {
    if (editingCourt.value) {
      // Update existing court
      const { error } = await supabase
        .from('courts')
        .update({
          name: courtForm.value.name,
          court_number: parseInt(courtForm.value.court_number.toString()),
          description: courtForm.value.description || null,
          surface_type: courtForm.value.surface_type,
          court_type: courtForm.value.court_type,
          base_price_per_hour: parseFloat(courtForm.value.base_price_per_hour.toString()),
          has_lighting: courtForm.value.has_lighting,
          has_heating: courtForm.value.has_heating,
          has_air_conditioning: courtForm.value.has_air_conditioning,
          is_active: courtForm.value.is_active,
          updated_at: new Date().toISOString()
        })
        .eq('id', editingCourt.value.court_id)
      
      if (error) throw error
    } else {
      // Create new court
      const { error } = await supabase
        .from('courts')
        .insert({
          center_id: courtForm.value.center_id,
          name: courtForm.value.name,
          court_number: parseInt(courtForm.value.court_number.toString()),
          description: courtForm.value.description || null,
          surface_type: courtForm.value.surface_type,
          court_type: courtForm.value.court_type,
          base_price_per_hour: parseFloat(courtForm.value.base_price_per_hour.toString()),
          has_lighting: courtForm.value.has_lighting,
          has_heating: courtForm.value.has_heating,
          has_air_conditioning: courtForm.value.has_air_conditioning,
          is_active: courtForm.value.is_active
        })
      
      if (error) throw error
    }
    
    await fetchCourts()
    closeModal()
    
  } catch (error) {
    console.error('Error saving court:', error)
  } finally {
    saving.value = false
  }
}

const closeModal = () => {
  showCreateModal.value = false
  editingCourt.value = null
  courtForm.value = {
    center_id: preselectedCenterId || '',
    name: '',
    court_number: 1,
    description: '',
    surface_type: '',
    court_type: '',
    base_price_per_hour: 0,
    has_lighting: false,
    has_heating: false,
    has_air_conditioning: false,
    is_active: true
  }
}

// Initialize
onMounted(async () => {
  await fetchManagedCenters()
  await fetchCourts()
})
</script>