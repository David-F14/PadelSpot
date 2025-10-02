<template>
  <div class="min-h-screen bg-background">

    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center py-20">
      <Loader2 class="h-8 w-8 animate-spin text-primary" />
      <span class="ml-2 text-muted-foreground">Chargement des informations...</span>
    </div>

    <!-- Authentication Required -->
    <div v-else-if="!user" class="text-center py-20">
      <Lock class="h-12 w-12 text-muted-foreground mx-auto mb-4" />
      <h2 class="text-2xl font-semibold text-foreground mb-2">Connexion requise</h2>
      <p class="text-muted-foreground mb-6">
        Vous devez être connecté pour effectuer une réservation.
      </p>
      <div class="space-x-4">
        <UiButton @click="navigateTo('/auth/login')">
          Se connecter
        </UiButton>
        <UiButton variant="outline" @click="navigateTo('/auth/register')">
          Créer un compte
        </UiButton>
      </div>
    </div>

    <!-- Booking Form -->
    <div v-else class="container mx-auto px-4 py-8">
      <div class="max-w-4xl mx-auto">
        <!-- Progress Steps -->
        <div class="mb-8">
          <div class="flex items-center justify-center space-x-4">
            <div class="flex items-center">
              <div class="w-8 h-8 bg-primary text-primary-foreground rounded-full flex items-center justify-center text-sm font-medium">
                1
              </div>
              <span class="ml-2 text-sm font-medium">Détails</span>
            </div>
            <div class="w-12 h-px bg-muted"></div>
            <div class="flex items-center">
              <div :class="[
                'w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium',
                step >= 2 ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground'
              ]">
                2
              </div>
              <span class="ml-2 text-sm font-medium">Paiement</span>
            </div>
            <div class="w-12 h-px bg-muted"></div>
            <div class="flex items-center">
              <div :class="[
                'w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium',
                step >= 3 ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground'
              ]">
                3
              </div>
              <span class="ml-2 text-sm font-medium">Confirmation</span>
            </div>
          </div>
        </div>

        <div class="grid lg:grid-cols-3 gap-8">
          <!-- Left Column - Form -->
          <div class="lg:col-span-2">
            <!-- Step 1: Booking Details -->
            <UiCard v-if="step === 1">
              <UiCardHeader>
                <UiCardTitle>Détails de la réservation</UiCardTitle>
              </UiCardHeader>
              <UiCardContent class="space-y-6">
                <!-- Slot Summary -->
                <div class="bg-muted/50 rounded-lg p-4">
                  <h3 class="font-medium mb-2">Créneau sélectionné</h3>
                  <div class="space-y-1 text-sm">
                    <div><strong>Centre:</strong> {{ center?.name }}</div>
                    <div><strong>Terrain:</strong> {{ court?.court_name }}</div>
                    <div><strong>Date:</strong> {{ formatDate(bookingDetails.date) }}</div>
                    <div><strong>Heure:</strong> {{ bookingDetails.time.slice(0, 5) }} - {{ getEndTime(bookingDetails.time) }}</div>
                    <div><strong>Prix:</strong> {{ bookingDetails.price }}€</div>
                  </div>
                </div>

                <!-- Player Count -->
                <div>
                  <label class="block text-sm font-medium mb-2">Nombre de joueurs</label>
                  <select 
                    v-model="bookingDetails.playerCount"
                    class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  >
                    <option value="2">2 joueurs</option>
                    <option value="3">3 joueurs</option>
                    <option value="4">4 joueurs</option>
                  </select>
                </div>


                <!-- Special Requests -->
                <div>
                  <label class="block text-sm font-medium mb-2">Demandes particulières (optionnel)</label>
                  <textarea 
                    v-model="bookingDetails.specialRequests"
                    class="flex min-h-[80px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                    placeholder="Matériel spécifique, préférences..."
                  ></textarea>
                </div>

                <!-- Equipment Rental -->
                <div>
                  <label class="block text-sm font-medium mb-2">Location de matériel</label>
                  <div class="space-y-3">
                    <div class="flex items-center justify-between p-3 border rounded">
                      <div class="flex items-center">
                        <input 
                          id="rackets"
                          v-model="equipment.rackets.selected"
                          type="checkbox" 
                          class="h-4 w-4"
                        />
                        <label for="rackets" class="ml-2">Raquettes de padel</label>
                      </div>
                      <div class="flex items-center space-x-2">
                        <select 
                          v-model="equipment.rackets.quantity"
                          :disabled="!equipment.rackets.selected"
                          class="text-sm rounded border px-2 py-1"
                        >
                          <option v-for="n in 4" :key="n" :value="n">{{ n }}</option>
                        </select>
                        <span class="text-sm text-muted-foreground">× 5€</span>
                      </div>
                    </div>
                    
                    <div class="flex items-center justify-between p-3 border rounded">
                      <div class="flex items-center">
                        <input 
                          id="balls"
                          v-model="equipment.balls.selected"
                          type="checkbox" 
                          class="h-4 w-4"
                        />
                        <label for="balls" class="ml-2">Balles de padel</label>
                      </div>
                      <div class="flex items-center space-x-2">
                        <select 
                          v-model="equipment.balls.quantity"
                          :disabled="!equipment.balls.selected"
                          class="text-sm rounded border px-2 py-1"
                        >
                          <option v-for="n in 3" :key="n" :value="n">{{ n }}</option>
                        </select>
                        <span class="text-sm text-muted-foreground">× 3€</span>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Terms -->
                <div class="flex items-start space-x-2">
                  <input 
                    id="terms"
                    v-model="acceptTerms"
                    type="checkbox" 
                    class="h-4 w-4 mt-0.5"
                    required
                  />
                  <label for="terms" class="text-sm text-muted-foreground">
                    J'accepte les 
                    <NuxtLink to="/legal/terms" class="text-primary hover:underline">conditions d'utilisation</NuxtLink>
                    et la politique d'annulation
                  </label>
                </div>

                <UiButton 
                  @click="step = 2" 
                  class="w-full"
                  :disabled="!canProceedToPayment"
                >
                  Continuer vers le paiement
                  <ArrowRight class="ml-2 h-4 w-4" />
                </UiButton>
              </UiCardContent>
            </UiCard>

            <!-- Step 2: Payment -->
            <UiCard v-if="step === 2">
              <UiCardHeader>
                <UiCardTitle>Paiement</UiCardTitle>
              </UiCardHeader>
              <UiCardContent class="space-y-6">
                <!-- Payment Method -->
                <div>
                  <label class="block text-sm font-medium mb-4">Mode de paiement</label>
                  <div class="space-y-3">
                    <div class="flex items-center space-x-3 p-4 border rounded-lg cursor-pointer hover:bg-muted/50" @click="paymentMethod = 'card'">
                      <input type="radio" v-model="paymentMethod" value="card" class="h-4 w-4" />
                      <CreditCard class="h-5 w-5 text-muted-foreground" />
                      <span>Carte bancaire</span>
                    </div>
                    <div class="flex items-center space-x-3 p-4 border rounded-lg cursor-pointer hover:bg-muted/50" @click="paymentMethod = 'paypal'">
                      <input type="radio" v-model="paymentMethod" value="paypal" class="h-4 w-4" />
                      <span class="text-lg font-semibold text-blue-600">PayPal</span>
                    </div>
                  </div>
                </div>

                <!-- Card Form (if card selected) -->
                <div v-if="paymentMethod === 'card'" class="space-y-4">
                  <div>
                    <label class="block text-sm font-medium mb-2">Numéro de carte</label>
                    <UiInput 
                      v-model="cardInfo.number"
                      placeholder="1234 5678 9012 3456"
                      maxlength="19"
                    />
                  </div>
                  
                  <div class="grid grid-cols-2 gap-4">
                    <div>
                      <label class="block text-sm font-medium mb-2">Date d'expiration</label>
                      <UiInput 
                        v-model="cardInfo.expiry"
                        placeholder="MM/YY"
                        maxlength="5"
                      />
                    </div>
                    <div>
                      <label class="block text-sm font-medium mb-2">CVV</label>
                      <UiInput 
                        v-model="cardInfo.cvv"
                        placeholder="123"
                        maxlength="4"
                      />
                    </div>
                  </div>
                  
                  <div>
                    <label class="block text-sm font-medium mb-2">Nom sur la carte</label>
                    <UiInput 
                      v-model="cardInfo.name"
                      placeholder="Jean Dupont"
                    />
                  </div>
                </div>

                <div class="flex space-x-4">
                  <UiButton variant="outline" @click="step = 1" class="flex-1">
                    <ArrowLeft class="mr-2 h-4 w-4" />
                    Retour
                  </UiButton>
                  <UiButton 
                    @click="processPayment" 
                    class="flex-1"
                    :disabled="processing"
                  >
                    <Loader2 v-if="processing" class="mr-2 h-4 w-4 animate-spin" />
                    {{ processing ? 'Traitement...' : `Payer ${totalPrice}€` }}
                  </UiButton>
                </div>
              </UiCardContent>
            </UiCard>

            <!-- Step 3: Confirmation -->
            <UiCard v-if="step === 3">
              <UiCardContent class="text-center py-8">
                <div class="mb-4">
                  <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                    <Check class="h-8 w-8 text-green-600" />
                  </div>
                  <h2 class="text-2xl font-bold text-foreground mb-2">Réservation confirmée !</h2>
                  <p class="text-muted-foreground mb-4">
                    Votre réservation a été confirmée avec succès. Vous recevrez un email de confirmation.
                  </p>
                </div>

                <div class="bg-muted/50 rounded-lg p-4 mb-6 text-left">
                  <h3 class="font-medium mb-2">Détails de votre réservation</h3>
                  <div class="space-y-1 text-sm">
                    <div><strong>Numéro:</strong> #{{ bookingId }}</div>
                    <div><strong>Centre:</strong> {{ center?.name }}</div>
                    <div><strong>Date:</strong> {{ formatDate(bookingDetails.date) }}</div>
                    <div><strong>Heure:</strong> {{ bookingDetails.time.slice(0, 5) }} - {{ getEndTime(bookingDetails.time) }}</div>
                    <div><strong>Total payé:</strong> {{ totalPrice }}€</div>
                  </div>
                </div>

                <div class="space-y-4">
                  <UiButton @click="navigateTo('/dashboard')" class="w-full">
                    Voir mes réservations
                  </UiButton>
                  <UiButton variant="outline" @click="navigateTo('/centers')" class="w-full">
                    Nouvelle réservation
                  </UiButton>
                </div>
              </UiCardContent>
            </UiCard>
          </div>

          <!-- Right Column - Summary -->
          <div class="lg:col-span-1">
            <div class="sticky top-8">
              <UiCard>
                <UiCardHeader>
                  <UiCardTitle>Récapitulatif</UiCardTitle>
                </UiCardHeader>
                <UiCardContent>
                  <div class="space-y-3">
                    <div class="flex justify-between">
                      <span>Terrain (1h30)</span>
                      <span>{{ bookingDetails.price }}€</span>
                    </div>
                    
                    <div v-if="equipmentTotal > 0" class="flex justify-between">
                      <span>Location matériel</span>
                      <span>{{ equipmentTotal }}€</span>
                    </div>
                    
                    <div class="flex justify-between text-sm text-muted-foreground">
                      <span>TVA (20%)</span>
                      <span>{{ Math.round(totalPrice * 0.2 * 100) / 100 }}€</span>
                    </div>
                    
                    <hr />
                    
                    <div class="flex justify-between font-semibold text-lg">
                      <span>Total</span>
                      <span>{{ totalPrice }}€</span>
                    </div>
                  </div>
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
import { ref, computed, onMounted } from 'vue'
import { 
  ArrowLeft, ArrowRight, Lock, Loader2, CreditCard, Check
} from 'lucide-vue-next'

