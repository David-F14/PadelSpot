<template>
  <div class="min-h-screen bg-background flex items-center justify-center">
    <div class="text-center">
      <Loader2 class="h-8 w-8 animate-spin mx-auto text-primary mb-4" />
      <p class="text-muted-foreground">Redirection vers votre dashboard...</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Loader2 } from 'lucide-vue-next'

// Middleware to protect the route
definePageMeta({
  middleware: 'auth'
})

// SEO
useHead({
  title: 'Dashboard - PadelSpot',
  meta: [
    { name: 'robots', content: 'noindex' },
  ],
})

// User status
const { isManager, isPlayer, loading } = useUser()

// Watch for user status changes and redirect accordingly
watch([isManager, isPlayer, loading], ([manager, player, isLoading]) => {
  // Wait for loading to complete
  if (isLoading) return

  if (manager) {
    // User is a manager, redirect to manager dashboard
    navigateTo('/dashboard/manager')
  } else if (player) {
    // User is only a player, redirect to player dashboard
    navigateTo('/dashboard/player')
  } else {
    // User has no role yet, redirect to home
    navigateTo('/')
  }
}, { immediate: true })

// Also handle initial load
onMounted(() => {
  // Small delay to ensure everything is loaded
  setTimeout(() => {
    if (!loading.value) {
      if (isManager.value) {
        navigateTo('/dashboard/manager')
      } else if (isPlayer.value) {
        navigateTo('/dashboard/player')
      } else {
        navigateTo('/')
      }
    }
  }, 100)
})
</script>