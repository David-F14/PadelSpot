<template>
  <div class="min-h-screen bg-background flex">
    <!-- Left Side - Register Form -->
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
            Créer un compte
          </h2>
          <p class="mt-2 text-muted-foreground">
            Rejoignez PadelSpot et réservez vos terrains facilement
          </p>
        </div>

        <!-- Register Form -->
        <form @submit.prevent="handleRegister" class="space-y-6">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label for="firstName" class="block text-sm font-medium text-foreground mb-2">
                Prénom
              </label>
              <UiInput
                id="firstName"
                v-model="firstName"
                type="text"
                required
                placeholder="Jean"
                :class="{ 'border-destructive': firstNameError }"
              />
              <p v-if="firstNameError" class="text-sm text-destructive mt-1">
                {{ firstNameError }}
              </p>
            </div>

            <div>
              <label for="lastName" class="block text-sm font-medium text-foreground mb-2">
                Nom
              </label>
              <UiInput
                id="lastName"
                v-model="lastName"
                type="text"
                required
                placeholder="Dupont"
                :class="{ 'border-destructive': lastNameError }"
              />
              <p v-if="lastNameError" class="text-sm text-destructive mt-1">
                {{ lastNameError }}
              </p>
            </div>
          </div>

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
            <label for="phone" class="block text-sm font-medium text-foreground mb-2">
              Téléphone (optionnel)
            </label>
            <UiInput
              id="phone"
              v-model="phone"
              type="tel"
              placeholder="+33 6 12 34 56 78"
            />
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
                placeholder="Minimum 6 caractères"
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

          <div>
            <label for="confirmPassword" class="block text-sm font-medium text-foreground mb-2">
              Confirmer le mot de passe
            </label>
            <div class="relative">
              <UiInput
                id="confirmPassword"
                v-model="confirmPassword"
                :type="showConfirmPassword ? 'text' : 'password'"
                required
                placeholder="Répétez votre mot de passe"
                :class="{ 'border-destructive': confirmPasswordError }"
              />
              <button
                type="button"
                @click="showConfirmPassword = !showConfirmPassword"
                class="absolute right-3 top-1/2 transform -translate-y-1/2 text-muted-foreground hover:text-foreground"
              >
                <Eye v-if="showConfirmPassword" class="h-5 w-5" />
                <EyeOff v-else class="h-5 w-5" />
              </button>
            </div>
            <p v-if="confirmPasswordError" class="text-sm text-destructive mt-1">
              {{ confirmPasswordError }}
            </p>
          </div>

          <!-- Skill Level -->
          <div>
            <label for="skillLevel" class="block text-sm font-medium text-foreground mb-2">
              Niveau de jeu
            </label>
            <select 
              id="skillLevel"
              v-model="skillLevel"
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
            >
              <option value="débutant">Débutant</option>
              <option value="intermédiaire">Intermédiaire</option>
              <option value="avancé">Avancé</option>
              <option value="expert">Expert</option>
            </select>
          </div>

          <!-- Terms and conditions -->
          <div class="flex items-center">
            <input
              id="acceptTerms"
              v-model="acceptTerms"
              type="checkbox"
              class="h-4 w-4 text-primary border-input rounded focus:ring-primary"
              required
            />
            <label for="acceptTerms" class="ml-2 text-sm text-muted-foreground">
              J'accepte les 
              <NuxtLink to="/legal/terms" class="text-primary hover:text-primary/80">
                conditions d'utilisation
              </NuxtLink>
              et la 
              <NuxtLink to="/legal/privacy" class="text-primary hover:text-primary/80">
                politique de confidentialité
              </NuxtLink>
            </label>
          </div>

          <!-- Submit Button -->
          <UiButton
            type="submit"
            class="w-full"
            :disabled="loading"
          >
            <Loader2 v-if="loading" class="mr-2 h-4 w-4 animate-spin" />
            Créer mon compte
          </UiButton>

          <!-- Error Message -->
          <div v-if="errorMessage" class="text-center">
            <p class="text-sm text-destructive">
              {{ errorMessage }}
            </p>
          </div>

          <!-- Success Message -->
          <div v-if="successMessage" class="text-center">
            <p class="text-sm text-green-600">
              {{ successMessage }}
            </p>
          </div>

          <!-- Divider -->
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-border"></div>
            </div>
            <div class="relative flex justify-center text-xs uppercase">
              <span class="bg-background px-2 text-muted-foreground">Ou s'inscrire avec</span>
            </div>
          </div>

          <!-- Social Register -->
          <div class="grid grid-cols-2 gap-3">
            <UiButton
              type="button"
              variant="outline"
              @click="handleGoogleRegister"
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
              @click="handleFacebookRegister"
              :disabled="loading"
            >
              <svg class="mr-2 h-4 w-4" fill="#1877F2" viewBox="0 0 24 24">
                <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
              </svg>
              Facebook
            </UiButton>
          </div>
        </form>

        <!-- Sign In Link -->
        <div class="text-center">
          <p class="text-sm text-muted-foreground">
            Vous avez déjà un compte ?
            <NuxtLink
              to="/auth/login"
              class="font-medium text-primary hover:text-primary/80"
            >
              Se connecter
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
            Bienvenue sur PadelSpot !
          </h3>
          <p class="text-muted-foreground">
            Créez votre compte et découvrez la plateforme de réservation de terrains 
            de padel la plus simple en France.
          </p>
          <div class="grid grid-cols-3 gap-4 text-center">
            <div>
              <div class="text-xl font-bold text-primary">2 min</div>
              <div class="text-xs text-muted-foreground">Inscription</div>
            </div>
            <div>
              <div class="text-xl font-bold text-primary">2 clics</div>
              <div class="text-xs text-muted-foreground">Réservation</div>
            </div>
            <div>
              <div class="text-xl font-bold text-primary">50+</div>
              <div class="text-xs text-muted-foreground">Centres</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Eye, EyeOff, Loader2 } from 'lucide-vue-next'

