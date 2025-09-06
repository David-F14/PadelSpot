# Création d'utilisateurs de test pour PadelSpot

## Étapes à suivre

### 1. Créer les utilisateurs dans Supabase Dashboard

1. Allez sur [votre projet Supabase](https://app.supabase.com)
2. Cliquez sur **Authentication** > **Users**
3. Cliquez sur **"Add user"**
4. Créez ces comptes de test :

#### Gestionnaire Paris
- **Email:** `manager.paris@email.com`
- **Password:** `test123456`
- **Confirm password:** `test123456`
- Cochez "Auto Confirm User"

#### Gestionnaire Lyon  
- **Email:** `manager.lyon@email.com`
- **Password:** `test123456`
- **Confirm password:** `test123456`
- Cochez "Auto Confirm User"

#### Utilisateur Test
- **Email:** `test.user@email.com`
- **Password:** `test123456`
- **Confirm password:** `test123456`
- Cochez "Auto Confirm User"

### 2. Récupérer les UUIDs

Après création, notez les **UUIDs** de chaque utilisateur (colonne "id" dans le tableau).

### 3. Assigner les gestionnaires aux centres

Exécutez ces requêtes dans le SQL Editor en remplaçant les UUIDs :

```sql
-- Assigner les gestionnaires aux centres
UPDATE public.centers 
SET manager_user_id = 'UUID_MANAGER_PARIS' 
WHERE id = '550e8400-e29b-41d4-a716-446655440001';

UPDATE public.centers 
SET manager_user_id = 'UUID_MANAGER_LYON' 
WHERE id = '550e8400-e29b-41d4-a716-446655440002';

-- Mettre à jour les rôles (si la colonne role existe)
UPDATE public.user_profiles 
SET role = 'manager' 
WHERE id IN ('UUID_MANAGER_PARIS', 'UUID_MANAGER_LYON');
```

### 4. Vérifier que tout fonctionne

```sql
-- Vérifier les profils créés
SELECT id, email, first_name, last_name, role 
FROM public.user_profiles;

-- Vérifier les centres avec leurs gestionnaires
SELECT 
  c.name as center_name,
  up.email as manager_email,
  up.role as manager_role
FROM public.centers c
LEFT JOIN public.user_profiles up ON up.id = c.manager_user_id;

-- Vérifier les créneaux générés
SELECT COUNT(*) as total_slots 
FROM public.time_slots;
```

### 5. Tester la connexion

1. Lancez votre app PadelSpot : `npm run dev`
2. Allez sur `/auth/login`
3. Connectez-vous avec `test.user@email.com` / `test123456`
4. Vérifiez que le profil se crée automatiquement

## Données de test disponibles

Après ces étapes, vous aurez :
- ✅ **4 centres** avec données réalistes
- ✅ **13 terrains** avec différents types et prix
- ✅ **Créneaux horaires** générés pour 30 jours
- ✅ **Utilisateurs de test** fonctionnels
- ✅ **Fonctions de recherche** opérationnelles

## Test rapide

```sql
-- Rechercher des centres à Paris
SELECT * FROM public.search_centers_by_location(48.8566, 2.3522, 'Paris', 50, 10);

-- Voir les terrains disponibles demain à 14h-15h30
SELECT * FROM public.get_available_courts(
  '550e8400-e29b-41d4-a716-446655440001', -- Paris center
  CURRENT_DATE + 1, 
  '14:00', 
  '15:30'
);
```