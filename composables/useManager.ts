export const useManager = () => {
  const user = useSupabaseUser()
  const supabase = useSupabaseClient()
  
  const isManager = ref(false)
  const managedCenters = ref<any[]>([])
  const loading = ref(false)

  const checkManagerStatus = async () => {
    if (!user.value) {
      isManager.value = false
      managedCenters.value = []
      return
    }

    loading.value = true

    try {
      const { data, error } = await supabase
        .from('centers')
        .select('id, name, is_active')
        .eq('manager_user_id', user.value.id)

      if (error) throw error

      managedCenters.value = data || []
      isManager.value = managedCenters.value.length > 0
    } catch (error) {
      console.error('Error checking manager status:', error)
      isManager.value = false
      managedCenters.value = []
    } finally {
      loading.value = false
    }
  }

  // Watch for user changes
  watch(user, () => {
    checkManagerStatus()
  }, { immediate: true })

  return {
    isManager: readonly(isManager),
    managedCenters: readonly(managedCenters),
    loading: readonly(loading),
    checkManagerStatus
  }
}