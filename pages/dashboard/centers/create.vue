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
              Créer un centre
            </div>
          </div>
        </nav>
      </div>
    </header>

    <!-- Content -->
    <div class="container mx-auto px-4 py-8">
      <div class="max-w-4xl mx-auto">
        <!-- Header -->
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-foreground mb-2">Créer un nouveau centre</h1>
          <p class="text-muted-foreground">
            Remplissez les informations de votre centre de padel pour commencer à recevoir des réservations.
          </p>
        </div>

        <!-- Form -->
        <form @submit.prevent="createCenter" class="space-y-8">
          <!-- Basic Information -->
          <UiCard>
            <UiCardHeader>
              <UiCardTitle>Informations générales</UiCardTitle>
              <p class="text-sm text-muted-foreground">
                Les informations de base qui seront visibles sur votre page centre
              </p>
            </UiCardHeader>
            <UiCardContent class="space-y-6">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label class="block text-sm font-medium mb-2">
                    Nom du centre *
                  </label>
                  <UiInput 
                    v-model="form.name" 
                    placeholder="Ex: Padel Club Paris"
                    required 
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium mb-2">Email</label>
                  <UiInput 
                    v-model="form.email" 
                    type="email" 
                    placeholder="contact@padelclub.fr"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium mb-2">Téléphone</label>
                  <UiInput 
                    v-model="form.phone" 
                    placeholder="01 23 45 67 89"
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium mb-2">Site web</label>
                  <UiInput 
                    v-model="form.website" 
                    type="url" 
                    placeholder="https://padelclub.fr"
                  />
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium mb-2">Description</label>
                <textarea 
                  v-model="form.description"
                  class="flex min-h-[100px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                  placeholder="Décrivez votre centre, ses équipements, son ambiance..."
                ></textarea>
              </div>
            </UiCardContent>
          </UiCard>

          <!-- Address Information -->
          <UiCard>
            <UiCardHeader>
              <UiCardTitle>Adresse</UiCardTitle>
              <p class="text-sm text-muted-foreground">
                L'adresse complète permet aux clients de vous trouver facilement
              </p>
            </UiCardHeader>
            <UiCardContent class="space-y-6">
              <div>
                <label class="block text-sm font-medium mb-2">
                  Adresse ligne 1 *
                </label>
                <UiInput 
                  v-model="form.address_line1" 
                  placeholder="123 Rue de la République"
                  required 
                />
              </div>
              <div>
                <label class="block text-sm font-medium mb-2">Adresse ligne 2</label>
                <UiInput 
                  v-model="form.address_line2" 
                  placeholder="Bâtiment A, 2e étage"
                />
              </div>
              <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                  <label class="block text-sm font-medium mb-2">Ville *</label>
                  <UiInput 
                    v-model="form.city" 
                    placeholder="Paris"
                    required 
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium mb-2">Code postal *</label>
                  <UiInput 
                    v-model="form.postal_code" 
                    placeholder="75001"
                    required 
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium mb-2">Pays</label>
                  <UiInput 
                    v-model="form.country" 
                    placeholder="France"
                  />
                </div>
              </div>
              
              <!-- Geolocation Helper -->
              <div class="bg-muted/30 p-4 rounded-lg">
                <div class="flex items-start space-x-3">
                  <MapPin class="h-5 w-5 text-muted-foreground mt-0.5" />
                  <div>
                    <h4 class="font-medium">Position géographique</h4>
                    <p class="text-sm text-muted-foreground mb-3">
                      Nous détecterons automatiquement les coordonnées de votre centre à partir de l'adresse.
                      Vous pourrez les ajuster après la création si nécessaire.
                    </p>
                  </div>
                </div>
              </div>
            </UiCardContent>
          </UiCard>

          <!-- Opening Hours -->
          <UiCard>
            <UiCardHeader>
              <UiCardTitle>Horaires d'ouverture</UiCardTitle>
              <p class="text-sm text-muted-foreground">
                Définissez vos horaires pour chaque jour de la semaine
              </p>
            </UiCardHeader>
            <UiCardContent>
              <div class="space-y-4">
                <div 
                  v-for="(day, key) in daysOfWeek" 
                  :key="key"
                  class="flex items-center space-x-4 py-2"
                >
                  <div class="w-24 text-sm font-medium capitalize">{{ day }}</div>
                  <div class="flex items-center space-x-4 flex-1">
                    <label class="flex items-center">
                      <input 
                        v-model="form.opening_hours[key].closed"
                        type="checkbox"
                        class="mr-2"
                      />
                      <span class="text-sm">Fermé</span>
                    </label>
                    <template v-if="!form.opening_hours[key].closed">
                      <UiInput
                        v-model="form.opening_hours[key].open"
                        type="time"
                        class="w-32"
                      />
                      <span class="text-sm text-muted-foreground">à</span>
                      <UiInput
                        v-model="form.opening_hours[key].close"
                        type="time"
                        class="w-32"
                      />
                    </template>
                  </div>
                </div>
              </div>
            </UiCardContent>
          </UiCard>

          <!-- Business Settings -->
          <UiCard>
            <UiCardHeader>
              <UiCardTitle>Paramètres d'activité</UiCardTitle>
              <p class="text-sm text-muted-foreground">
                Configuration initiale de votre centre
              </p>
            </UiCardHeader>
            <UiCardContent class="space-y-6">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label class="block text-sm font-medium mb-2">
                    Réservation à l'avance (jours)
                  </label>
                  <UiInput
                    v-model="form.booking_advance_days"
                    type="number"
                    min="1"
                    max="365"
                    placeholder="30"
                  />
                  <p class="text-xs text-muted-foreground mt-1">
                    Nombre de jours maximum à l'avance pour réserver
                  </p>
                </div>
                
                <div>
                  <label class="block text-sm font-medium mb-2">Numéro SIRET</label>
                  <UiInput
                    v-model="form.registration_number"
                    placeholder="12345678901234"
                  />
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium mb-2">
                  Politique d'annulation
                </label>
                <textarea 
                  v-model="form.cancellation_policy"
                  class="flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                  placeholder="Annulation gratuite jusqu'à 24h avant le créneau réservé..."
                ></textarea>
              </div>

              <div class="space-y-4">
                <div class="flex items-center justify-between">
                  <div>
                    <div class="font-medium">Centre actif</div>
                    <div class="text-sm text-muted-foreground">
                      Le centre sera visible et pourra recevoir des réservations
                    </div>
                  </div>
                  <label class="relative inline-flex items-center cursor-pointer">
                    <input v-model="form.is_active" type="checkbox" class="sr-only peer" />
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
                    <input v-model="form.accepts_online_booking" type="checkbox" class="sr-only peer" />
                    <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                  </label>
                </div>
              </div>
            </UiCardContent>
          </UiCard>

          <!-- Actions -->
          <div class="flex space-x-4">
            <UiButton type="button" variant="outline" @click="navigateTo('/dashboard/manager')" class="flex-1">
              Annuler
            </UiButton>
            <UiButton type="submit" :disabled="creating" class="flex-1">
              <Loader2 v-if="creating" class="mr-2 h-4 w-4 animate-spin" />
              <Building2 v-else class="mr-2 h-4 w-4" />
              {{ creating ? 'Création...' : 'Créer le centre' }}
            </UiButton>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { 
  ArrowLeft, Building2, MapPin, Loader2
} from 'lucide-vue-next'

