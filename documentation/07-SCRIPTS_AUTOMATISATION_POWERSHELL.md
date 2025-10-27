# Documentation Technique - Scripts d'Automatisation PowerShell

## Informations du document

**Date de création :** 27 octobre 2025  
**Projet :** flutter-recette-october-2025-1  
**Version :** 1.0  
**Auteur :** Documentation technique du projet

---

## Table des matières

1. [Introduction](#introduction)
2. [Script add_categories_gcloud.ps1](#script-add_categories_gcloudps1)
3. [Script remove_icons_from_categories.ps1](#script-remove_icons_from_categoriesps1)
4. [Script import_to_firestore.ps1](#script-import_to_firestoreps1)
5. [Fichier de données categories_import.json](#fichier-de-données-categories_importjson)
6. [API REST Firestore](#api-rest-firestore)
7. [Authentification et sécurité](#authentification-et-sécurité)
8. [Gestion des erreurs](#gestion-des-erreurs)
9. [Performance et optimisation](#performance-et-optimisation)

---

## Introduction

### Contexte

Après l'implémentation de l'interface d'administration Flutter, il est apparu nécessaire de créer des scripts autonomes permettant l'initialisation des catégories depuis la ligne de commande, indépendamment de l'application Flutter.

### Avantages des scripts PowerShell

1. **Automatisation CI/CD**
   - Exécutable dans les pipelines de déploiement
   - Pas besoin de lancer l'application

2. **Reproductibilité**
   - Initialisation rapide de nouveaux environnements
   - Dev, Staging, Production

3. **Maintenance**
   - Modification en masse des données
   - Opérations de nettoyage

4. **Indépendance**
   - Pas de dépendance à l'application Flutter
   - Utilisable par les administrateurs système

---

## Script add_categories_gcloud.ps1

### Emplacement

`scripts/add_categories_gcloud.ps1`

### Prérequis

1. Google Cloud SDK installé
2. Authentification gcloud effectuée
3. Projet configuré dans gcloud
4. Base de données Firestore créée
5. Connexion Internet active

### Code complet commenté

```powershell
# Script pour ajouter les catégories via gcloud et API REST Firestore
# Exécutez ce script dans un terminal PowerShell EXTERNE (pas VS Code)

# Configuration
$projectId = "flutter-recette-october-2025-1"

# Affichage de l'en-tête
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Ajout des catégories dans Firestore" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que gcloud est disponible
try {
    # Capture de la version de gcloud
    $gcloudVersion = gcloud --version 2>&1 | Select-String "Google Cloud SDK"
    Write-Host "✅ gcloud trouvé: $gcloudVersion" -ForegroundColor Green
} catch {
    # Erreur si gcloud n'est pas installé ou pas dans PATH
    Write-Host "❌ gcloud n'est pas installé ou pas dans le PATH" -ForegroundColor Red
    Write-Host "Installez-le avec: winget install Google.CloudSDK" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🔐 Authentification..." -ForegroundColor Yellow

# Obtenir le token d'accès OAuth2
try {
    # Commande gcloud pour obtenir le token
    $token = gcloud auth print-access-token 2>&1
    
    # Vérifier le code de sortie
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur d'authentification" -ForegroundColor Red
        Write-Host "Exécutez d'abord: gcloud auth login" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✅ Token obtenu" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de l'obtention du token" -ForegroundColor Red
    Write-Host "Exécutez d'abord: gcloud auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "📝 Ajout des 12 catégories..." -ForegroundColor Yellow
Write-Host ""

# Définir les catégories (après suppression des icônes)
$categories = @(
    @{name="Breakfast"; color="FFE8B4"},
    @{name="Lunch"; color="FFC4E1"},
    @{name="Dinner"; color="C4E1FF"},
    @{name="Desserts"; color="FFD4D4"},
    @{name="Appetizers"; color="D4FFD4"},
    @{name="Soups"; color="FFE4C4"},
    @{name="Beverages"; color="E4C4FF"},
    @{name="Snacks"; color="FFFACD"},
    @{name="Vegetarian"; color="C8E6C9"},
    @{name="Seafood"; color="B3E5FC"},
    @{name="Pasta"; color="FFCCBC"},
    @{name="Pizza"; color="FFE0B2"}
)

# URL de l'API REST Firestore
$url = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/categories"

# Headers HTTP pour l'authentification
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Compteur pour l'affichage
$count = 0

# Boucle d'ajout des catégories
foreach ($category in $categories) {
    $count++
    
    # Construction du body JSON selon le format Firestore API
    $body = @{
        fields = @{
            name = @{stringValue = $category.name}
            color = @{stringValue = $category.color}
        }
    } | ConvertTo-Json -Depth 10
    
    # Tentative d'ajout
    try {
        # POST request vers l'API Firestore
        $response = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body -ErrorAction Stop
        Write-Host "   $count. ✅ $($category.name) ajouté" -ForegroundColor Green
    } catch {
        # Affichage de l'erreur sans arrêter le script
        Write-Host "   $count. ❌ Erreur pour $($category.name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Affichage final
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ TERMINÉ!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Vérifiez dans Firebase Console:" -ForegroundColor Yellow
Write-Host "https://console.firebase.google.com/project/$projectId/firestore" -ForegroundColor Cyan
Write-Host ""
```

### Détails techniques

#### Format du body JSON

**Structure requise par l'API Firestore :**

```json
{
  "fields": {
    "name": {
      "stringValue": "Breakfast"
    },
    "color": {
      "stringValue": "FFE8B4"
    }
  }
}
```

**Explications :**
- `fields` : Objet contenant tous les champs du document
- Chaque champ a un type explicite : `stringValue`, `integerValue`, `booleanValue`, etc.
- Pas de `documentId` : Firestore le génère automatiquement

#### Méthode HTTP POST

**Endpoint :**
```
POST https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/{collectionId}
```

**Headers requis :**
- `Authorization: Bearer {token}` : Authentification OAuth2
- `Content-Type: application/json` : Format du body

**Réponse :**
```json
{
  "name": "projects/{projectId}/databases/(default)/documents/categories/{docId}",
  "fields": { ... },
  "createTime": "...",
  "updateTime": "..."
}
```

#### Gestion du token OAuth2

**Obtention :**
```powershell
$token = gcloud auth print-access-token
```

**Caractéristiques :**
- Validité : 1 heure
- Renouvellement automatique par gcloud
- Format : JWT (JSON Web Token)

**Utilisation :**
```powershell
$headers = @{
    "Authorization" = "Bearer $token"
}
```

#### ConvertTo-Json avec -Depth 10

**Pourquoi -Depth 10 ?**

Par défaut, `ConvertTo-Json` limite la profondeur à 2 niveaux. Avec notre structure imbriquée :
```
@{
  fields = @{
    name = @{stringValue = "..."}
  }
}
```

Nous avons 3 niveaux d'imbrication. `-Depth 10` assure la conversion complète.

---

## Script remove_icons_from_categories.ps1

### Emplacement

`scripts/remove_icons_from_categories.ps1`

### Objectif

Supprimer le champ "icon" de toutes les catégories existantes dans Firestore sans recréer les documents.

### Prérequis

Identiques à add_categories_gcloud.ps1 plus :
- Au moins une catégorie doit exister dans Firestore

### Code complet commenté

```powershell
# Script pour supprimer le champ "icon" des catégories existantes dans Firestore

# Configuration
$projectId = "flutter-recette-october-2025-1"

# En-tête
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Suppression des icônes des catégories" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Obtenir le token d'accès
try {
    $token = gcloud auth print-access-token 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur d'authentification" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Token obtenu" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de l'obtention du token" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📝 Récupération des catégories..." -ForegroundColor Yellow

# URL pour lister les documents
$listUrl = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/categories"

# Headers pour GET
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    # GET request pour récupérer tous les documents
    $response = Invoke-RestMethod -Method Get -Uri $listUrl -Headers $headers
    $documents = $response.documents
    
    Write-Host "✅ $($documents.Count) catégories trouvées" -ForegroundColor Green
    Write-Host ""
    Write-Host "🗑️  Suppression des icônes..." -ForegroundColor Yellow
    Write-Host ""
    
    $count = 0
    
    # Boucle sur chaque document
    foreach ($doc in $documents) {
        $count++
        
        # Récupérer le nom complet du document (path)
        $docName = $doc.name
        
        # Récupérer le nom de la catégorie pour l'affichage
        $categoryName = $doc.fields.name.stringValue
        
        # Créer le body sans le champ icon
        $updateBody = @{
            fields = @{
                name = @{stringValue = $doc.fields.name.stringValue}
                color = @{stringValue = $doc.fields.color.stringValue}
            }
        } | ConvertTo-Json -Depth 10
        
        # Headers pour PATCH
        $updateHeaders = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        
        try {
            # PATCH request pour remplacer le document
            Invoke-RestMethod -Method Patch -Uri "https://firestore.googleapis.com/v1/$docName" -Headers $updateHeaders -Body $updateBody | Out-Null
            Write-Host "   $count. ✅ $categoryName - icône supprimée" -ForegroundColor Green
        } catch {
            Write-Host "   $count. ❌ Erreur pour $categoryName" -ForegroundColor Red
        }
    }
    
    # Affichage final
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "✅ TERMINÉ!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

### Détails techniques

#### Méthode GET pour lister les documents

**Endpoint :**
```
GET https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/{collectionId}
```

**Réponse :**
```json
{
  "documents": [
    {
      "name": "projects/{projectId}/databases/(default)/documents/categories/{docId}",
      "fields": {
        "name": {"stringValue": "Breakfast"},
        "icon": {"stringValue": "🍳"},
        "color": {"stringValue": "FFE8B4"}
      },
      "createTime": "...",
      "updateTime": "..."
    },
    // ... autres documents
  ]
}
```

#### Méthode PATCH pour mettre à jour

**Endpoint :**
```
PATCH https://firestore.googleapis.com/v1/{documentPath}
```

**documentPath exemple :**
```
projects/flutter-recette-october-2025-1/databases/(default)/documents/categories/abc123
```

**Body :**
Le body contient UNIQUEMENT les champs à conserver. Les champs absents sont supprimés.

```json
{
  "fields": {
    "name": {"stringValue": "Breakfast"},
    "color": {"stringValue": "FFE8B4"}
  }
}
```

**Différence avec PUT :**
- PUT : Remplace tout le document
- PATCH : Mise à jour partielle (mais ici on remplace complètement)

#### Extraction des valeurs

**PowerShell :**
```powershell
# Récupérer le nom du document
$docName = $doc.name

# Récupérer les valeurs des champs
$categoryName = $doc.fields.name.stringValue
$categoryColor = $doc.fields.color.stringValue
```

**Structure de l'objet $doc :**
```
$doc
├── name (string)
├── fields (object)
│   ├── name (object)
│   │   └── stringValue (string)
│   ├── icon (object)
│   │   └── stringValue (string)
│   └── color (object)
│       └── stringValue (string)
├── createTime (string)
└── updateTime (string)
```

---

## Script import_to_firestore.ps1

### Emplacement

`scripts/import_to_firestore.ps1`

### Objectif

Script informatif expliquant les limitations de Firebase CLI pour l'import de données et suggérant des alternatives.

### Code complet

```powershell
# Script PowerShell pour importer les catégories dans Firestore
# Utilise Firebase Emulator pour les données

Write-Host "🔧 Import des catégories dans Firestore" -ForegroundColor Green
Write-Host ""

$projectId = "flutter-recette-october-2025-1"
$collection = "categories"

# Lire le fichier JSON
$jsonData = Get-Content "scripts\categories_import.json" -Raw | ConvertFrom-Json

Write-Host "📝 Données chargées depuis categories_import.json" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Firebase CLI est disponible
try {
    $firebaseVersion = firebase --version
    Write-Host "✅ Firebase CLI trouvé: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Firebase CLI n'est pas installé" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "⚠️  IMPORTANT: Cette méthode nécessite l'import via l'émulateur" -ForegroundColor Yellow
Write-Host ""
Write-Host "Solutions alternatives:" -ForegroundColor Cyan
Write-Host "1. Utiliser l'application Flutter (Settings > Administration > Initialiser)" -ForegroundColor White
Write-Host "2. Créer manuellement 1 catégorie pour débloquer Firestore" -ForegroundColor White
Write-Host "3. Installer Google Cloud SDK avec: winget install Google.CloudSDK" -ForegroundColor White
Write-Host ""
Write-Host "Recommandation: Utilisez l'application Flutter - c'est la solution la plus simple!" -ForegroundColor Yellow
```

### Limitations Firebase CLI

**Firebase CLI ne permet pas :**
- Import direct de données dans Firestore production
- Seul l'émulateur peut être utilisé pour import/export

**Commandes Firebase CLI disponibles :**
```bash
# Export (nécessite gcloud)
firebase firestore:export gs://bucket-name

# Import (nécessite gcloud)
firebase firestore:import gs://bucket-name

# Ces commandes utilisent Google Cloud Storage
```

---

## Fichier de données categories_import.json

### Emplacement

`scripts/categories_import.json`

### Format

```json
{
  "categories": {
    "category_1": {
      "name": "Breakfast",
      "color": "FFE8B4"
    },
    "category_2": {
      "name": "Lunch",
      "color": "FFC4E1"
    },
    "category_3": {
      "name": "Dinner",
      "color": "C4E1FF"
    },
    "category_4": {
      "name": "Desserts",
      "color": "FFD4D4"
    },
    "category_5": {
      "name": "Appetizers",
      "color": "D4FFD4"
    },
    "category_6": {
      "name": "Soups",
      "color": "FFE4C4"
    },
    "category_7": {
      "name": "Beverages",
      "color": "E4C4FF"
    },
    "category_8": {
      "name": "Snacks",
      "color": "FFFACD"
    },
    "category_9": {
      "name": "Vegetarian",
      "color": "C8E6C9"
    },
    "category_10": {
      "name": "Seafood",
      "color": "B3E5FC"
    },
    "category_11": {
      "name": "Pasta",
      "color": "FFCCBC"
    },
    "category_12": {
      "name": "Pizza",
      "color": "FFE0B2"
    }
  }
}
```

### Utilisation

**Chargement dans PowerShell :**
```powershell
$jsonData = Get-Content "scripts\categories_import.json" -Raw | ConvertFrom-Json
```

**Accès aux données :**
```powershell
# Accéder à une catégorie
$breakfast = $jsonData.categories.category_1
$name = $breakfast.name
$color = $breakfast.color
```

**Conversion pour API Firestore :**
```powershell
foreach ($key in $jsonData.categories.PSObject.Properties.Name) {
    $category = $jsonData.categories.$key
    
    $body = @{
        fields = @{
            name = @{stringValue = $category.name}
            color = @{stringValue = $category.color}
        }
    } | ConvertTo-Json -Depth 10
}
```

---

## API REST Firestore

### Documentation officielle

https://firebase.google.com/docs/firestore/use-rest-api

### Endpoints principaux

#### 1. Créer un document

**Méthode :** POST  
**URL :** `https://firestore.googleapis.com/v1/projects/{projectId}/databases/{databaseId}/documents/{collectionId}`

**Paramètres :**
- `projectId` : ID du projet Firebase
- `databaseId` : Généralement `(default)`
- `collectionId` : Nom de la collection

**Body :**
```json
{
  "fields": {
    "fieldName": {"stringValue": "value"}
  }
}
```

**Document ID :**
- Non spécifié : Généré automatiquement
- Spécifié : Ajouté comme query parameter `?documentId=custom-id`

#### 2. Lire un document

**Méthode :** GET  
**URL :** `https://firestore.googleapis.com/v1/{documentPath}`

**Exemple :**
```
GET https://firestore.googleapis.com/v1/projects/my-project/databases/(default)/documents/categories/abc123
```

#### 3. Lister les documents d'une collection

**Méthode :** GET  
**URL :** `https://firestore.googleapis.com/v1/projects/{projectId}/databases/{databaseId}/documents/{collectionId}`

**Query parameters :**
- `pageSize` : Nombre de documents par page (max 300)
- `pageToken` : Token pour la pagination
- `orderBy` : Champ de tri

#### 4. Mettre à jour un document

**Méthode :** PATCH  
**URL :** `https://firestore.googleapis.com/v1/{documentPath}`

**Query parameters :**
- `updateMask.fieldPaths` : Champs à mettre à jour

**Comportement :**
- Sans updateMask : Remplace tout le document
- Avec updateMask : Mise à jour partielle

#### 5. Supprimer un document

**Méthode :** DELETE  
**URL :** `https://firestore.googleapis.com/v1/{documentPath}`

**Réponse :**
- 200 OK : Document supprimé
- 404 Not Found : Document inexistant

### Types de valeurs Firestore

| Type Firestore | Clé JSON | Exemple |
|----------------|----------|---------|
| String | stringValue | `{"stringValue": "Hello"}` |
| Integer | integerValue | `{"integerValue": "42"}` |
| Double | doubleValue | `{"doubleValue": 3.14}` |
| Boolean | booleanValue | `{"booleanValue": true}` |
| Timestamp | timestampValue | `{"timestampValue": "2025-10-27T..."}` |
| Array | arrayValue | `{"arrayValue": {"values": [...]}}` |
| Map | mapValue | `{"mapValue": {"fields": {...}}}` |
| Null | nullValue | `{"nullValue": null}` |
| Reference | referenceValue | `{"referenceValue": "projects/..."}` |

### Gestion de la pagination

**Pour collections avec beaucoup de documents :**

```powershell
$pageToken = $null
$allDocuments = @()

do {
    $url = "$baseUrl?pageSize=100"
    if ($pageToken) {
        $url += "&pageToken=$pageToken"
    }
    
    $response = Invoke-RestMethod -Uri $url -Headers $headers
    $allDocuments += $response.documents
    $pageToken = $response.nextPageToken
} while ($pageToken)
```

---

## Authentification et sécurité

### OAuth2 avec Google Cloud

#### Flux d'authentification

```
1. Utilisateur : gcloud auth login
2. Navigateur s'ouvre
3. Connexion avec compte Google
4. Autorisation des scopes
5. Token stocké localement par gcloud
6. Token réutilisable pendant 1 heure
```

#### Scopes requis

Pour Firestore, les scopes suivants sont nécessaires :
```
https://www.googleapis.com/auth/datastore
https://www.googleapis.com/auth/cloud-platform
```

Automatiquement inclus avec `gcloud auth login`.

#### Stockage du token

**Emplacement local :**
```
%APPDATA%\gcloud\credentials.db
```

**Sécurité :**
- Token chiffré sur le disque
- Accès limité à l'utilisateur local
- Expiration automatique après 1 heure

#### Révocation

```bash
# Révoquer l'authentification
gcloud auth revoke

# Révoquer un compte spécifique
gcloud auth revoke user@example.com
```

### Considérations de sécurité

#### 1. Token dans les scripts

**Ne jamais :**
- Hard-coder un token
- Commiter un token dans Git
- Partager un token

**Toujours :**
- Utiliser `gcloud auth print-access-token`
- Générer à la demande
- Laisser expirer naturellement

#### 2. Règles Firestore en production

**Configuration actuelle (DANGEREUX) :**
```javascript
allow read, write: if true;
```

**Configuration recommandée :**
```javascript
match /categories/{category} {
  allow read: if true;
  allow write: if request.auth != null && 
                 request.auth.token.admin == true;
}
```

#### 3. Validation des entrées

Même avec des scripts automatisés, valider :
- Format des couleurs (6 caractères hex)
- Unicité des noms
- Longueur des chaînes

---

## Gestion des erreurs

### Types d'erreurs rencontrées

#### 1. Erreur 404 Not Found

**Causes possibles :**
- Base de données Firestore inexistante
- Nom de projet incorrect
- Collection inexistante (pour GET)

**Solution :**
```powershell
# Vérifier le projet
gcloud config get-value project

# Vérifier les bases de données
gcloud firestore databases list
```

#### 2. Erreur 403 Forbidden

**Causes possibles :**
- Règles Firestore restrictives
- Token expiré ou invalide
- Permissions insuffisantes

**Solution :**
```powershell
# Régénérer le token
gcloud auth login

# Vérifier les règles
firebase firestore:rules get
```

#### 3. Erreur 401 Unauthorized

**Causes possibles :**
- Pas de token fourni
- Token mal formaté
- Authentification expirée

**Solution :**
```powershell
# Vérifier l'authentification
gcloud auth list

# Se reconnecter
gcloud auth login
```

#### 4. Erreur 400 Bad Request

**Causes possibles :**
- Format JSON invalide
- Type de valeur incorrect
- Champ requis manquant

**Solution :**
```powershell
# Valider le JSON avant envoi
$body | ConvertTo-Json -Depth 10 | Write-Host

# Vérifier la structure
$body.fields.name.stringValue
```

### Pattern de gestion d'erreur

```powershell
try {
    # Opération risquée
    $response = Invoke-RestMethod ...
    
    # Succès
    Write-Host "✅ Succès" -ForegroundColor Green
    
} catch {
    # Capture de l'erreur
    $errorMessage = $_.Exception.Message
    $statusCode = $_.Exception.Response.StatusCode.value__
    
    # Affichage détaillé
    Write-Host "❌ Erreur HTTP $statusCode" -ForegroundColor Red
    Write-Host "   Message: $errorMessage" -ForegroundColor Red
    
    # Continuer ou arrêter selon le contexte
    # exit 1  # Arrêter
    # continue  # Passer au suivant
}
```

### Logging avancé

```powershell
# Activer le verbose
$VerbosePreference = "Continue"

# Log dans un fichier
$logFile = "logs\import_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Start-Transcript -Path $logFile

# ... script ...

Stop-Transcript
```

---

## Performance et optimisation

### Batch vs Loop

#### Approche actuelle : Loop

```powershell
foreach ($category in $categories) {
    Invoke-RestMethod -Method Post ...
}
```

**Caractéristiques :**
- Une requête HTTP par catégorie
- 12 requêtes réseau pour 12 catégories
- Temps total : ~3-5 secondes

#### Alternative : Batch Write

**API Firestore Batch :**
```
POST https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents:batchWrite
```

**Body :**
```json
{
  "writes": [
    {
      "update": {
        "name": "projects/.../documents/categories/doc1",
        "fields": {...}
      }
    },
    {
      "update": {
        "name": "projects/.../documents/categories/doc2",
        "fields": {...}
      }
    }
  ]
}
```

**Avantages :**
- Une seule requête HTTP
- Atomique (tout ou rien)
- Plus rapide pour grandes quantités

**Limites :**
- Maximum 500 opérations par batch

### Optimisation PowerShell

#### Parallel Processing

**PowerShell 7+ :**
```powershell
$categories | ForEach-Object -Parallel {
    $category = $_
    # Invoke-RestMethod ...
} -ThrottleLimit 5
```

**Gains :**
- Requêtes parallèles
- Temps total divisé par le ThrottleLimit

**Attention :**
- Limite de rate limiting Firestore
- Complexité de gestion d'erreur

#### Réutilisation de connexion HTTP

```powershell
# Créer une session web
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Réutiliser pour toutes les requêtes
Invoke-RestMethod -Uri $url -WebSession $session
```

**Gains :**
- Réutilisation de la connexion TCP
- Économie de handshakes SSL/TLS

---

## Comparaison des méthodes d'initialisation

### Méthode 1 : Application Flutter

**Fichier :** `lib/Services/init_categories.dart`

**Avantages :**
- Interface graphique
- Feedback visuel
- Validation côté client
- Gestion des doublons automatique

**Inconvénients :**
- Nécessite l'application lancée
- Pas scriptable dans CI/CD
- Dépend de l'UI

**Temps d'exécution :** ~2-3 secondes

### Méthode 2 : Script PowerShell

**Fichier :** `scripts/add_categories_gcloud.ps1`

**Avantages :**
- Automatisable
- Utilisable en CI/CD
- Pas besoin de l'application
- Scriptable et versionnable

**Inconvénients :**
- Nécessite gcloud SDK
- Configuration initiale requise
- Pas d'interface graphique

**Temps d'exécution :** ~3-5 secondes

### Méthode 3 : Firebase Console (manuelle)

**Interface :** Web

**Avantages :**
- Pas de code requis
- Contrôle total
- Visual direct
- Modification facile

**Inconvénients :**
- Temps important (15-20 min)
- Risque d'erreurs
- Non reproductible
- Pas automatisable

**Temps d'exécution :** 15-20 minutes

### Tableau comparatif

| Critère | Flutter App | PowerShell | Console |
|---------|-------------|------------|---------|
| Temps | 2-3 sec | 3-5 sec | 15-20 min |
| Setup initial | Aucun | gcloud | Aucun |
| Automatisation | Non | Oui | Non |
| Interface | Graphique | Ligne cmd | Web |
| Reproductibilité | Moyenne | Excellente | Faible |
| Maintenance | Code | Script | Manuel |
| CI/CD | Non | Oui | Non |
| Validation | Intégrée | Basique | Manuelle |
| Idéal pour | Utilisateur | DevOps | Admin ponctuel |

---

## Commandes de référence complète

### Google Cloud SDK

```powershell
# Installation
winget install Google.CloudSDK

# Version
gcloud --version

# Authentification
gcloud auth login
gcloud auth list
gcloud auth revoke

# Configuration
gcloud config set project PROJECT_ID
gcloud config get-value project
gcloud config list

# Firestore
gcloud firestore databases list
gcloud firestore databases create --location=LOCATION
gcloud firestore databases describe (default)

# Token
gcloud auth print-access-token

# Aide
gcloud firestore --help
gcloud firestore databases --help
```

### Firebase CLI

```bash
# Installation (Node.js requis)
npm install -g firebase-tools

# Login
firebase login

# Projets
firebase projects:list
firebase use PROJECT_ID

# Firestore
firebase deploy --only firestore
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes

# Configuration
firebase init firestore
```

### PowerShell

```powershell
# Navigation
cd C:\projetsFirebase\projetrecette

# Exécution de script
.\scripts\add_categories_gcloud.ps1

# Avec paramètres
.\script.ps1 -ProjectId "mon-projet"

# Liste des fichiers
Get-ChildItem scripts\

# Lecture de JSON
Get-Content file.json | ConvertFrom-Json

# Requête HTTP
Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body

# Variables d'environnement
$env:Path
$env:GOOGLE_APPLICATION_CREDENTIALS
```

---

## Annexes

### Codes d'erreur HTTP courants

| Code | Nom | Signification | Action |
|------|-----|---------------|--------|
| 200 | OK | Succès | Continuer |
| 400 | Bad Request | Requête malformée | Vérifier JSON |
| 401 | Unauthorized | Non authentifié | Authentifier |
| 403 | Forbidden | Pas de permission | Vérifier règles |
| 404 | Not Found | Ressource inexistante | Créer ressource |
| 409 | Conflict | Conflit (doublon) | Gérer conflit |
| 429 | Too Many Requests | Rate limit | Attendre/Retry |
| 500 | Internal Server Error | Erreur serveur | Réessayer |
| 503 | Service Unavailable | Service indisponible | Attendre |

### Format des couleurs

**Validation hexadécimale :**
```powershell
function Test-HexColor {
    param([string]$color)
    return $color -match '^[0-9A-Fa-f]{6}$'
}

# Utilisation
if (Test-HexColor "FFE8B4") {
    # Valide
}
```

### Exemple de réponse API complète

**POST Successful :**
```json
{
  "name": "projects/flutter-recette-october-2025-1/databases/(default)/documents/categories/K4LmN9oP2qR",
  "fields": {
    "name": {
      "stringValue": "Breakfast"
    },
    "color": {
      "stringValue": "FFE8B4"
    }
  },
  "createTime": "2025-10-27T14:30:45.123456Z",
  "updateTime": "2025-10-27T14:30:45.123456Z"
}
```

**GET Collection :**
```json
{
  "documents": [
    {
      "name": "projects/.../documents/categories/doc1",
      "fields": {...},
      "createTime": "...",
      "updateTime": "..."
    }
  ],
  "nextPageToken": "token_if_more_results"
}
```

---

## Checklist de déploiement

### Avant d'exécuter les scripts

- [ ] Google Cloud SDK installé
- [ ] gcloud auth login effectué
- [ ] Projet configuré (gcloud config set project)
- [ ] Base de données Firestore créée
- [ ] Règles Firestore configurées et déployées
- [ ] Connexion Internet active
- [ ] PowerShell avec droits suffisants

### Après exécution

- [ ] Toutes les catégories ajoutées (12)
- [ ] Vérification dans Firebase Console
- [ ] Test de lecture depuis l'application
- [ ] Pas de doublons
- [ ] Structure correcte (name, color)
- [ ] Types de données corrects (string)

---

**Fin du document**

Document suivant : [08-RESOLUTION_PROBLEMES_CORS_IMAGES.md](08-RESOLUTION_PROBLEMES_CORS_IMAGES.md)

