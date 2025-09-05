import { useColorMode } from '@vueuse/nuxt'

export interface ThemeConfig {
  name: string
  label: string
  cssVars: Record<string, string>
  darkMode?: boolean
}

export const useTheme = () => {
  const colorMode = useColorMode()

  const themes = ref<ThemeConfig[]>([
    {
      name: 'light',
      label: 'Clair',
      cssVars: {
        '--background': '0 0% 100%',
        '--foreground': '222.2 84% 4.9%',
        '--primary': '221.2 83.2% 53.3%',
        '--primary-foreground': '210 40% 98%',
      }
    },
    {
      name: 'dark',
      label: 'Sombre',
      cssVars: {
        '--background': '222.2 84% 4.9%',
        '--foreground': '210 40% 98%',
        '--primary': '217.2 91.2% 59.8%',
        '--primary-foreground': '222.2 84% 4.9%',
      },
      darkMode: true
    },
    {
      name: 'padel-green',
      label: 'Vert Padel',
      cssVars: {
        '--background': '120 20% 98%',
        '--foreground': '120 10% 10%',
        '--primary': '142 76% 36%',
        '--primary-foreground': '355 100% 97%',
      }
    },
    {
      name: 'ocean-blue',
      label: 'Bleu Océan',
      cssVars: {
        '--background': '210 20% 98%',
        '--foreground': '210 10% 10%',
        '--primary': '217 91% 60%',
        '--primary-foreground': '210 40% 98%',
      }
    }
  ])

  const currentTheme = computed(() => 
    themes.value.find(theme => theme.name === colorMode.value) || themes.value[0]
  )

  const setTheme = (themeName: string) => {
    const theme = themes.value.find(t => t.name === themeName)
    if (!theme) return

    colorMode.value = themeName

    // Apply CSS variables
    const root = document.documentElement
    Object.entries(theme.cssVars).forEach(([property, value]) => {
      root.style.setProperty(property, value)
    })

    // Store theme preference
    if (import.meta.client) {
      localStorage.setItem('padelspot-theme', themeName)
    }
  }

  const toggleTheme = () => {
    const currentIndex = themes.value.findIndex(t => t.name === colorMode.value)
    const nextIndex = (currentIndex + 1) % themes.value.length
    setTheme(themes.value[nextIndex].name)
  }

  // Initialize theme on client
  if (import.meta.client) {
    const savedTheme = localStorage.getItem('padelspot-theme')
    if (savedTheme && themes.value.find(t => t.name === savedTheme)) {
      setTheme(savedTheme)
    }
  }

  return {
    themes: readonly(themes),
    currentTheme,
    setTheme,
    toggleTheme
  }
}