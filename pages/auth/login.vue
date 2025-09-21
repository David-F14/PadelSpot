<template>
  <div class="flex w-full max-w-6xl">
    <!-- Left Side - Login Form -->
    <div class="flex-1 flex items-center justify-center px-4 sm:px-6 lg:px-8">
      <div class="max-w-md w-full space-y-8">
        <!-- Header -->
        <div class="text-center">
          <div class="flex justify-center mb-4">
            <div class="h-12 w-12 bg-primary rounded-lg flex items-center justify-center">
              <span class="text-primary-foreground font-bold text-2xl">P</span>
            </div>
          </div>
          <h2 class="text-3xl font-bold text-foreground">
            Connexion
          </h2>
          <p class="mt-2 text-muted-foreground">
            Connectez-vous à votre compte PadelSpot
          </p>
        </div>

        <!-- Login Form -->
        <form @submit.prevent="handleLogin" class="space-y-6">
          <div class="space-y-4">
            <div>
              <label for="email" class="block text-sm font-medium text-foreground mb-2">
                Email
              </label>
              <UiInput
                id="email"
                v-model="email"
                type="email"
                required
                placeholder="votre-email@exemple.com"
                :class="{ 'border-destructive': emailError }"
              />
              <p v-if="emailError" class="text-sm text-destructive mt-1">
                {{ emailError }}
              </p>
            </div>

            <div>
              <label for="password" class="block text-sm font-medium text-foreground mb-2">
                Mot de passe
              </label>
              <div class="relative">
                <UiInput
                  id="password"
                  v-model="password"
                  :type="showPassword ? 'text' : 'password'"
                  required
                  placeholder="Votre mot de passe"
                  :class="{ 'border-destructive': passwordError }"
                />
                <button
                  type="button"
                  @click="showPassword = !showPassword"
                  class="absolute right-3 top-1/2 transform -translate-y-1/2 text-muted-foreground hover:text-foreground"
                >
                  <Eye v-if="showPassword" class="h-5 w-5" />
                  <EyeOff v-else class="h-5 w-5" />
                </button>
              </div>
              <p v-if="passwordError" class="text-sm text-destructive mt-1">
                {{ passwordError }}
              </p>
            </div>
          </div>

          <!-- Remember Me & Forgot Password -->
          <div class="flex items-center justify-between">
            <div class="flex items-center">
              <input
                id="remember-me"
                v-model="rememberMe"
                type="checkbox"
                class="h-4 w-4 text-primary border-input rounded focus:ring-primary"
              />
              <label for="remember-me" class="ml-2 text-sm text-muted-foreground">
                Se souvenir de moi
              </label>
            </div>
            <NuxtLink
              to="/auth/forgot-password"
              class="text-sm text-primary hover:text-primary/80"
            >
              Mot de passe oublié ?
            </NuxtLink>
          </div>

          <!-- Submit Button -->
          <UiButton
            type="submit"
            class="w-full"
            :disabled="loading"
          >
            <Loader2 v-if="loading" class="mr-2 h-4 w-4 animate-spin" />
            Se connecter
          </UiButton>

          <!-- Error Message -->
          <div v-if="errorMessage" class="text-center">
            <p class="text-sm text-destructive">
              {{ errorMessage }}
            </p>
          </div>

          <!-- Divider -->
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-border"></div>
            </div>
            <div class="relative flex justify-center text-xs uppercase">
              <span class="bg-background px-2 text-muted-foreground">Ou continuer avec</span>
            </div>
          </div>

          <!-- Social Login -->
          <div class="grid grid-cols-2 gap-3">
            <UiButton
              type="button"
              variant="outline"
              @click="handleGoogleLogin"
              :disabled="loading"
            >
              <svg class="mr-2 h-4 w-4" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
              </svg>
              Google
            </UiButton>
            
            <UiButton
              type="button"
              variant="outline"
              @click="handleFacebookLogin"
              :disabled="loading"
            >
              <svg class="mr-2 h-4 w-4" fill="#1877F2" viewBox="0 0 24 24">
                <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
              </svg>
              Facebook
            </UiButton>
          </div>
        </form>

        <!-- Sign Up Link -->
        <div class="text-center">
          <p class="text-sm text-muted-foreground">
            Vous n'avez pas encore de compte ?
            <NuxtLink
              to="/auth/register"
              class="font-medium text-primary hover:text-primary/80"
            >
              Créer un compte
            </NuxtLink>
          </p>
        </div>
        </div>
    </div>

    <!-- Right Side - Hero Image -->
    <div class="hidden lg:flex lg:flex-1 bg-muted relative overflow-hidden">
      <div class="absolute inset-0 bg-gradient-to-br from-primary/20 to-primary/5"></div>
      <div class="absolute inset-0 flex flex-col justify-center items-center text-center p-8">
        <div class="max-w-md space-y-6">
          <div class="h-16 w-16 bg-primary rounded-full flex items-center justify-center mx-auto">
            <span class="text-primary-foreground font-bold text-3xl">P</span>
          </div>
          <h3 class="text-2xl font-bold text-foreground">
            Rejoignez PadelSpot
          </h3>
          <p class="text-muted-foreground">
            La plateforme de référence pour réserver vos terrains de padel en France.
            Plus de 50 centres partenaires vous attendent !
          </p>
          <div class="grid grid-cols-3 gap-4 text-center">
            <div>
              <div class="text-xl font-bold text-primary">50+</div>
              <div class="text-xs text-muted-foreground">Centres</div>
            </div>
            <div>
              <div class="text-xl font-bold text-primary">200+</div>
              <div class="text-xs text-muted-foreground">Terrains</div>
            </div>
            <div>
              <div class="text-xl font-bold text-primary">1K+</div>
              <div class="text-xs text-muted-foreground">Joueurs</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Define layout