// Redirect authenticated users away from register
definePageMeta({
  auth: false
})

// SEO
useHead({
  title: 'Inscription - PadelSpot',
  meta: [
    { name: 'description', content: 'Créez votre compte PadelSpot et commencez à réserver vos terrains de padel en 2 clics.' },
    { name: 'robots', content: 'noindex' },
  ],
})

// Reactive data
const firstName = ref('')
const lastName = ref('')
const email = ref('')
const phone = ref('')
const password = ref('')
const confirmPassword = ref('')
const skillLevel = ref('débutant')
const acceptTerms = ref(false)

const showPassword = ref(false)
const showConfirmPassword = ref(false)
const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

// Validation errors
const firstNameError = ref('')
const lastNameError = ref('')
const emailError = ref('')
const passwordError = ref('')
const confirmPasswordError = ref('')

// Get Supabase client
const supabase = useSupabaseClient()

// Methods
const validateForm = () => {
  // Clear previous errors
  firstNameError.value = ''
  lastNameError.value = ''
  emailError.value = ''
  passwordError.value = ''
  confirmPasswordError.value = ''
  
  let isValid = true
  
  if (!firstName.value.trim()) {
    firstNameError.value = 'Le prénom est requis'
    isValid = false
  }
  
  if (!lastName.value.trim()) {
    lastNameError.value = 'Le nom est requis'
    isValid = false
  }
  
  if (!email.value) {
    emailError.value = 'L\'email est requis'
    isValid = false
  } else if (!email.value.includes('@')) {
    emailError.value = 'Format d\'email invalide'
    isValid = false
  }
  
  if (!password.value) {
    passwordError.value = 'Le mot de passe est requis'
    isValid = false
  } else if (password.value.length < 6) {
    passwordError.value = 'Le mot de passe doit contenir au moins 6 caractères'
    isValid = false
  }
  
  if (!confirmPassword.value) {
    confirmPasswordError.value = 'Veuillez confirmer votre mot de passe'
    isValid = false
  } else if (password.value !== confirmPassword.value) {
    confirmPasswordError.value = 'Les mots de passe ne correspondent pas'
    isValid = false
  }
  
  return isValid
}

const handleRegister = async () => {
  if (!validateForm()) return
  
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''
  
  try {
    const { data, error } = await supabase.auth.signUp({
      email: email.value,
      password: password.value,
      options: {
        data: {
          first_name: firstName.value.trim(),
          last_name: lastName.value.trim(),
          phone: phone.value.trim() || null,
          skill_level: skillLevel.value,
        }
      }
    })
    
    if (error) {
      if (error.message.includes('already registered')) {
        errorMessage.value = 'Cet email est déjà utilisé'
      } else {
        errorMessage.value = error.message
      }
    } else {
      // Registration successful
      successMessage.value = 'Compte créé avec succès ! Vérifiez votre email pour confirmer votre compte.'
      
      // Clear form
      firstName.value = ''
      lastName.value = ''
      email.value = ''
      phone.value = ''
      password.value = ''
      confirmPassword.value = ''
      acceptTerms.value = false
      
      // Redirect to login after a short delay
      setTimeout(() => {
        navigateTo('/auth/login?message=registration_success')
      }, 3000)
    }
  } catch (error) {
    errorMessage.value = 'Une erreur inattendue s\'est produite'
    console.error('Registration error:', error)
  } finally {
    loading.value = false
  }
}

const handleGoogleRegister = async () => {
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
    errorMessage.value = 'Erreur lors de l\'inscription avec Google'
    console.error('Google register error:', error)
  } finally {
    loading.value = false
  }
}

const handleFacebookRegister = async () => {
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
    errorMessage.value = 'Erreur lors de l\'inscription avec Facebook'
    console.error('Facebook register error:', error)
  } finally {
    loading.value = false
  }
}
</script>