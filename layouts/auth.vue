<template>
  <div class="min-h-screen bg-background flex flex-col">
    <!-- Simple header for auth pages -->
    <header class="border-b border-border">
      <div class="container mx-auto px-4 py-4">
        <nav class="flex items-center justify-between">
          <NuxtLink to="/" class="flex items-center space-x-2">
            <div class="h-8 w-8 bg-primary rounded-md flex items-center justify-center">
              <span class="text-primary-foreground font-bold text-lg">P</span>
            </div>
            <h1 class="text-xl font-bold text-foreground">PadelSpot</h1>
          </NuxtLink>

          <UiButton variant="outline" @click="navigateTo('/')">
            <ArrowLeft class="mr-2 h-4 w-4" />
            Retour à l'accueil
          </UiButton>
        </nav>
      </div>
    </header>

    <!-- Page Content -->
    <div class="flex-1 flex items-center justify-center">
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft } from 'lucide-vue-next'
</script>