// Middleware to protect the route
definePageMeta({
  middleware: 'auth'
})

// SEO
useHead({
  title: 'Créer un centre - Dashboard Gérant - PadelSpot',
  meta: [
    { name: 'robots', content: 'noindex' },
  ],
})

// Auth
const user = useSupabaseUser()
const supabase = useSupabaseClient()

// Reactive data
const creating = ref(false)

const form = reactive({
  name: '',
  description: '',
  email: '',
  phone: '',
  website: '',
  address_line1: '',
  address_line2: '',
  city: '',
  postal_code: '',
  country: 'France',
  opening_hours: {
    monday: { open: '08:00', close: '22:00', closed: false },
    tuesday: { open: '08:00', close: '22:00', closed: false },
    wednesday: { open: '08:00', close: '22:00', closed: false },
    thursday: { open: '08:00', close: '22:00', closed: false },
    friday: { open: '08:00', close: '22:00', closed: false },
    saturday: { open: '08:00', close: '22:00', closed: false },
    sunday: { open: '09:00', close: '21:00', closed: false }
  },
  booking_advance_days: 30,
  registration_number: '',
  cancellation_policy: 'Annulation gratuite jusqu\'à 24h avant le créneau réservé. Au-delà, 50% du montant sera retenu.',
  is_active: true,
  accepts_online_booking: true
})

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
const generateSlug = (name: string) => {
  return name
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
}

const createCenter = async () => {
  if (!form.name || !form.address_line1 || !form.city || !form.postal_code) {
    alert('Veuillez remplir tous les champs obligatoires')
    return
  }

  creating.value = true

  try {
    // Generate slug
    const slug = generateSlug(form.name)
    
    // Create center
    const { data, error } = await supabase
      .from('centers')
      .insert({
        name: form.name,
        slug,
        description: form.description || null,
        email: form.email || null,
        phone: form.phone || null,
        website: form.website || null,
        address_line1: form.address_line1,
        address_line2: form.address_line2 || null,
        city: form.city,
        postal_code: form.postal_code,
        country: form.country,
        opening_hours: form.opening_hours,
        manager_user_id: user.value?.id,
        registration_number: form.registration_number || null,
        booking_advance_days: parseInt(form.booking_advance_days.toString()) || 30,
        cancellation_policy: form.cancellation_policy || null,
        is_active: form.is_active,
        accepts_online_booking: form.accepts_online_booking
      })
      .select()
      .single()

    if (error) throw error

    // Navigate to center settings page
    navigateTo(`/dashboard/centers/${data.id}`)

  } catch (error: any) {
    console.error('Error creating center:', error)
    
    // Handle specific errors
    if (error.code === '23505' && error.constraint === 'centers_slug_key') {
      alert('Un centre avec ce nom existe déjà. Veuillez choisir un autre nom.')
    } else {
      alert('Erreur lors de la création du centre. Veuillez réessayer.')
    }
  } finally {
    creating.value = false
  }
}
</script>