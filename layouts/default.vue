<template>
  <div class="min-h-screen bg-background">
    <!-- Header -->
    <header class="border-b border-border">
      <div class="container mx-auto px-4 py-4">
        <nav class="flex items-center justify-between">
          <div class="flex items-center space-x-2">
            <NuxtLink to="/" class="flex items-center space-x-2">
              <div class="h-8 w-8 bg-primary rounded-md flex items-center justify-center">
                <span class="text-primary-foreground font-bold text-lg">P</span>
              </div>
              <h1 class="text-xl font-bold text-foreground">PadelSpot</h1>
            </NuxtLink>
          </div>

          <div class="flex items-center space-x-4">
            <!-- Navigation based on auth status -->
            <template v-if="!user">
              <UiButton variant="outline" @click="navigateTo('/auth/login')">
                Connexion
              </UiButton>
              <UiButton @click="navigateTo('/auth/register')">
                S'inscrire
              </UiButton>
            </template>

            <template v-else>
              <!-- User menu dropdown -->
              <UserMenu />
            </template>
          </div>
        </nav>
      </div>
    </header>

    <!-- Page Content -->
    <slot />
  </div>
</template>

<script setup lang="ts">
// Auth
const user = useSupabaseUser()
</script>