<template>
  <UiDropdownMenu>
    <template #trigger>
      <UiDropdownMenuTrigger>
        <UiButton variant="outline" size="sm" class="flex items-center space-x-2">
          <User class="h-4 w-4" />
          <span class="hidden sm:inline">{{ user?.email?.split('@')[0] || 'Utilisateur' }}</span>
          <ChevronDown class="h-3 w-3" />
        </UiButton>
      </UiDropdownMenuTrigger>
    </template>

    <!-- User info section -->
    <div class="px-2 py-1.5 text-sm">
      <div class="font-medium">{{ user?.email?.split('@')[0] || 'Utilisateur' }}</div>
      <div class="text-xs text-muted-foreground">{{ user?.email }}</div>
    </div>

    <UiDropdownMenuSeparator />

    <!-- Navigation items based on user role -->
    <UiDropdownMenuItem v-if="isManager" @click="navigateTo('/dashboard')">
      <LayoutDashboard class="mr-2 h-4 w-4" />
      Dashboard Gérant
    </UiDropdownMenuItem>

    <UiDropdownMenuItem v-if="isPlayer && !isManager" @click="navigateTo('/dashboard/player')">
      <Calendar class="mr-2 h-4 w-4" />
      Mes réservations
    </UiDropdownMenuItem>

    <UiDropdownMenuItem @click="navigateTo('/')">
      <Home class="mr-2 h-4 w-4" />
      Accueil
    </UiDropdownMenuItem>

    <UiDropdownMenuSeparator />

    <!-- Account management -->
    <UiDropdownMenuItem @click="navigateTo('/profile')" disabled>
      <Settings class="mr-2 h-4 w-4" />
      Paramètres
    </UiDropdownMenuItem>

    <UiDropdownMenuItem @click="navigateTo('/about')">
      <Info class="mr-2 h-4 w-4" />
      À propos
    </UiDropdownMenuItem>

    <UiDropdownMenuSeparator />

    <!-- Logout -->
    <UiDropdownMenuItem @click="handleLogout" class="text-destructive focus:text-destructive">
      <LogOut class="mr-2 h-4 w-4" />
      Déconnexion
    </UiDropdownMenuItem>
  </UiDropdownMenu>
</template>

<script setup lang="ts">
import {
  User, ChevronDown, LayoutDashboard, Calendar, Home,
  Settings, Info, LogOut
} from 'lucide-vue-next'

// Auth
const user = useSupabaseUser()
const { signOut } = useAuth()

// User status
const { isManager, isPlayer } = useUser()

// Logout handler
const handleLogout = async () => {
  await signOut()
}
</script>