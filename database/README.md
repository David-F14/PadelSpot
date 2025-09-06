# Base de données PadelSpot

Cette documentation décrit la structure de la base de données PostgreSQL utilisée par PadelSpot, avec les tables, relations et fonctions nécessaires au fonctionnement de l'application.

## Vue d'ensemble

PadelSpot utilise Supabase (PostgreSQL) avec Row Level Security (RLS) pour garantir la sécurité des données. La base de données est conçue pour supporter :

- Gestion des utilisateurs et profils étendus
- Centres de padel et leurs terrains
- Système de réservation en temps réel
- Gestion des créneaux horaires et tarification dynamique
- Paiements et facturation

## Structure des tables

### 1. Profils utilisateurs (`user_profiles`)

Étend les utilisateurs Supabase Auth avec des informations supplémentaires.

**Colonnes principales :**
- `id` : UUID lié à `auth.users`
- `email`, `first_name`, `last_name` : Informations personnelles
- `phone`, `avatar_url`, `date_of_birth` : Données de profil
- `skill_level` : Niveau de jeu (débutant, intermédiaire, avancé, expert)
- `favorite_centers` : Liste des centres favoris (UUID[])
- `role` : Rôle utilisateur (player, manager, admin)

### 2. Centres de padel (`centers`)

Informations sur les centres de padel partenaires.

**Colonnes principales :**
- `id` : Identifiant unique
- `name`, `description` : Informations de base
- `address_line1`, `city`, `postal_code` : Adresse complète
- `latitude`, `longitude` : Coordonnées GPS pour géolocalisation
- `opening_hours` : Horaires d'ouverture (JSONB)
- `manager_user_id` : Gestionnaire du centre
- `average_rating`, `total_reviews` : Système d'évaluation

### 3. Terrains (`courts`)

Terrains individuels au sein des centres.

**Colonnes principales :**
- `id` : Identifiant unique
- `center_id` : Référence au centre parent
- `name`, `court_number` : Identification du terrain
- `surface_type` : Type de surface (gazon_synthetique, terre_battue, etc.)
- `court_type` : Intérieur/extérieur/semi-couvert
- `base_price_per_hour` : Prix de base à l'heure
- `peak_hours_multiplier` : Multiplicateur pour heures de pointe

### 4. Créneaux horaires (`time_slots`)

Créneaux de réservation disponibles pour chaque terrain.

**Colonnes principales :**
- `id` : Identifiant unique
- `court_id` : Référence au terrain
- `slot_date`, `start_time`, `end_time` : Créneau horaire
- `final_price` : Prix final calculé pour ce créneau
- `is_available`, `is_booked` : Statut de disponibilité
- `booking_id` : Référence à la réservation (si réservé)

### 5. Réservations (`bookings`)

Réservations effectuées par les utilisateurs.

**Colonnes principales :**
- `id` : Identifiant unique
- `user_id`, `court_id`, `center_id` : Références
- `booking_date`, `start_time`, `end_time` : Créneau réservé
- `status` : Statut (pending, confirmed, completed, cancelled, etc.)
- `payment_status` : Statut du paiement
- `total_price` : Prix total payé
- `players` : Informations des joueurs (JSONB)

## Migrations

Les migrations sont organisées par ordre chronologique :

1. **001_create_users_profiles.sql** - Profils utilisateurs étendus
2. **002_create_centers.sql** - Centres de padel
3. **003_create_courts.sql** - Terrains et tarification
4. **004_create_time_slots.sql** - Créneaux horaires
5. **005_create_bookings.sql** - Système de réservation
6. **006_rls_policies_and_functions.sql** - Sécurité et fonctions utilitaires

## Fonctions utilitaires

### Tarification

- `calculate_court_price()` - Calcule le prix d'un terrain selon la date/heure
- `calculate_booking_total()` - Calcule le prix total d'une réservation

### Disponibilité

- `is_court_available()` - Vérifie la disponibilité d'un terrain
- `get_available_courts()` - Liste des terrains disponibles pour un créneau
- `generate_time_slots_for_court()` - Génère des créneaux automatiquement

### Recherche

- `search_centers_by_location()` - Recherche de centres par géolocalisation
- `generate_center_slug()` - Génération de slugs URL-friendly

### Statistiques

- `get_user_booking_stats()` - Statistiques utilisateur
- `get_center_booking_stats()` - Statistiques centre

### Maintenance

- `cleanup_expired_bookings()` - Nettoyage des réservations expirées

## Sécurité (RLS)

Toutes les tables utilisent Row Level Security :

### Politiques principales

- **Users** : Accès à leurs propres données uniquement
- **Centers** : Lecture publique, modification par les gestionnaires
- **Courts** : Lecture publique, modification par les gestionnaires du centre
- **Bookings** : Accès utilisateur et gestionnaire du centre concerné
- **Admins** : Accès complet à toutes les données

## Installation

Pour appliquer les migrations sur votre instance Supabase :

1. Connectez-vous au SQL Editor de Supabase
2. Exécutez les migrations dans l'ordre (001 à 006)
3. Vérifiez que toutes les tables et fonctions sont créées
4. Testez les politiques RLS

```sql
-- Exemple de test de création de centre
INSERT INTO centers (name, address_line1, city, postal_code, manager_user_id)
VALUES ('Test Padel Center', '123 Rue de la Paix', 'Paris', '75001', auth.uid());
```

## Données de test

Pour peupler la base avec des données de test, vous pouvez utiliser les scripts suivants :

### Centres de test
```sql
INSERT INTO centers (name, address_line1, city, postal_code, latitude, longitude, manager_user_id)
VALUES 
  ('Padel Center Paris', '15 Avenue des Champs', 'Paris', '75008', 48.8566, 2.3522, auth.uid()),
  ('Lyon Padel Club', '20 Place Bellecour', 'Lyon', '69002', 45.7640, 4.8357, auth.uid()),
  ('Marseille Tennis Padel', '30 Vieux Port', 'Marseille', '13001', 43.2965, 5.3698, auth.uid());
```

### Terrains de test
```sql
-- Après avoir créé les centres, récupérez leurs IDs et créez des terrains
INSERT INTO courts (center_id, name, court_number, surface_type, base_price_per_hour)
VALUES 
  ('center-id-1', 'Court Central', 1, 'gazon_synthetique', 25.00),
  ('center-id-1', 'Court 2', 2, 'gazon_synthetique', 25.00);
```

## Maintenance

### Tâches régulières

1. **Nettoyage des réservations expirées** : Exécuter `cleanup_expired_bookings()` toutes les 5 minutes
2. **Génération des créneaux** : Utiliser `generate_time_slots_for_court()` pour créer les créneaux futurs
3. **Sauvegarde** : Sauvegarder quotidiennement via Supabase Dashboard

### Monitoring

Surveiller les métriques suivantes :
- Taux d'occupation des terrains
- Revenus par centre
- Performance des requêtes de recherche
- Erreurs de validation des réservations

## Support

Pour toute question sur la base de données :
1. Consultez les logs Supabase
2. Vérifiez les politiques RLS
3. Testez les fonctions via SQL Editor
4. Référez-vous à cette documentation