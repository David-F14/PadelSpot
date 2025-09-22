export const useUser = () => {
  const user = useSupabaseUser()
  const supabase = useSupabaseClient()

  const isManager = ref(false)
  const isPlayer = ref(false)
  const managedCenters = ref<any[]>([])
  const userRole = ref<string | null>(null)
  const loading = ref(false)

  const checkUserStatus = async () => {
    if (!user.value) {
      isManager.value = false
      isPlayer.value = false
      managedCenters.value = []
      userRole.value = null
      return
    }

    loading.value = true

    try {
      // Get user role from user_profiles table
      const { data: profileData, error: profileError } = await supabase
        .from('user_profiles')
        .select('role')
        .eq('id', user.value.id)
        .single()

      if (profileError) throw profileError

      userRole.value = profileData?.role || null
      isManager.value = userRole.value === 'manager'
      isPlayer.value = userRole.value === 'player'

      // If user is a manager, get their managed centers
      if (isManager.value) {
        const { data: centersData, error: centersError } = await supabase
          .from('centers')
          .select('id, name, is_active')
          .eq('manager_user_id', user.value.id)

        if (centersError) throw centersError
        managedCenters.value = centersData || []
      } else {
        managedCenters.value = []
      }

    } catch (error) {
      console.error('Error checking user status:', error)
      isManager.value = false
      isPlayer.value = false
      managedCenters.value = []
      userRole.value = null
    } finally {
      loading.value = false
    }
  }

  // Watch for user changes
  watch(user, () => {
    checkUserStatus()
  }, { immediate: true })

  return {
    isManager: readonly(isManager),
    isPlayer: readonly(isPlayer),
    managedCenters: readonly(managedCenters),
    userRole: readonly(userRole),
    loading: readonly(loading),
    checkUserStatus
  }
}