// Page automatically protected by global auth middleware

// SEO
useHead({
  title: 'Réservation - PadelSpot',
  meta: [
    { name: 'description', content: 'Finalisez votre réservation de terrain de padel en toute sécurité.' },
    { name: 'robots', content: 'noindex' },
  ],
})

// Get query parameters
const route = useRoute()
const user = useSupabaseUser()
const supabase = useSupabaseClient()

// Reactive data
const loading = ref(true)
const processing = ref(false)
const step = ref(1)

const bookingDetails = ref({
  centerId: route.query.center as string,
  courtId: route.query.court as string,
  date: route.query.date as string,
  time: route.query.time as string,
  price: parseFloat(route.query.price as string) || 0,
  playerCount: '2',
  specialRequests: ''
})

const center = ref<any>(null)
const court = ref<any>(null)

const acceptTerms = ref(false)
const paymentMethod = ref('card')

const equipment = ref({
  rackets: { selected: false, quantity: 2 },
  balls: { selected: false, quantity: 1 }
})

const cardInfo = ref({
  number: '',
  expiry: '',
  cvv: '',
  name: ''
})

const bookingId = ref('')

// Computed
const canProceedToPayment = computed(() => {
  return acceptTerms.value
})

const equipmentTotal = computed(() => {
  let total = 0
  if (equipment.value.rackets.selected) {
    total += equipment.value.rackets.quantity * 5
  }
  if (equipment.value.balls.selected) {
    total += equipment.value.balls.quantity * 3
  }
  return total
})

