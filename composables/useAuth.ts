export interface AuthUser {
  id: string
  email: string
  user_metadata?: Record<string, any>
  app_metadata?: Record<string, any>
}

export interface UserProfile {
  id: string
  email: string
  full_name?: string
  avatar_url?: string
  phone?: string
  role: 'user' | 'manager' | 'admin'
  created_at: string
  updated_at: string
}

export interface AuthError {
  message: string
  status?: number
}

export const useAuth = () => {
  const supabase = useSupabaseClient()
  
  // Get user from Supabase
  const user = useSupabaseUser()
  
  // State
  const profile = ref<UserProfile | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)
  
  // Computed
  const isAuthenticated = computed(() => !!user.value)
  const isManager = computed(() => profile.value?.role === 'manager')
  const isAdmin = computed(() => profile.value?.role === 'admin')
  
  // Methods
  const signUp = async (email: string, password: string, fullName?: string) => {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: signUpError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: fullName
          }
        }
      })
      
      if (signUpError) throw signUpError
      
      return { user: data.user, session: data.session }
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors de l\'inscription'
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const signIn = async (email: string, password: string) => {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password
      })
      
      if (signInError) throw signInError
      
      return { user: data.user, session: data.session }
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors de la connexion'
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const signOut = async () => {
    loading.value = true
    error.value = null
    
    try {
      const { error: signOutError } = await supabase.auth.signOut()
      
      if (signOutError) throw signOutError
      
      profile.value = null
      
      // Redirect to home
      await navigateTo('/')
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors de la déconnexion'
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const signInWithProvider = async (provider: 'google' | 'facebook' | 'github') => {
    loading.value = true
    error.value = null
    
    try {
      const { data, error: providerError } = await supabase.auth.signInWithOAuth({
        provider,
        options: {
          redirectTo: `${window.location.origin}/auth/callback`
        }
      })
      
      if (providerError) throw providerError
      
      return data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors de la connexion'
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const resetPassword = async (email: string) => {
    loading.value = true
    error.value = null
    
    try {
      const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/auth/reset-password`
      })
      
      if (resetError) throw resetError
      
      return true
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors de la réinitialisation'
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const updatePassword = async (newPassword: string) => {
    loading.value = true
    error.value = null
    
    try {
      const { error: updateError } = await supabase.auth.updateUser({
        password: newPassword
      })
      
      if (updateError) throw updateError
      
      return true
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors de la mise à jour'
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const fetchProfile = async () => {
    if (!user.value) {
      profile.value = null
      return
    }
    
    loading.value = true
    error.value = null
    
    try {
      const { data, error: profileError } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('id', user.value.id)
        .single()
      
      if (profileError && profileError.code !== 'PGRST116') {
        throw profileError
      }
      
      // If no profile exists, create one
      if (!data) {
        const { data: newProfile, error: createError } = await supabase
          .from('user_profiles')
          .insert({
            id: user.value.id,
            email: user.value.email!,
            full_name: user.value.user_metadata?.full_name || null,
            role: 'user'
          })
          .select()
          .single()
        
        if (createError) throw createError
        
        profile.value = newProfile
      } else {
        profile.value = data
      }
    } catch (err) {
      console.error('Error fetching profile:', err)
      error.value = err instanceof Error ? err.message : 'Erreur lors du chargement du profil'
    } finally {
      loading.value = false
    }
  }
  
  const updateProfile = async (updates: Partial<UserProfile>) => {
    if (!user.value || !profile.value) {
      throw new Error('Utilisateur non connecté')
    }
    
    loading.value = true
    error.value = null
    
    try {
      const { data, error: updateError } = await supabase
        .from('user_profiles')
        .update({
          ...updates,
          updated_at: new Date().toISOString()
        })
        .eq('id', user.value.id)
        .select()
        .single()
      
      if (updateError) throw updateError
      
      profile.value = data
      
      return data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur lors de la mise à jour'
      throw err
    } finally {
      loading.value = false
    }
  }
  
  const clearError = () => {
    error.value = null
  }
  
  // Auto-fetch profile when user changes
  watch(user, (newUser) => {
    if (newUser) {
      fetchProfile()
    } else {
      profile.value = null
    }
  }, { immediate: true })
  
  return {
    // State
    user: readonly(user),
    profile: readonly(profile),
    loading: readonly(loading),
    error: readonly(error),
    
    // Computed
    isAuthenticated,
    isManager,
    isAdmin,
    
    // Methods
    signUp,
    signIn,
    signOut,
    signInWithProvider,
    resetPassword,
    updatePassword,
    fetchProfile,
    updateProfile,
    clearError
  }
}