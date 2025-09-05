// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt',
    '@nuxtjs/color-mode',
    '@vueuse/nuxt',
    '@nuxtjs/supabase',
    '@vite-pwa/nuxt'
  ],
  tailwindcss: {
    cssPath: '~/assets/css/tailwind.css'
  },
  colorMode: {
    classSuffix: ''
  },
  supabase: {
    url: process.env.SUPABASE_URL,
    key: process.env.SUPABASE_ANON_KEY,
    redirectOptions: {
      login: '/auth/login',
      callback: '/auth/confirm',
      exclude: ['/']
    }
  },
  pwa: {
    registerType: 'autoUpdate',
    workbox: {
      navigateFallback: '/',
      globPatterns: ['**/*.{js,css,html,png,svg,ico}'],
    },
    client: {
      installPrompt: true,
    },
    devOptions: {
      enabled: true,
      navigateFallbackAllowlist: [/^\/$/],
      type: 'module',
    },
    manifest: {
      name: 'PadelSpot',
      short_name: 'PadelSpot',
      description: 'Réservation de terrains de padel en toute simplicité',
      theme_color: '#3B82F6',
      background_color: '#ffffff',
      display: 'standalone',
      orientation: 'portrait',
      scope: '/',
      start_url: '/',
      icons: [
        {
          src: '/icon-72x72.png',
          sizes: '72x72',
          type: 'image/png'
        },
        {
          src: '/icon-96x96.png',
          sizes: '96x96',
          type: 'image/png'
        },
        {
          src: '/icon-128x128.png',
          sizes: '128x128',
          type: 'image/png'
        },
        {
          src: '/icon-144x144.png',
          sizes: '144x144',
          type: 'image/png'
        },
        {
          src: '/icon-152x152.png',
          sizes: '152x152',
          type: 'image/png'
        },
        {
          src: '/icon-192x192.png',
          sizes: '192x192',
          type: 'image/png'
        },
        {
          src: '/icon-384x384.png',
          sizes: '384x384',
          type: 'image/png'
        },
        {
          src: '/icon-512x512.png',
          sizes: '512x512',
          type: 'image/png'
        }
      ]
    }
  }
})