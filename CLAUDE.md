# CLAUDE.md

Ce fichier fournit des instructions à Claude Code (claude.ai/code) pour travailler avec le code de ce dépôt.

## Vue d'ensemble du projet

PadelSpot est une Progressive Web App (PWA) de réservation de terrains de padel développée avec Nuxt 3, Vue 3 et TypeScript. L'application vise à offrir une interface simple, intuitive et moderne pour la réservation de créneaux de padel.

## Objectifs UX/UI

- **Interface minimaliste** : pas plus de 3 clics pour réserver
- **Design moderne** avec ShadCN Vue et système de thèmes configurables  
- **Navigation intuitive** avec micro-animations fluides
- **Thèmes multiples** : clair/sombre/personnalisés + branding par centre
- **Expérience mobile-first** avec gestures optimisées pour mobile

## Stack technique

- **Frontend** : Nuxt 3 + Vue 3 + TypeScript
- **UI/UX** : ShadCN Vue avec système de thèmes flexible
- **Styling** : TailwindCSS pour styling personnalisé
- **Backend** : Supabase (authentification + base de données + temps réel)
- **Paiements** : Stripe pour paiements sécurisés
- **PWA** : @vite-pwa/nuxt avec notifications push

## Architecture du projet

```
D:\workspace\padelSpot\
├── assets/
│   └── css/
│       └── main.css              # Styles TailwindCSS + variables CSS ShadCN
├── components/
│   └── ui/                       # Composants ShadCN Vue
├── composables/
│   ├── useTheme.ts              # Gestion des thèmes (clair/sombre/personnalisés)
│   └── useBooking.ts            # Logique de réservation et gestion des centres
├── lib/
│   └── utils.ts                 # Utilitaires (cn function pour classes CSS)
├── pages/                       # Pages Nuxt (routing automatique)
├── layouts/                     # Layouts Nuxt
├── plugins/                     # Plugins Nuxt
├── server/                      # API routes Nuxt
└── public/                      # Assets statiques (icônes PWA)
```

## Fonctionnalités clés

1. **Recherche géolocalisée** de centres de padel
2. **Sélection de créneaux intuitive** avec calendrier moderne
3. **Paiement en 2 clics** avec intégration Stripe
4. **Dashboard gérant** simplifié pour les centres
5. **Système de thèmes** avec persistance utilisateur
6. **Quick actions** et gestion des favoris
7. **Notifications** temps réel pour confirmations/rappels

## Composables principaux

- **`useTheme()`** : Gestion des thèmes ShadCN avec CSS variables
- **`useBooking()`** : Logique de réservation, recherche de centres, créneaux
- **`useSupabaseClient()`** : Client Supabase pour base de données
- **`useSupabaseUser()`** : Gestion utilisateur et authentification

## Configuration

### Variables d'environnement (.env)
```
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
STRIPE_SECRET_KEY=your_stripe_secret_key_here
NUXT_PUBLIC_APP_URL=http://localhost:3000
```

### Commandes de développement

- `npm run dev` : Démarrer le serveur de développement
- `npm run build` : Construire l'application pour la production
- `npm run preview` : Prévisualiser l'application construite
- `npm run generate` : Générer l'application statique

### Commandes de qualité de code

- `npm run typecheck` : Vérification TypeScript (à implémenter)
- `npm run lint` : ESLint (à implémenter)
- `npm run test` : Tests unitaires (à implémenter)

## Modules et dépendances

### Modules Nuxt
- `@nuxtjs/tailwindcss` : Intégration TailwindCSS
- `@pinia/nuxt` : Gestion d'état avec Pinia
- `@nuxtjs/color-mode` : Gestion mode sombre/clair
- `@vueuse/nuxt` : Utilitaires Vue composition
- `@nuxtjs/supabase` : Intégration Supabase
- `@vite-pwa/nuxt` : Progressive Web App

### Dépendances principales
- `radix-vue` : Composants headless pour ShadCN
- `lucide-vue-next` : Icônes modernes
- `clsx` + `tailwind-merge` : Gestion classes CSS conditionnelles
- `class-variance-authority` : Variants de composants
- `@supabase/supabase-js` : Client JavaScript Supabase

## Conventions de code

- **TypeScript strict** : Toujours typer les interfaces et composables
- **Composition API** : Utiliser `<script setup>` dans tous les composants
- **Naming** : kebab-case pour les fichiers, PascalCase pour les composants
- **Structure** : Séparer la logique business dans les composables
- **CSS** : Utiliser les utilitaires TailwindCSS + variables CSS pour les thèmes

## Base de données (Supabase)

### Tables principales
- `centers` : Centres de padel (nom, adresse, coordonnées, horaires)
- `courts` : Terrains (type, surface, prix, équipements)
- `time_slots` : Créneaux horaires disponibles
- `bookings` : Réservations utilisateurs
- `users` : Profils utilisateurs étendus

### Authentification
- Utilise Supabase Auth avec redirection vers `/auth/login`
- Support email/password + OAuth (Google, Facebook)
- Session persistante avec `useSupabaseUser()`

## PWA Configuration

- **Manifest** : Icônes multi-tailles, mode standalone, orientation portrait
- **Service Worker** : Cache automatique avec Workbox
- **Install prompt** : Promotion d'installation native
- **Offline support** : Navigation hors ligne basique

## Notes pour Claude Code

- **Priorité mobile** : Toujours tester l'expérience mobile en premier
- **Performance** : Optimiser les images, lazy loading, code splitting
- **Accessibilité** : Utiliser les composants ShadCN qui incluent ARIA
- **SEO** : Meta tags Nuxt pour référencement local
- **Sécurité** : Valider côté serveur, utiliser Row Level Security Supabase

## Roadmap de développement

### Phase 1 - Fondations (MVP)
- [x] 1. Créer les premières pages (pages/index.vue, pages/auth/login.vue)
- [x] 2. Ajouter des composants ShadCN (npx shadcn-vue@latest add button card input)
- [x] 3. Créer les schémas de base de données Supabase

### Phase 2 - Authentification et pages principales
- [x] 4. Implémenter l'authentification Supabase
- [x] 5. Créer les pages centres, réservation

### Phase 3 - Fonctionnalités core
- [x] 6. Implémenter la recherche géolocalisée de centres
- [ ] 7. Développer l'interface de sélection de créneaux
- [ ] 8. Développer le dashboard Gérant

### Phase 4 - Paiements et finalisation
- [ ] 9. Intégrer Stripe pour les paiements
- [ ] 10. Configurer les notifications PWA
- [ ] 11. Tests et optimisations