const totalPrice = computed(() => {
  const subtotal = bookingDetails.value.price + equipmentTotal.value
  return Math.round(subtotal * 1.2 * 100) / 100 // Add 20% VAT
})

// Methods
const goBack = () => {
  if (step.value > 1) {
    step.value--
  } else {
    history.back()
  }
}

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString('fr-FR', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  })
}

const getEndTime = (startTime: string) => {
  const [hours, minutes] = startTime.split(':').map(Number)
  const endHour = hours + 1
  const endMinute = minutes + 30
  return `${endHour.toString().padStart(2, '0')}:${endMinute.toString().padStart(2, '0')}`
}

const fetchBookingInfo = async () => {
  loading.value = true
  
  try {
    // Fetch center info
    const { data: centerData } = await supabase
      .from('centers')
      .select('*')
      .eq('id', bookingDetails.value.centerId)
      .single()
    
    center.value = centerData
    
    // Fetch court info  
    const { data: courtData } = await supabase
      .from('courts')
      .select('*')
      .eq('id', bookingDetails.value.courtId)
      .single()
    
    court.value = courtData
    
  } catch (error) {
    console.error('Error fetching booking info:', error)
  } finally {
    loading.value = false
  }
}

const processPayment = async () => {
  processing.value = true
  
  try {
    // Create booking record
    const { data, error } = await supabase
      .from('bookings')
      .insert({
        user_id: user.value?.id,
        court_id: bookingDetails.value.courtId,
        center_id: bookingDetails.value.centerId,
        booking_date: bookingDetails.value.date,
        start_time: bookingDetails.value.time,
        end_time: getEndTime(bookingDetails.value.time) + ':00',
        player_count: parseInt(bookingDetails.value.playerCount),
        players: null,
        base_price: bookingDetails.value.price,
        total_price: totalPrice.value,
        special_requests: bookingDetails.value.specialRequests,
        equipment_rental: {
          rackets: equipment.value.rackets.selected ? equipment.value.rackets.quantity : 0,
          balls: equipment.value.balls.selected ? equipment.value.balls.quantity : 0
        },
        status: 'confirmed',
        payment_status: 'paid',
        payment_method: paymentMethod.value
      })
      .select()
      .single()
    
    if (error) throw error
    
    bookingId.value = data.id
    step.value = 3
    
  } catch (error) {
    console.error('Booking error:', error)
    // Handle error - show error message
  } finally {
    processing.value = false
  }
}

// Initialize
onMounted(() => {
  if (!route.query.center || !route.query.court) {
    navigateTo('/centers')
    return
  }
  
  fetchBookingInfo()
})
</script>