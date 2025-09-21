export default defineNuxtRouteMiddleware((to) => {
  const user = useSupabaseUser()

  // Pages publiques qui ne nécessitent pas d'authentification
  const publicRoutes = [
    '/auth/login',
    '/auth/register',
    '/auth/confirm',
    '/about'
  ]

  // Si l'utilisateur n'est pas connecté et n'est pas sur une page publique
  if (!user.value && !publicRoutes.includes(to.path)) {
    return navigateTo('/auth/login')
  }
})