# Installation des migrations PadelSpot

## Prérequis
- Accès à votre projet Supabase
- Permissions d'administrateur sur la base de données

## Instructions d'installation

### Étape 1 : Connexion à Supabase
1. Allez sur [supabase.com](https://supabase.com)
2. Ouvrez votre projet PadelSpot
3. Cliquez sur "SQL Editor" dans le menu de gauche

### Étape 2 : Exécution des migrations

**IMPORTANT : Exécutez les migrations dans l'ordre indiqué !**

#### Migration 1 : Profils utilisateurs
```sql
-- Copiez et collez le contenu de database/migrations/001_create_users_profiles.sql
```

#### Migration 2 : Centres de padel  
```sql
-- Copiez et collez le contenu de database/migrations/002_create_centers.sql
```

#### Migration 3 : Terrains
```sql
-- Copiez et collez le contenu de database/migrations/003_create_courts.sql
```

#### Migration 4 : Créneaux horaires
```sql
-- Copiez et collez le contenu de database/migrations/004_create_time_slots.sql
```

#### Migration 5 : Réservations
```sql
-- Copiez et collez le contenu de database/migrations/005_create_bookings.sql
```

#### Migration 6 : Sécurité et fonctions
```sql
-- Copiez et collez le contenu de database/migrations/006_rls_policies_and_functions.sql
```

#### Migration 7 : Données de test (optionnel)
```sql
-- Copiez et collez le contenu de database/migrations/007_sample_data.sql
-- ATTENTION : Seulement pour le développement !
```

### Étape 3 : Vérification

Après chaque migration, vérifiez qu'il n'y a pas d'erreurs dans la console Supabase.

Vous pouvez tester avec cette requête :
```sql
-- Vérifier que toutes les tables sont créées
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('user_profiles', 'centers', 'courts', 'time_slots', 'bookings');
```

### Étape 4 : Configuration des variables d'environnement

Assurez-vous que votre fichier `.env` contient :
```env
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

## Dépannage

### Erreur "relation does not exist"
- Vérifiez que les migrations précédentes ont été exécutées
- Respectez l'ordre d'exécution

### Erreur de permissions
- Vérifiez que vous êtes connecté avec un compte administrateur
- Les politiques RLS peuvent bloquer certaines opérations

### Erreur sur les triggers
- Certains triggers peuvent échouer si les fonctions n'existent pas encore
- Réexécutez la migration problématique

## Test de fonctionnement

Une fois toutes les migrations appliquées, testez avec :

```sql
-- Test de recherche de centres
SELECT * FROM public.search_centers_by_location(48.8566, 2.3522, 'Paris', 50, 10);

-- Test de disponibilité
SELECT * FROM public.get_available_courts(
  '550e8400-e29b-41d4-a716-446655440001', 
  CURRENT_DATE + 1, 
  '10:00', 
  '11:30'
);
```

## Support

En cas de problème :
1. Consultez les logs d'erreur dans Supabase
2. Vérifiez le fichier `database/README.md`
3. Relancez la migration qui a échoué