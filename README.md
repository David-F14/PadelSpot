# PadelSpot 🏓

Une Progressive Web App (PWA) moderne pour la réservation de terrains de padel, développée avec Nuxt 3, Vue 3 et TypeScript.

## 🎯 Objectifs

- **Interface minimaliste** : pas plus de 3 clics pour réserver
- **Design moderne** avec ShadCN Vue et système de thèmes configurables
- **Navigation intuitive** avec micro-animations fluides
- **Expérience mobile-first** optimisée pour smartphones

## 🚀 Stack technique

- **Frontend** : Nuxt 3 + Vue 3 + TypeScript
- **UI/UX** : ShadCN Vue avec système de thèmes flexible
- **Styling** : TailwindCSS
- **Backend** : Supabase (authentification + base de données + temps réel)
- **Paiements** : Stripe
- **PWA** : @vite-pwa/nuxt avec notifications push

## 📱 Fonctionnalités clés

1. **Recherche géolocalisée** de centres de padel
2. **Sélection de créneaux intuitive** avec calendrier moderne
3. **Paiement en 2 clics** avec intégration Stripe
4. **Dashboard gérant** simplifié pour les centres
5. **Système de thèmes** avec persistance utilisateur
6. **Quick actions** et gestion des favoris
7. **Notifications** temps réel pour confirmations/rappels

## ⚡ Installation

Clonez le projet et installez les dépendances :

```bash
git clone <repository-url>
cd padelSpot
npm install
```

## 🔧 Configuration

Créez un fichier `.env` à la racine du projet avec vos variables d'environnement :

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
STRIPE_SECRET_KEY=your_stripe_secret_key_here

# Application Configuration
NUXT_PUBLIC_APP_URL=http://localhost:3000
```

## 🏃‍♂️ Développement

Démarrez le serveur de développement :

```bash
npm run dev
```

L'application sera accessible sur `http://localhost:3000` (ou un autre port si celui-ci est occupé).

## 🏗️ Production

Construire l'application pour la production :

```bash
npm run build
```

Prévisualiser la version de production :

```bash
npm run preview
```

Générer l'application statique :

```bash
npm run generate
```

## 📁 Architecture du projet

```
D:\workspace\padelSpot\
├── assets/css/              # Styles TailwindCSS + variables CSS ShadCN
├── components/ui/           # Composants ShadCN Vue
├── composables/             # Composables Vue (useTheme, useBooking, etc.)
├── lib/                     # Utilitaires (cn function pour classes CSS)
├── pages/                   # Pages Nuxt (routing automatique)
├── layouts/                 # Layouts Nuxt
├── plugins/                 # Plugins Nuxt
├── server/                  # API routes Nuxt
└── public/                  # Assets statiques (icônes PWA)
```

## 🗃️ Base de données (Supabase)

### Tables principales
- `centers` : Centres de padel (nom, adresse, coordonnées, horaires)
- `courts` : Terrains (type, surface, prix, équipements)
- `time_slots` : Créneaux horaires disponibles
- `bookings` : Réservations utilisateurs
- `users` : Profils utilisateurs étendus

### Authentification
- Support email/password + OAuth (Google, Facebook)
- Session persistante avec `useSupabaseUser()`
- Redirection automatique vers `/auth/login`

## 🗺️ Roadmap

### Phase 1 - Fondations (MVP)
- [x] Configuration initiale du projet
- [ ] Pages de base (accueil, authentification)
- [ ] Composants ShadCN de base
- [ ] Schémas de base de données

### Phase 2 - Authentification et pages principales
- [ ] Authentification Supabase complète
- [ ] Pages centres et réservation

### Phase 3 - Fonctionnalités core
- [ ] Recherche géolocalisée de centres
- [ ] Interface de sélection de créneaux
- [ ] Dashboard gérant

### Phase 4 - Paiements et finalisation
- [ ] Intégration Stripe
- [ ] Notifications PWA
- [ ] Tests et optimisations

## 🤝 Contribution

Pour contribuer au projet :

1. Forkez le repository
2. Créez une branche pour votre feature (`git checkout -b feature/amazing-feature`)
3. Committez vos changements (`git commit -m 'Add amazing feature'`)
4. Pushez vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème, ouvrez une issue sur GitHub ou contactez l'équipe de développement.

---

Développé avec ❤️ pour la communauté padel