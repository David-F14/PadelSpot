<template>
  <div class="min-h-screen bg-background">
    <div class="container mx-auto px-4 py-8">
      <div class="text-center space-y-6">
        <h1 class="text-4xl font-bold text-foreground">
          PadelSpot
        </h1>
        
        <p class="text-xl text-muted-foreground max-w-2xl mx-auto">
          Réservez vos créneaux de padel en quelques clics. 
          Trouvez les meilleurs centres près de chez vous.
        </p>

        <div class="flex flex-col sm:flex-row gap-4 justify-center items-center mt-8">
          <NuxtLink
            to="/centers"
            class="inline-flex items-center justify-center rounded-md bg-primary px-8 py-3 text-sm font-medium text-primary-foreground hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 transition-colors"
          >
            Voir les centres
          </NuxtLink>
          
          <NuxtLink
            to="/auth/login"
            class="inline-flex items-center justify-center rounded-md border border-input bg-background px-8 py-3 text-sm font-medium hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 transition-colors"
          >
            Se connecter
          </NuxtLink>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-12 text-left">
          <div class="p-6 border rounded-lg bg-card">
            <h3 class="text-lg font-semibold mb-2">Recherche simple</h3>
            <p class="text-muted-foreground">
              Trouvez les centres de padel les plus proches de vous grâce à la géolocalisation.
            </p>
          </div>
          
          <div class="p-6 border rounded-lg bg-card">
            <h3 class="text-lg font-semibold mb-2">Réservation rapide</h3>
            <p class="text-muted-foreground">
              Réservez votre terrain en moins de 3 clics avec notre interface intuitive.
            </p>
          </div>
          
          <div class="p-6 border rounded-lg bg-card">
            <h3 class="text-lg font-semibold mb-2">Paiement sécurisé</h3>
            <p class="text-muted-foreground">
              Payez en toute sécurité avec notre intégration Stripe complète.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
useHead({
  title: 'PadelSpot - Réservation de terrains de padel',
  meta: [
    { name: 'description', content: 'Réservez vos créneaux de padel en quelques clics. Trouvez les meilleurs centres près de chez vous.' }
  ]
})
</script>