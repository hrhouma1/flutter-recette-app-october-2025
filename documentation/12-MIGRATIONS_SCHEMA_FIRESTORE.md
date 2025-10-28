# Cours Pédagogique - Migrations de Schéma dans Firestore

## Informations du document

**Date :** 27 octobre 2025  
**Niveau :** Intermédiaire à Avancé  
**Durée de lecture :** 60 minutes  
**Prérequis :** Connaissances de base en Firestore et Flutter

---

## Table des matières

1. [Fondamentaux Firestore](#fondamentaux-firestore)
2. [Concept de migration de schéma](#concept-de-migration-de-schéma)
3. [Notre cas pratique : Suppression du champ icon](#notre-cas-pratique)
4. [Stratégies de migration](#stratégies-de-migration)
5. [Synchronisation application-base de données](#synchronisation-application-base-de-données)
6. [Problèmes d'incompatibilité](#problèmes-dincompatibilité)
7. [Meilleures pratiques](#meilleures-pratiques)
8. [Migrations complexes](#migrations-complexes)

---

## Fondamentaux Firestore

### Nature schema-less de Firestore

#### Différence avec bases SQL

**Base de données SQL (PostgreSQL, MySQL) :**
```sql
CREATE TABLE categories (
  id INT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  icon VARCHAR(10),
  color VARCHAR(6) NOT NULL
);
```

Caractéristiques :
- Schéma strict défini à l'avance
- Toutes les lignes ont la même structure
- Modification de schéma = ALTER TABLE (peut être bloquant)
- Types de données fixes

**Base de données NoSQL (Firestore) :**
```
Collection: categories
Document 1:
  name: "Breakfast"
  icon: "icone"
  color: "FFE8B4"

Document 2:
  name: "Lunch"
  color: "FFC4E1"
  nouveau_champ: "valeur"
```

Caractéristiques :
- Pas de schéma imposé
- Chaque document peut avoir des champs différents
- Flexibilité totale
- Types dynamiques

#### Implications pratiques

**Flexibilité :**
- Vous pouvez ajouter des champs à tout moment
- Vous pouvez supprimer des champs sans altérer la base
- Vous pouvez changer le type d'un champ

**Responsabilités :**
- L'application doit gérer les variations de structure
- Le code doit être défensif (vérifier existence des champs)
- La cohérence des données est sous votre contrôle

### Structure d'un document Firestore

```javascript
{
  // Métadonnées (générées automatiquement)
  id: "abc123",              // Document ID
  createTime: "timestamp",    // Date de création
  updateTime: "timestamp",    // Date dernière modification
  
  // Données (définies par vous)
  fields: {
    name: "Breakfast",
    icon: "icone",
    color: "FFE8B4"
  }
}
```

**Champs système (non modifiables) :**
- Document ID
- createTime
- updateTime

**Champs données (modifiables) :**
- Définis par votre application
- Peuvent changer au fil du temps

---

## Concept de migration de schéma

### Qu'est-ce qu'une migration ?

**Définition :**
Une migration de schéma est le processus de modification de la structure des données stockées dans une base de données.

**Exemples de migrations :**
1. Ajouter un champ
2. Supprimer un champ
3. Renommer un champ
4. Changer le type d'un champ
5. Restructurer les données (normalisation/dénormalisation)

### Pourquoi migrer ?

**Raisons techniques :**
- Évolution des besoins métier
- Optimisation des requêtes
- Correction d'erreurs de conception
- Simplification du modèle

**Raisons fonctionnelles :**
- Nouvelles fonctionnalités
- Suppression de fonctionnalités obsolètes
- Amélioration de l'expérience utilisateur

### Migrations SQL vs Firestore

#### SQL : Migrations synchrones et bloquantes

**Exemple SQL :**
```sql
-- Migration 001: Ajouter colonne email
ALTER TABLE users ADD COLUMN email VARCHAR(255);

-- Migration 002: Supprimer colonne phone
ALTER TABLE users DROP COLUMN phone;

-- Migration 003: Renommer colonne
ALTER TABLE users RENAME COLUMN old_name TO new_name;
```

Caractéristiques :
- Exécution immédiate sur toutes les lignes
- Peut bloquer la base (locks)
- Opération transactionnelle
- Rollback possible

#### Firestore : Migrations asynchrones et progressives

**Exemple Firestore :**
```javascript
// Pas de commande ALTER
// La migration se fait document par document
```

Caractéristiques :
- Pas de commande de migration native
- Opérations programmatiques
- Progression graduelle
- Pas de blocage de la base

---

## Notre cas pratique

### Situation initiale

**Structure originale :**
```json
{
  "name": "Breakfast",
  "icon": "icone",
  "color": "FFE8B4"
}
```

**Modèle Dart :**
```dart
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
}
```

**12 documents** dans la collection "categories", tous avec 3 champs.

### Décision de migration

**Objectif :** Supprimer le champ "icon" de toutes les catégories

**Raisons :**
1. Simplification du modèle de données
2. Les icônes ne sont pas utilisées dans l'UI
3. Réduction de la complexité du code
4. Facilite les futures migrations

### Structure cible

**Après migration :**
```json
{
  "name": "Breakfast",
  "color": "FFE8B4"
}
```

**Modèle Dart mis à jour :**
```dart
class CategoryModel {
  final String id;
  final String name;
  final String color;
  // icon supprimé
}
```

### Étapes de la migration

#### Étape 1 : Mise à jour du script d'ajout

**Fichier :** `scripts/add_categories_gcloud.ps1`

**Avant (lignes 44-57) :**
```powershell
$categories = @(
    @{name="Breakfast"; icon="icone"; color="FFE8B4"},
    @{name="Lunch"; icon="icone"; color="FFC4E1"},
    # ...
)
```

**Après (lignes 44-57) :**
```powershell
$categories = @(
    @{name="Breakfast"; color="FFE8B4"},
    @{name="Lunch"; color="FFC4E1"},
    # ...
)
```

**Body de la requête avant (lignes 69-74) :**
```powershell
$body = @{
    fields = @{
        name = @{stringValue = $category.name}
        icon = @{stringValue = $category.icon}
        color = @{stringValue = $category.color}
    }
}
```

**Body de la requête après (lignes 69-73) :**
```powershell
$body = @{
    fields = @{
        name = @{stringValue = $category.name}
        color = @{stringValue = $category.color}
    }
}
```

#### Étape 2 : Création script de migration

**Fichier créé :** `scripts/remove_icons_from_categories.ps1`

**Algorithme :**
```
1. Authentification gcloud
2. Obtention token OAuth2
3. GET: Récupérer tous les documents de la collection
4. Pour chaque document:
   a. Extraire name et color (exclure icon)
   b. PATCH: Remplacer le document avec nouveaux champs uniquement
5. Afficher résultats
```

**Code clé :**
```powershell
# Récupération
$response = Invoke-RestMethod -Method Get -Uri $listUrl -Headers $headers
$documents = $response.documents

# Boucle de migration
foreach ($doc in $documents) {
    $docName = $doc.name
    
    # Nouveau body SANS icon
    $updateBody = @{
        fields = @{
            name = @{stringValue = $doc.fields.name.stringValue}
            color = @{stringValue = $doc.fields.color.stringValue}
        }
    } | ConvertTo-Json -Depth 10
    
    # PATCH: Remplace complètement le document
    Invoke-RestMethod -Method Patch -Uri "https://firestore.googleapis.com/v1/$docName" -Headers $updateHeaders -Body $updateBody
}
```

#### Étape 3 : Exécution de la migration

**Commande exécutée :**
```powershell
.\scripts\remove_icons_from_categories.ps1
```

**Résultat :**
```
12 catégories trouvées
   1. Dinner - icône supprimée
   2. Pizza - icône supprimée
   ... (12 succès)
```

**Durée :** ~5 secondes pour 12 documents

#### Étape 4 : Mise à jour du modèle Dart

**Fichier à modifier :** `lib/Models/category_model.dart`

**Avant :**
```dart
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '',
    );
  }
}
```

**Après :**
```dart
class CategoryModel {
  final String id;
  final String name;
  final String color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
    };
  }

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      color: map['color'] ?? '',
    );
  }
}
```

**Note importante :**
La ligne `icon: map['icon'] ?? ''` dans fromMap() peut être conservée temporairement pour rétrocompatibilité, mais elle sera ignorée car le paramètre icon n'existe plus dans le constructeur.

#### Étape 5 : Mise à jour du code utilisant le modèle

**Recherche des utilisations :**
```bash
grep -r "category.icon" lib/
```

**Résultat dans notre cas :**
Aucune utilisation dans l'UI. Le champ icon n'était pas affiché.

**Si utilisé, modification requise :**
```dart
// Avant
Text(category.icon)

// Après (supprimer ou remplacer)
// Supprimer complètement ou utiliser une valeur par défaut
```

---

## Stratégies de migration

### Stratégie 1 : Migration immédiate (utilisée dans notre cas)

**Processus :**
```
1. Modifier tous les documents existants
2. Mettre à jour le code de l'application
3. Déployer simultanément
```

**Avantages :**
- Simple et direct
- Pas de code de compatibilité
- Modèle de données propre immédiatement

**Inconvénients :**
- Nécessite downtime ou coordination
- Risqué si beaucoup de documents
- Pas de rollback facile

**適 pour :**
- Petits datasets (< 1000 documents)
- Applications en développement
- Changements non-critiques

**Notre implémentation :**
- 12 documents seulement
- Script prend 5 secondes
- Application peut être redémarrée rapidement

### Stratégie 2 : Migration progressive (lazy migration)

**Processus :**
```
1. Mettre à jour le code pour gérer ancienne ET nouvelle structure
2. Les nouveaux documents utilisent nouvelle structure
3. Les anciens documents sont migrés au fur et à mesure de leur lecture
4. Après période de transition, nettoyer les anciens documents restants
```

**Code exemple :**
```dart
factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
  return CategoryModel(
    id: id,
    name: map['name'] ?? '',
    color: map['color'] ?? '',
    // Gérer ancienne structure avec icon
    iconUrl: map['icon'] ?? map['iconUrl'] ?? '', // Nouveau nom de champ
  );
}

// Lors de la lecture, mettre à jour si nécessaire
Future<CategoryModel> getCategory(String id) async {
  final doc = await collection.doc(id).get();
  final category = CategoryModel.fromMap(doc.id, doc.data()!);
  
  // Si ancien format détecté, migrer
  if (doc.data()!.containsKey('icon')) {
    await migrateDocument(doc.id);
  }
  
  return category;
}
```

**Avantages :**
- Pas de downtime
- Migration graduelle
- Rollback possible
- Sécurisé

**Inconvénients :**
- Code complexe (gère 2 structures)
- Période de transition
- Logique de migration dans l'app

**適 pour :**
- Gros datasets (> 10000 documents)
- Applications en production
- Migrations risquées

### Stratégie 3 : Migration par version

**Processus :**
```
1. Ajouter champ "schemaVersion" à tous les documents
2. Code gère multiple versions
3. Migration en arrière-plan (Cloud Functions)
4. Monitoring de la progression
```

**Structure :**
```json
{
  "schemaVersion": 2,
  "name": "Breakfast",
  "color": "FFE8B4"
}
```

**Code :**
```dart
factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
  final version = map['schemaVersion'] ?? 1;
  
  switch (version) {
    case 1:
      return _fromV1(id, map);
    case 2:
      return _fromV2(id, map);
    default:
      throw Exception('Version de schéma non supportée: $version');
  }
}

static CategoryModel _fromV1(String id, Map<String, dynamic> map) {
  // Ancienne structure avec icon
  return CategoryModel(
    id: id,
    name: map['name'] ?? '',
    color: map['color'] ?? '',
  );
}

static CategoryModel _fromV2(String id, Map<String, dynamic> map) {
  // Nouvelle structure sans icon
  return CategoryModel(
    id: id,
    name: map['name'] ?? '',
    color: map['color'] ?? '',
  );
}
```

**Cloud Function de migration :**
```javascript
exports.migrateCategories = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const snapshot = await db.collection('categories')
      .where('schemaVersion', '==', 1)
      .limit(100)
      .get();
    
    const batch = db.batch();
    snapshot.docs.forEach(doc => {
      batch.update(doc.ref, {
        schemaVersion: 2,
        icon: admin.firestore.FieldValue.delete()
      });
    });
    
    await batch.commit();
    console.log(`Migrated ${snapshot.size} documents`);
  });
```

**Avantages :**
- Très sécurisé
- Monitoring précis
- Rollback facile
- Audit trail

**Inconvénients :**
- Complexité maximale
- Overhead (champ version)
- Nécessite Cloud Functions

**適 pour :**
- Applications critiques
- Datasets massifs
- Migrations complexes

### Stratégie 4 : Double écriture

**Processus :**
```
1. Écrire dans ancien ET nouveau format simultanément
2. Période de transition
3. Vérifier toutes les données dupliquées
4. Basculer vers nouveau format uniquement
```

**Code :**
```dart
Future<void> saveCategory(CategoryModel category) async {
  await firestore.collection('categories').doc(category.id).set({
    // Nouveau format
    'name': category.name,
    'color': category.color,
    // Ancien format (temporaire)
    'icon': category.icon, // Sera supprimé plus tard
  });
}
```

**適 pour :**
- Migrations critiques
- Besoin de rollback rapide
- Applications haute disponibilité

---

## Notre cas pratique

### Situation avant migration

**Firestore :**
```
Collection: categories (12 documents)

Document ID: abc123
{
  name: "Breakfast"
  icon: "icone emoji"
  color: "FFE8B4"
}

Document ID: def456
{
  name: "Lunch"
  icon: "icone emoji"
  color: "FFC4E1"
}

... (10 autres documents similaires)
```

**Code application :**
```dart
class CategoryModel {
  final String icon;
  // ...
}
```

**Scripts :**
```powershell
icon = @{stringValue = $category.icon}
```

### Processus de migration appliqué

**Méthode utilisée :** Migration immédiate via script

**Raisons du choix :**
- Seulement 12 documents (petit dataset)
- Application en développement (pas en production)
- Migration simple (suppression champ)
- Pas d'utilisateurs actifs

### Exécution détaillée

#### 1. Récupération de tous les documents

**API Call :**
```
GET https://firestore.googleapis.com/v1/projects/flutter-recette-october-2025-1/databases/(default)/documents/categories
```

**Réponse :**
```json
{
  "documents": [
    {
      "name": "projects/.../documents/categories/abc123",
      "fields": {
        "name": {"stringValue": "Breakfast"},
        "icon": {"stringValue": "icone"},
        "color": {"stringValue": "FFE8B4"}
      },
      "createTime": "2025-10-27T...",
      "updateTime": "2025-10-27T..."
    },
    // ... 11 autres documents
  ]
}
```

#### 2. Transformation des données

**Pour chaque document, extraction :**
```powershell
$categoryName = $doc.fields.name.stringValue    # "Breakfast"
$categoryColor = $doc.fields.color.stringValue  # "FFE8B4"
# icon est IGNORE (pas extrait)
```

**Construction du nouveau body :**
```powershell
$updateBody = @{
    fields = @{
        name = @{stringValue = "Breakfast"}
        color = @{stringValue = "FFE8B4"}
    }
}
# icon n'est PAS inclus
```

#### 3. Mise à jour via PATCH

**API Call :**
```
PATCH https://firestore.googleapis.com/v1/projects/.../documents/categories/abc123
```

**Body :**
```json
{
  "fields": {
    "name": {"stringValue": "Breakfast"},
    "color": {"stringValue": "FFE8B4"}
  }
}
```

**Comportement de PATCH :**
- Remplace COMPLÈTEMENT le document
- Seuls les champs dans le body sont conservés
- Les champs absents (icon) sont SUPPRIMÉS
- createTime est préservé
- updateTime est mis à jour

#### 4. Résultat après PATCH

**Document mis à jour :**
```json
{
  "name": "projects/.../documents/categories/abc123",
  "fields": {
    "name": {"stringValue": "Breakfast"},
    "color": {"stringValue": "FFE8B4"}
  },
  "createTime": "2025-10-27T14:30:45.123456Z",  // PRESERVE
  "updateTime": "2025-10-27T18:45:12.789012Z"   // MIS A JOUR
}
```

**Champ icon :** Complètement supprimé, n'existe plus.

### Ordre des modifications

**Ordre appliqué (correct) :**
```
1. Migrer les données dans Firestore (script)
2. Mettre à jour le modèle Dart (code)
3. Redémarrer l'application
```

**Pourquoi cet ordre ?**

Le modèle Dart avec `icon` peut toujours lire des documents sans `icon` grâce à :
```dart
icon: map['icon'] ?? '',  // Retourne '' si icon absent
```

**Ordre inverse (problématique) :**
```
1. Mettre à jour le modèle Dart (supprimer icon)
2. Migrer les données
3. Redémarrer
```

Problème : Entre 1 et 2, l'application essaie de lire des documents avec `icon`, mais le modèle ne l'accepte plus.

**Ordre idéal pour notre cas :**
Simultané (les deux en même temps) car dataset petit et pas en production.

---

## Synchronisation application-base de données

### Concept de synchronisation

**Définition :**
La synchronisation est le processus qui garantit que les données dans l'application correspondent aux données dans Firestore.

### Flux de données Firestore

```
Application Flutter
        ↓ write
Firestore Cloud
        ↓ notification (si listener)
Application Flutter (mise à jour UI)
```

#### Opérations

**1. Écriture (Write) :**
```dart
await firestore.collection('categories').doc('abc').set({
  'name': 'Breakfast',
  'color': 'FFE8B4',
});
```

Flux :
```
App → Firestore Cloud (HTTP POST/PATCH)
    → Stockage persistant
    → Retour confirmation
App reçoit confirmation
```

**2. Lecture simple (Read) :**
```dart
final doc = await firestore.collection('categories').doc('abc').get();
final data = doc.data();
```

Flux :
```
App → Firestore Cloud (HTTP GET)
    → Récupération données
    → Retour données
App affiche données
```

**3. Lecture en temps réel (Snapshot listener) :**
```dart
firestore.collection('categories').snapshots().listen((snapshot) {
  snapshot.docChanges.forEach((change) {
    if (change.type == DocumentChangeType.added) {
      // Nouveau document
    }
    if (change.type == DocumentChangeType.modified) {
      // Document modifié
    }
    if (change.type == DocumentChangeType.removed) {
      // Document supprimé
    }
  });
});
```

Flux :
```
App → Firestore Cloud (WebSocket/Long polling)
    → Connexion persistante établie
    
Quand changement dans Firestore:
    Firestore Cloud → Notification push
    App → Mise à jour UI automatique
```

### États de synchronisation

#### État 1 : Données synchronisées

```
Application affiche : "Breakfast"
Firestore contient : "Breakfast"
```

Cohérent. Aucune action requise.

#### État 2 : Désynchronisation temporaire

```
Utilisateur modifie : "Breakfast" → "Petit-déjeuner"
Application affiche : "Petit-déjeuner" (optimistic update)
Firestore contient encore : "Breakfast" (write en cours)
    ↓ 100-200ms
Firestore mis à jour : "Petit-déjeuner"
Application confirmée : "Petit-déjeuner"
```

**Optimistic update :**
L'UI est mise à jour avant la confirmation Firestore pour meilleure UX.

#### État 3 : Conflit

```
App 1 modifie : "Breakfast" à timestamp T1
App 2 modifie : "Breakfast" à timestamp T2 (T2 > T1)

Firestore reçoit les deux modifications:
T1: "Version App 1"
T2: "Version App 2" (GAGNE - last write wins)

Résultat final: "Version App 2"
App 1 doit être notifiée du changement
```

**Gestion dans Firestore :**
```dart
// Transactions pour éviter conflits
await firestore.runTransaction((transaction) async {
  final doc = await transaction.get(docRef);
  final currentName = doc.data()!['name'];
  
  // Vérifier condition
  if (currentName == expectedValue) {
    transaction.update(docRef, {'name': newValue});
  } else {
    throw Exception('Conflit détecté');
  }
});
```

### Cache et synchronisation

#### Cache local Firestore

**Par défaut, Firestore utilise un cache :**

```
Première lecture:
App → Cache (MISS) → Firestore Cloud → Cache → App

Lecture suivante:
App → Cache (HIT) → App (instantané)
```

**Configuration du cache :**
```dart
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,  // Cache activé
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

**Implications pour migrations :**

Après migration dans Firestore, le cache local peut contenir l'ancienne structure.

**Solutions :**
1. Redémarrer l'application (vide le cache)
2. Forcer une lecture serveur :
   ```dart
   doc.get(GetOptions(source: Source.server))
   ```
3. Invalider le cache spécifiquement

#### Synchronisation offline

**Firestore supporte offline :**

```
User modifie en mode offline
    ↓
Stocké localement dans cache
    ↓
Queue de pending writes
    ↓
Connexion rétablie
    ↓
Sync automatique vers Firestore
```

**Impact sur migrations :**

Si migration exécutée pendant qu'un utilisateur est offline :
- L'utilisateur a l'ancienne structure en cache
- Lors de la reconnexion, conflict potentiel
- Firestore résout automatiquement (last write wins)

**Gestion :**
```dart
firestore.collection('categories').snapshots().listen(
  (snapshot) {
    snapshot.metadata.isFromCache; // true si offline
    snapshot.metadata.hasPendingWrites; // true si writes en attente
  }
);
```

---

## Problèmes d'incompatibilité

### Type 1 : Code attend un champ supprimé

**Problème :**
```dart
// Modèle a encore icon
final icon = category.icon;

// Mais Firestore n'a plus icon après migration
```

**Erreur potentielle :**
```
NoSuchMethodError: The getter 'icon' was called on null.
```

**OU** (si valeur par défaut) :
```dart
icon: map['icon'] ?? '',  // Retourne '' au lieu de l'icône
```

**Solutions :**

**Solution A : Code défensif**
```dart
// Vérifier existence avant utilisation
if (category.icon != null && category.icon.isNotEmpty) {
  displayIcon(category.icon);
}
```

**Solution B : Valeurs par défaut**
```dart
final icon = category.icon ?? 'default_icon';
```

**Solution C : Suppression du code**
Supprimer complètement les références à icon.

### Type 2 : Nouveau champ pas rétrocompatible

**Problème :**
```dart
// Nouveau modèle
class CategoryModel {
  final String requiredField; // REQUIS, pas de défaut
}

// Anciens documents n'ont pas ce champ
```

**Erreur :**
```
Required parameter 'requiredField' must be provided.
```

**Solutions :**

**Solution A : Champ optionnel**
```dart
class CategoryModel {
  final String? requiredField; // Nullable
}
```

**Solution B : Valeur par défaut**
```dart
factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
  return CategoryModel(
    requiredField: map['requiredField'] ?? 'default_value',
  );
}
```

**Solution C : Migration préalable**
Ajouter le champ à tous les documents avant de le rendre requis.

### Type 3 : Changement de type

**Problème :**
```
Avant : color: "FFE8B4" (string)
Après : color: 0xFFFFE8B4 (integer)
```

**Code avant :**
```dart
final color = map['color']; // String
```

**Code après :**
```dart
final color = map['color']; // Integer attendu, mais string reçu
```

**Erreur :**
```
type 'String' is not a subtype of type 'int'
```

**Solution : Conversion graduelle**
```dart
factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
  final colorValue = map['color'];
  
  final int colorInt;
  if (colorValue is String) {
    // Ancien format
    colorInt = int.parse('0xFF' + colorValue, radix: 16);
  } else {
    // Nouveau format
    colorInt = colorValue as int;
  }
  
  return CategoryModel(color: colorInt);
}
```

**Migration des données :**
```javascript
// Cloud Function
exports.migrateColorFormat = functions.https.onRequest(async (req, res) => {
  const snapshot = await db.collection('categories').get();
  const batch = db.batch();
  
  snapshot.docs.forEach(doc => {
    const color = doc.data().color;
    if (typeof color === 'string') {
      const colorInt = parseInt('0xFF' + color, 16);
      batch.update(doc.ref, {color: colorInt});
    }
  });
  
  await batch.commit();
  res.send('Migration complete');
});
```

### Type 4 : Restructuration (normalisation)

**Problème :**
```
Avant (denormalisé):
{
  name: "Breakfast",
  recipeCount: 5,
  recipes: ["recipe1", "recipe2", ...]
}

Après (normalisé):
{
  name: "Breakfast",
  recipeCount: 5
}
// Recipes dans collection séparée
```

**Migration complexe :**
```javascript
// Pour chaque catégorie
const categories = await db.collection('categories').get();

for (const catDoc of categories.docs) {
  const recipes = catDoc.data().recipes || [];
  
  // Créer documents recipes
  const batch = db.batch();
  recipes.forEach(recipeId => {
    const recipeRef = db.collection('recipes').doc(recipeId);
    batch.update(recipeRef, {
      categoryId: catDoc.id
    });
  });
  
  // Supprimer champ recipes de category
  batch.update(catDoc.ref, {
    recipes: admin.firestore.FieldValue.delete()
  });
  
  await batch.commit();
}
```

---

## Synchronisation application-base de données

### Patterns de synchronisation

#### Pattern 1 : Requête à la demande (Pull)

**Code :**
```dart
Future<List<CategoryModel>> getCategories() async {
  final snapshot = await firestore.collection('categories').get();
  return snapshot.docs.map((doc) => 
    CategoryModel.fromMap(doc.id, doc.data()!)
  ).toList();
}
```

**Caractéristiques :**
- L'app demande explicitement les données
- Pas de mise à jour automatique
- Bon pour données statiques

**Synchronisation :**
- Manuelle (refresh button)
- OU périodique (Timer)

#### Pattern 2 : Écoute temps réel (Push)

**Code :**
```dart
Stream<List<CategoryModel>> categoriesStream() {
  return firestore.collection('categories').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => 
      CategoryModel.fromMap(doc.id, doc.data()!)
    ).toList();
  });
}

// Dans le widget
StreamBuilder<List<CategoryModel>>(
  stream: categoriesStream(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView(children: snapshot.data!.map(...));
    }
    return CircularProgressIndicator();
  },
)
```

**Caractéristiques :**
- Firestore notifie l'app des changements
- Mise à jour automatique de l'UI
- Bon pour données collaboratives

**Synchronisation :**
- Automatique
- Temps réel (latence ~100-500ms)

#### Pattern 3 : Hybride (utilisé dans notre app)

**Initialisation : Pull**
```dart
Future<void> initializeCategories() async {
  await InitCategories.initializeCategories();
  // Requête ponctuelle
}
```

**Affichage : Pull avec refresh**
```dart
Future<void> loadCategories() async {
  final categories = await firestoreService.getCategories();
  setState(() {
    _categories = categories;
  });
}

// Refresh manuel
onPressed: () => loadCategories(),
```

**Raison du choix :**
- Catégories changent rarement
- Pas besoin de temps réel
- Économie de bandwidth et coûts

### Gestion de l'état pendant migration

#### Avant migration

**État application :**
```dart
List<CategoryModel> _categories = [
  CategoryModel(name: "Breakfast", icon: "icone", color: "FFE8B4"),
  // ... 11 autres avec icon
];
```

**État Firestore :**
```
12 documents avec champs: name, icon, color
```

**Cohérence :** OUI

#### Pendant migration (si app tourne)

**État application (cache) :**
```
Breakfast: {name, icon, color}  // Ancien format en cache
```

**État Firestore (en cours de migration) :**
```
Dinner: {name, color}     // Déjà migré
Pizza: {name, icon, color} // Pas encore migré
```

**Cohérence :** NON - Incohérence temporaire

**Gestion :**
```dart
// Code défensif dans fromMap
factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
  return CategoryModel(
    id: id,
    name: map['name'] ?? '',
    icon: map['icon'] ?? '',  // Gère présence OU absence
    color: map['color'] ?? '',
  );
}
```

#### Après migration

**Redémarrage de l'application :**
```bash
# Arrêter
q

# Relancer
flutter run -d chrome
```

**Nouveau chargement :**
- Cache vidé
- Lecture depuis Firestore
- Tous les documents au nouveau format
- UI cohérente

**État application :**
```dart
List<CategoryModel> _categories = [
  CategoryModel(name: "Breakfast", color: "FFE8B4"),
  // ... 11 autres SANS icon
];
```

**État Firestore :**
```
12 documents avec champs: name, color (icon supprimé)
```

**Cohérence :** OUI

### Problèmes de synchronisation courants

#### Problème 1 : Stale cache

**Symptôme :**
Après migration, l'app affiche toujours les anciennes données.

**Cause :**
Cache local Firestore contient l'ancienne structure.

**Solutions :**
```dart
// Solution 1 : Redémarrer app
// Solution 2 : Forcer lecture serveur
doc.get(GetOptions(source: Source.server))

// Solution 3 : Vider cache programmatiquement
await FirebaseFirestore.instance.clearPersistence();
```

#### Problème 2 : Pending writes

**Symptôme :**
Modifications locales écrasent la migration.

**Cause :**
```
T1: User modifie offline
T2: Migration exécutée
T3: User reconnecté, pending writes envoyés
T4: Données redeviennent anciennes
```

**Solution :**
Utiliser transactions :
```dart
await firestore.runTransaction((transaction) async {
  final doc = await transaction.get(docRef);
  final currentData = doc.data()!;
  
  // Vérifier version
  if (!currentData.containsKey('schemaVersion') || 
      currentData['schemaVersion'] < 2) {
    // Rejeter ou migrer
    throw Exception('Document pas à jour');
  }
  
  transaction.update(docRef, updates);
});
```

#### Problème 3 : Snapshots multiples

**Symptôme :**
Plusieurs listeners reçoivent notifications dupliquées.

**Cause :**
```dart
// Listener 1
categoriesStream().listen(...)

// Listener 2
categoriesStream().listen(...)

// Chaque changement notifie les DEUX
```

**Solution :**
```dart
// Utiliser StreamBuilder unique
StreamBuilder<List<CategoryModel>>(
  stream: categoriesStream(),
  // Un seul stream, partagé
)

// OU gérer subscription
StreamSubscription? _subscription;

@override
void initState() {
  _subscription = categoriesStream().listen(...);
}

@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

---

## Meilleures pratiques

### 1. Toujours gérer l'absence de champs

**Code défensif :**
```dart
factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
  return CategoryModel(
    id: id,
    name: map['name'] ?? 'Sans nom',        // Valeur par défaut
    color: map['color'] ?? 'FFFFFF',        // Blanc par défaut
    description: map['description'],        // Nullable (String?)
  );
}
```

**Vérification explicite :**
```dart
if (map.containsKey('icon')) {
  // Traiter icon
} else {
  // Gérer absence
}
```

### 2. Versionner les schémas

**Ajout champ version :**
```json
{
  "schemaVersion": 2,
  "name": "Breakfast",
  "color": "FFE8B4"
}
```

**Code :**
```dart
factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
  final version = map['schemaVersion'] ?? 1;
  
  switch (version) {
    case 1:
      return CategoryModel.fromV1(id, map);
    case 2:
      return CategoryModel.fromV2(id, map);
    default:
      throw UnsupportedSchemaVersionException(version);
  }
}
```

### 3. Tester les migrations

**Test avec données anciennes :**
```dart
test('CategoryModel handles old format without icon', () {
  final oldFormat = {
    'name': 'Test',
    'icon': 'icone',  // Ancien champ
    'color': 'FF0000',
  };
  
  final category = CategoryModel.fromMap('123', oldFormat);
  
  expect(category.name, 'Test');
  expect(category.color, 'FF0000');
  // icon ignoré
});

test('CategoryModel handles new format', () {
  final newFormat = {
    'name': 'Test',
    'color': 'FF0000',
    // Pas de icon
  };
  
  final category = CategoryModel.fromMap('123', newFormat);
  
  expect(category.name, 'Test');
  expect(category.color, 'FF0000');
});
```

### 4. Documenter les migrations

**Fichier de migration :**
```dart
// lib/migrations/category_migrations.dart

/// Migration 001: Suppression du champ icon
/// Date: 2025-10-27
/// Raison: Simplification du modèle
/// 
/// Changements:
/// - Supprimé: icon (String)
/// - Conservé: name, color
/// 
/// Script: scripts/remove_icons_from_categories.ps1
/// Exécuté: 2025-10-27 18:45
/// Documents migrés: 12
class Migration001_RemoveIcon {
  static const version = 1;
  static const description = 'Remove icon field from categories';
  
  static Future<void> migrate(FirebaseFirestore firestore) async {
    // Code de migration si besoin de ré-exécuter
  }
}
```

### 5. Sauvegarder avant migration

**Export Firestore :**
```bash
# Via gcloud (nécessite Cloud Storage)
gcloud firestore export gs://my-bucket/backup-2025-10-27

# Restauration si problème
gcloud firestore import gs://my-bucket/backup-2025-10-27
```

**Export manuel (petit dataset) :**
```dart
Future<void> exportCategories() async {
  final snapshot = await firestore.collection('categories').get();
  final data = snapshot.docs.map((doc) => {
    'id': doc.id,
    'data': doc.data(),
  }).toList();
  
  final json = jsonEncode(data);
  // Sauvegarder dans fichier
  await File('backup_categories.json').writeAsString(json);
}
```

---

## Migrations complexes

### Migration 1 : Renommer un champ

**Objectif :**
Renommer `color` en `colorCode`

**Approche :**
```dart
// Étape 1 : Code gère les deux noms
factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
  return CategoryModel(
    color: map['colorCode'] ?? map['color'] ?? 'FFFFFF',
  );
}

// Étape 2 : Migration script
final docs = await collection.get();
for (var doc in docs.docs) {
  await doc.reference.update({
    'colorCode': doc.data()['color'],
    'color': FieldValue.delete(),
  });
}

// Étape 3 : Simplifier code après migration
factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
  return CategoryModel(
    color: map['colorCode'] ?? 'FFFFFF',
  );
}
```

### Migration 2 : Normalisation (split)

**Objectif :**
Séparer informations catégorie et statistiques

**Avant :**
```json
{
  "name": "Breakfast",
  "color": "FFE8B4",
  "recipeCount": 25,
  "lastUpdated": "2025-10-27",
  "popularRecipes": ["id1", "id2"]
}
```

**Après :**
```
Collection: categories
{
  "name": "Breakfast",
  "color": "FFE8B4"
}

Collection: category_stats
{
  "categoryId": "breakfast_id",
  "recipeCount": 25,
  "lastUpdated": "2025-10-27",
  "popularRecipes": ["id1", "id2"]
}
```

**Script de migration :**
```dart
Future<void> normalizeCategories() async {
  final categories = await firestore.collection('categories').get();
  
  for (var doc in categories.docs) {
    final data = doc.data();
    
    // Créer document stats
    await firestore.collection('category_stats').doc(doc.id).set({
      'categoryId': doc.id,
      'recipeCount': data['recipeCount'] ?? 0,
      'lastUpdated': data['lastUpdated'],
      'popularRecipes': data['popularRecipes'] ?? [],
    });
    
    // Nettoyer category
    await doc.reference.update({
      'recipeCount': FieldValue.delete(),
      'lastUpdated': FieldValue.delete(),
      'popularRecipes': FieldValue.delete(),
    });
  }
}
```

### Migration 3 : Dénormalisation (merge)

**Objectif :**
Combiner données de plusieurs collections pour performance

**Avant :**
```
Collection: categories
{
  "name": "Breakfast",
  "color": "FFE8B4"
}

Collection: category_meta
{
  "categoryId": "breakfast_id",
  "description": "Morning meals"
}
```

**Après :**
```
Collection: categories
{
  "name": "Breakfast",
  "color": "FFE8B4",
  "description": "Morning meals"
}
```

**Script :**
```dart
Future<void> denormalizeCategories() async {
  final categories = await firestore.collection('categories').get();
  
  for (var doc in categories.docs) {
    final meta = await firestore
      .collection('category_meta')
      .where('categoryId', isEqualTo: doc.id)
      .get();
    
    if (meta.docs.isNotEmpty) {
      await doc.reference.update({
        'description': meta.docs.first.data()['description'],
      });
      
      // Optionnel: Supprimer category_meta
      await meta.docs.first.reference.delete();
    }
  }
}
```

---

## Monitoring et validation

### Vérifier progression migration

**Script avec compteur :**
```dart
Future<void> migratewithProgress() async {
  final snapshot = await firestore.collection('categories').get();
  final total = snapshot.docs.length;
  var migrated = 0;
  
  for (var doc in snapshot.docs) {
    await migrateDocument(doc);
    migrated++;
    print('Progress: $migrated/$total (${(migrated/total*100).toStringAsFixed(1)}%)');
  }
  
  print('Migration complete: $migrated documents');
}
```

### Validation post-migration

**Vérification structure :**
```dart
Future<void> validateMigration() async {
  final snapshot = await firestore.collection('categories').get();
  var valid = 0;
  var invalid = 0;
  
  for (var doc in snapshot.docs) {
    final data = doc.data();
    
    // Vérifier nouvelle structure
    if (data.containsKey('name') && 
        data.containsKey('color') && 
        !data.containsKey('icon')) {
      valid++;
    } else {
      invalid++;
      print('Document invalide: ${doc.id}');
      print('  Champs: ${data.keys.join(', ')}');
    }
  }
  
  print('Validation: $valid valid, $invalid invalid');
  if (invalid > 0) {
    throw Exception('Migration incomplète');
  }
}
```

### Rollback

**Si migration échoue :**

**Avec backup :**
```bash
# Restaurer depuis export
gcloud firestore import gs://bucket/backup-2025-10-27
```

**Sans backup (si modification simple) :**
```dart
// Ré-ajouter champ icon avec valeur par défaut
final docs = await firestore.collection('categories').get();
for (var doc in docs.docs) {
  await doc.reference.update({
    'icon': 'default_icon',
  });
}
```

---

## Conclusion

### Points clés à retenir

1. **Firestore est schema-less**
   - Flexibilité totale
   - Responsabilité de cohérence sur développeur

2. **Migrations sont programmatiques**
   - Pas de commande ALTER
   - Scripts personnalisés
   - Document par document

3. **Code doit être défensif**
   - Vérifier existence des champs
   - Valeurs par défaut
   - Gestion des erreurs

4. **Plusieurs stratégies disponibles**
   - Immédiate (notre cas)
   - Progressive
   - Par version
   - Double écriture

5. **Synchronisation est critique**
   - Cache peut être obsolète
   - Redémarrage après migration
   - Tests de validation

### Notre migration en résumé

**Ce que nous avons fait :**
- Migration immédiate via script PowerShell
- 12 documents migrés en 5 secondes
- Champ "icon" supprimé complètement
- Code Dart peut être mis à jour (pas encore fait)
- Application compatible (grâce à valeurs par défaut)

**Pourquoi ça a fonctionné :**
- Petit dataset
- Code défensif (`?? ''`)
- Pas en production
- Script testé et validé

**Prochaines étapes recommandées :**
1. Mettre à jour category_model.dart (supprimer icon)
2. Mettre à jour init_categories.dart (supprimer icon)
3. Tester l'application
4. Commit des changements

---

**Fin du cours pédagogique**