definePageMeta({
  layout: 'auth',
  auth: false // This page is for non-authenticated users
})
import { ref, watch } from 'vue'
import { Eye, EyeOff, Loader2 } from 'lucide-vue-next'

// SEO
useHead({
  title: 'Connexion - PadelSpot',
  meta: [
    { name: 'description', content: 'Connectez-vous à votre compte PadelSpot pour réserver vos terrains de padel.' },
    { name: 'robots', content: 'noindex' },
  ],
})

// Reactive data
const email = ref('')
const password = ref('')
const rememberMe = ref(false)
const showPassword = ref(false)
const loading = ref(false)
const errorMessage = ref('')
const emailError = ref('')
const passwordError = ref('')

// Get Supabase client
const supabase = useSupabaseClient()
const user = useSupabaseUser()

// Redirect if already logged in (but not on first load to avoid loops)
watch(user, (newUser, oldUser) => {
  if (newUser && !oldUser) {
    navigateTo('/')
  }
})

// Methods
const validateForm = () => {
  emailError.value = ''
  passwordError.value = ''
  
  if (!email.value) {
    emailError.value = 'L\'email est requis'
    return false
  }
  
  if (!email.value.includes('@')) {
    emailError.value = 'Format d\'email invalide'
    return false
  }
  
  if (!password.value) {
    passwordError.value = 'Le mot de passe est requis'
    return false
  }
  
  if (password.value.length < 6) {
    passwordError.value = 'Le mot de passe doit contenir au moins 6 caractères'
    return false
  }
  
  return true
}

const handleLogin = async () => {
  if (!validateForm()) return
  
  loading.value = true
  errorMessage.value = ''
  
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })
    
    if (error) {
      if (error.message.includes('Invalid login credentials')) {
        errorMessage.value = 'Email ou mot de passe incorrect'
      } else {
        errorMessage.value = error.message
      }
    } else {
      // Login successful, redirect immediately
      await navigateTo('/')
    }
  } catch (error) {
    errorMessage.value = 'Une erreur inattendue s\'est produite'
    console.error('Login error:', error)
  } finally {
    loading.value = false
  }
}

const handleGoogleLogin = async () => {
  loading.value = true
  try {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/`
      }
    })
    
    if (error) {
      errorMessage.value = error.message
    }
  } catch (error) {
    errorMessage.value = 'Erreur lors de la connexion avec Google'
    console.error('Google login error:', error)
  } finally {
    loading.value = false
  }
}

const handleFacebookLogin = async () => {
  loading.value = true
  try {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'facebook',
      options: {
        redirectTo: `${window.location.origin}/`
      }
    })
    
    if (error) {
      errorMessage.value = error.message
    }
  } catch (error) {
    errorMessage.value = 'Erreur lors de la connexion avec Facebook'
    console.error('Facebook login error:', error)
  } finally {
    loading.value = false
  }
}
</script>