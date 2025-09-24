<template>
  <div>

    <!-- Hero Section -->
    <section class="py-16">
      <div class="container mx-auto px-4 text-center">
        <h2 class="text-4xl md:text-6xl font-bold text-foreground mb-6">
          Réservez votre terrain de <span class="text-primary">padel</span> en 2 clics
        </h2>
        <p class="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
          Trouvez et réservez facilement les meilleurs terrains de padel près de chez vous. 
          Simple, rapide et sécurisé.
        </p>
        

        <!-- Quick Stats -->
        <div class="grid grid-cols-3 gap-4 max-w-md mx-auto text-center">
          <div>
            <div class="text-2xl font-bold text-primary">50+</div>
            <div class="text-sm text-muted-foreground">Centres</div>
          </div>
          <div>
            <div class="text-2xl font-bold text-primary">200+</div>
            <div class="text-sm text-muted-foreground">Terrains</div>
          </div>
          <div>
            <div class="text-2xl font-bold text-primary">1K+</div>
            <div class="text-sm text-muted-foreground">Réservations</div>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section class="py-16 bg-muted/50">
      <div class="container mx-auto px-4">
        <h3 class="text-3xl font-bold text-center mb-12 text-foreground">
          Pourquoi choisir PadelSpot ?
        </h3>
        
        <div class="grid md:grid-cols-3 gap-8">
          <UiCard class="text-center p-6">
            <div class="h-12 w-12 bg-primary/10 rounded-lg flex items-center justify-center mx-auto mb-4">
              <Clock class="h-6 w-6 text-primary" />
            </div>
            <h4 class="text-xl font-semibold mb-2">Réservation rapide</h4>
            <p class="text-muted-foreground">
              Réservez en moins de 2 minutes avec notre interface intuitive
            </p>
          </UiCard>

          <UiCard class="text-center p-6">
            <div class="h-12 w-12 bg-primary/10 rounded-lg flex items-center justify-center mx-auto mb-4">
              <MapPin class="h-6 w-6 text-primary" />
            </div>
            <h4 class="text-xl font-semibold mb-2">Géolocalisation</h4>
            <p class="text-muted-foreground">
              Trouvez les terrains les plus proches de votre position
            </p>
          </UiCard>

          <UiCard class="text-center p-6">
            <div class="h-12 w-12 bg-primary/10 rounded-lg flex items-center justify-center mx-auto mb-4">
              <CreditCard class="h-6 w-6 text-primary" />
            </div>
            <h4 class="text-xl font-semibold mb-2">Paiement sécurisé</h4>
            <p class="text-muted-foreground">
              Transactions 100% sécurisées avec Stripe
            </p>
          </UiCard>
        </div>
      </div>
    </section>

    <!-- Popular Centers Section -->
    <section class="py-16">
      <div class="container mx-auto px-4">
        <h3 class="text-3xl font-bold text-center mb-12 text-foreground">
          Centres populaires
        </h3>
        
        <div v-if="loading" class="text-center">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
        </div>
        
        <div v-else class="grid md:grid-cols-3 gap-6">
          <UiCard 
            v-for="center in popularCenters" 
            :key="center.id" 
            class="overflow-hidden hover:shadow-lg transition-shadow cursor-pointer"
            @click="navigateTo(`/centers/${center.id}`)"
          >
            <div class="h-48 bg-muted relative">
              <img 
                v-if="center.cover_image_url"
                :src="center.cover_image_url"
                :alt="center.name"
                class="w-full h-full object-cover"
              />
              <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
              <div class="absolute bottom-4 left-4 text-white">
                <h4 class="text-lg font-semibold">{{ center.name }}</h4>
                <p class="text-sm opacity-90">{{ center.city }}</p>
              </div>
            </div>
            <UiCardContent>
              <div class="flex justify-between items-center mt-4">
                <div class="flex items-center space-x-1">
                  <Star class="h-4 w-4 text-yellow-400 fill-current" />
                  <span class="text-sm font-medium">{{ center.average_rating || 'N/A' }}</span>
                  <span class="text-sm text-muted-foreground">({{ center.total_reviews || 0 }})</span>
                </div>
                <div class="text-right">
                  <div class="text-sm text-muted-foreground">À partir de</div>
                  <div class="text-lg font-bold text-primary">25€/h</div>
                </div>
              </div>
            </UiCardContent>
          </UiCard>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="border-t border-border py-8">
      <div class="container mx-auto px-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-2">
            <div class="h-6 w-6 bg-primary rounded flex items-center justify-center">
              <span class="text-primary-foreground font-bold text-sm">P</span>
            </div>
            <span class="font-medium">PadelSpot</span>
          </div>
          <p class="text-sm text-muted-foreground">
            © 2024 PadelSpot. Tous droits réservés.
          </p>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Clock, CreditCard, Star, LayoutDashboard, Calendar, MapPin } from 'lucide-vue-next'

// Auth
const user = useSupabaseUser()
const supabase = useSupabaseClient()

// User status
const { isManager, isPlayer } = useUser()

// SEO
useHead({
  title: 'PadelSpot - Réservez votre terrain de padel en 2 clics',
  meta: [
    { name: 'description', content: 'Trouvez et réservez facilement les meilleurs terrains de padel près de chez vous. Simple, rapide et sécurisé.' },
    { property: 'og:title', content: 'PadelSpot - Réservation de terrains de padel' },
    { property: 'og:description', content: 'La plateforme de réservation de terrains de padel la plus simple et rapide.' },
  ],
})

// Reactive data
const popularCenters = ref<any[]>([])
const loading = ref(false)

// Fetch popular centers
const fetchPopularCenters = async () => {
  loading.value = true
  
  try {
    const { data, error } = await supabase
      .from('centers')
      .select('id, name, city, cover_image_url, average_rating, total_reviews')
      .eq('is_active', true)
      .eq('is_verified', true)
      .order('average_rating', { ascending: false })
      .limit(6)
    
    if (error) throw error
    
    popularCenters.value = data || []
  } catch (error) {
    console.error('Error fetching popular centers:', error)
    popularCenters.value = []
  } finally {
    loading.value = false
  }
}



// Initialize
onMounted(() => {
  fetchPopularCenters()
})
</script>