<template>
  <div class="min-h-screen bg-background flex items-center justify-center p-4">
    <div class="w-full max-w-md space-y-6">
      <div class="text-center space-y-2">
        <h1 class="text-3xl font-bold text-foreground">
          Connexion
        </h1>
        <p class="text-muted-foreground">
          Connectez-vous à votre compte PadelSpot
        </p>
      </div>

      <div class="bg-card border rounded-lg p-6 shadow-sm">
        <form @submit.prevent="handleLogin" class="space-y-4">
          <div class="space-y-2">
            <label for="email" class="text-sm font-medium text-foreground">
              Email
            </label>
            <input
              id="email"
              v-model="email"
              type="email"
              required
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              placeholder="votre@email.com"
            />
          </div>

          <div class="space-y-2">
            <label for="password" class="text-sm font-medium text-foreground">
              Mot de passe
            </label>
            <input
              id="password"
              v-model="password"
              type="password"
              required
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              placeholder="••••••••"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="inline-flex items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 w-full"
          >
            <span v-if="loading" class="mr-2">
              <!-- Loading spinner placeholder -->
              ⏳
            </span>
            {{ loading ? 'Connexion...' : 'Se connecter' }}
          </button>

          <div v-if="error" class="text-sm text-red-600 text-center">
            {{ error }}
          </div>
        </form>

        <div class="mt-6 space-y-4">
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <span class="w-full border-t" />
            </div>
            <div class="relative flex justify-center text-xs uppercase">
              <span class="bg-card px-2 text-muted-foreground">
                Ou continuer avec
              </span>
            </div>
          </div>

          <div class="grid grid-cols-2 gap-2">
            <button
              @click="handleGoogleLogin"
              type="button"
              class="inline-flex items-center justify-center rounded-md border border-input bg-background px-4 py-2 text-sm font-medium hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"
            >
              Google
            </button>
            <button
              @click="handleFacebookLogin"
              type="button"
              class="inline-flex items-center justify-center rounded-md border border-input bg-background px-4 py-2 text-sm font-medium hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"
            >
              Facebook
            </button>
          </div>
        </div>

        <div class="mt-6 text-center text-sm">
          <span class="text-muted-foreground">Pas encore de compte ?</span>
          <NuxtLink 
            to="/auth/register" 
            class="text-primary hover:text-primary/80 font-medium ml-1"
          >
            S'inscrire
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  try {
    loading.value = true
    error.value = ''

    const { error: signInError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })

    if (signInError) {
      error.value = signInError.message
      return
    }

    await router.push('/')
  } catch (err) {
    error.value = 'Une erreur est survenue lors de la connexion'
    console.error('Login error:', err)
  } finally {
    loading.value = false
  }
}

const handleGoogleLogin = async () => {
  try {
    const { error: signInError } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/`
      }
    })

    if (signInError) {
      error.value = signInError.message
    }
  } catch (err) {
    error.value = 'Erreur lors de la connexion avec Google'
    console.error('Google login error:', err)
  }
}

const handleFacebookLogin = async () => {
  try {
    const { error: signInError } = await supabase.auth.signInWithOAuth({
      provider: 'facebook',
      options: {
        redirectTo: `${window.location.origin}/`
      }
    })

    if (signInError) {
      error.value = signInError.message
    }
  } catch (err) {
    error.value = 'Erreur lors de la connexion avec Facebook'
    console.error('Facebook login error:', err)
  }
}

// Redirection si déjà connecté
watch(user, (newUser) => {
  if (newUser) {
    router.push('/')
  }
}, { immediate: true })

useHead({
  title: 'Connexion - PadelSpot',
  meta: [
    { name: 'description', content: 'Connectez-vous à votre compte PadelSpot pour réserver vos terrains de padel.' }
  ]
})
</script>