# Documentation Technique - Tests Firebase et Troubleshooting

## Informations du document

**Date de création :** 27 octobre 2025  
**Projet :** flutter-recette-october-2025-1  
**Version :** 1.0  
**Auteur :** Documentation technique du projet

---

## Table des matières

1. [Page de test Firebase](#page-de-test-firebase)
2. [Problèmes rencontrés](#problèmes-rencontrés)
3. [Solutions implémentées](#solutions-implémentées)
4. [Scripts PowerShell](#scripts-powershell)
5. [Configuration Google Cloud SDK](#configuration-google-cloud-sdk)
6. [Règles Firestore](#règles-firestore)
7. [Changement de projet Firebase](#changement-de-projet-firebase)

---

## Page de test Firebase

### Fichier : lib/Views/test_firebase_page.dart

#### Objectif

Créer une interface de diagnostic pour vérifier la connexion Firebase et Firestore en temps réel, permettant d'identifier rapidement les problèmes de configuration.

#### Architecture

**Classe principale :** `TestFirebasePage extends StatefulWidget`

**State :** `_TestFirebasePageState`

#### État local

```dart
String _connectionStatus = 'Vérification en cours...';
String _projectId = '';
bool _isConnected = false;
String _testResult = '';
```

**Variables :**
- `_connectionStatus` : Affiche les résultats détaillés des tests
- `_projectId` : Stocke l'ID du projet Firebase
- `_isConnected` : Indicateur de succès de la connexion
- `_testResult` : Message de résumé (succès/échec)

#### Tests implémentés

##### Test 1 : Vérification de l'initialisation Firebase

**Code :**
```dart
final app = Firebase.app();
final projectId = app.options.projectId;
```

**Validations :**
- Firebase.app() ne lance pas d'exception
- projectId n'est pas null ou vide

**Résultat attendu :**
```
Test 1: Firebase initialisé
Projet: flutter-recette-october-2025-1
```

##### Test 2 : Connexion Firestore

**Code :**
```dart
final firestore = FirebaseFirestore.instance;
final snapshot = await firestore
    .collection('categories')
    .limit(1)
    .get()
    .timeout(const Duration(seconds: 10));
```

**Validations :**
- Pas de timeout (10 secondes max)
- Pas d'erreur de permission
- Snapshot retourné (même vide)

**Résultat attendu :**
```
Test 2: Test de connexion Firestore...
Connexion Firestore réussie!
Documents trouvés: X
```

##### Test 3 : Test d'écriture/suppression

**Code :**
```dart
await firestore.collection('_test_connection').doc('test').set({
  'timestamp': FieldValue.serverTimestamp(),
  'message': 'Test de connexion',
});

await firestore.collection('_test_connection').doc('test').delete();
```

**Validations :**
- Écriture réussie
- Suppression réussie
- Pas d'erreur de permission

**Résultat attendu :**
```
Test 3: Test d'écriture...
Écriture/Suppression réussie!
```

#### Interface utilisateur

##### 1. Carte de statut

**Composants :**
- Icône : check_circle (vert) ou info (orange)
- Titre : Résultat du test
- Projet Firebase ID (si disponible)
- Couleur de fond : Vert (succès) ou Orange (en cours/échec)

##### 2. Carte de résultats détaillés

**Contenu :**
- Titre : "Résultats des tests:"
- Texte sélectionnable avec tous les logs
- Affichage en temps réel de la progression

##### 3. Boutons d'action

**Bouton "Ajouter une catégorie de test"**
- Visible seulement si connecté
- Ajoute une catégorie "Test Category" pour validation

**Bouton "Refaire les tests"**
- Toujours visible
- Réinitialise l'état et relance tous les tests

#### Méthode _testFirebaseConnection()

**Algorithme complet :**

```
1. Début
2. Afficher "Vérification en cours..."
3. TRY
   a. Test Firebase.app()
   b. Récupérer projectId
   c. Afficher succès Test 1
   d. Attendre 1 seconde
   
   e. Test Firestore.instance
   f. Query avec limit(1) et timeout(10s)
   g. Afficher succès Test 2
   h. Afficher nombre de documents
   i. Attendre 1 seconde
   
   j. Test écriture document de test
   k. Test suppression document de test
   l. Afficher succès Test 3
   
   m. Marquer _isConnected = true
   n. Afficher "TOUS LES TESTS RÉUSSIS"
4. CATCH
   a. Afficher erreur détaillée
   b. Marquer _isConnected = false
   c. Afficher "ÉCHEC DE LA CONNEXION"
5. Fin
```

#### Intégration dans Settings

**Fichier : lib/Views/app_main_screen.dart**

**Modification :**
```dart
// Option Test Firebase (ajoutée en premier)
_buildSettingTile(
  context: context,
  icon: Icons.cloud_done,
  title: 'Test Firebase',
  subtitle: 'Vérifier la connexion Firebase',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TestFirebasePage(),
      ),
    );
  },
),
```

---

## Problèmes rencontrés

### Problème 1 : TimeoutException lors de la connexion Firestore

#### Symptômes

```
ERREUR: TimeoutException after 0:00:10.000000: Future not completed
```

**Contexte :**
- Firebase initialisé correctement
- projectId récupéré avec succès
- Échec au Test 2 (connexion Firestore)

#### Causes identifiées

1. **Base de données Firestore non créée**
   - L'application tentait de se connecter à une base inexistante
   - Firestore retournait 404 via l'API REST

2. **Règles de sécurité restrictives**
   - Règles temporaires expirées (date limite dépassée)
   - Accès bloqué même avec facturation activée

3. **Projet Firebase incorrect**
   - Script utilisant l'ancien nom de projet
   - Tentative de connexion à un projet différent

#### Diagnostic

**Méthode utilisée :**
- Analyse des logs de l'application
- Vérification de l'erreur HTTP (404)
- Test via gcloud CLI
- Inspection de Firebase Console

---

### Problème 2 : Erreur 404 lors de l'ajout de catégories via script

#### Symptômes

```bash
PS> .\scripts\add_categories_gcloud.ps1
1. Erreur pour Breakfast: Le serveur distant a retourné une erreur : (404) Introuvable.
```

**Contexte :**
- Authentification gcloud réussie
- Token obtenu
- Toutes les requêtes échouent avec 404

#### Cause

**Base de données Firestore non créée**

L'endpoint Firestore REST API retourne 404 si :
```
GET https://firestore.googleapis.com/v1/projects/{project}/databases/(default)/documents/{collection}
```

La base de données `(default)` n'existe pas.

#### Tentatives de résolution

**Tentative 1 : Via Firebase CLI**
```bash
firebase firestore:databases:create default --location=europe-west3
```
**Résultat :** Erreur - Facturation non activée

**Tentative 2 : Via gcloud SDK (régions incorrectes)**
```bash
gcloud firestore databases create --location=europe-west
```
**Résultat :** Erreur - Invalid locationId

**Tentative 3 : Via gcloud SDK (région correcte)**
```bash
gcloud firestore databases create --location=europe-west3
```
**Résultat :** Erreur - Facturation requise

**Solution finale :** Création manuelle via Firebase Console

---

### Problème 3 : Facturation non activée

#### Symptômes

```
ERROR: This API method requires billing to be enabled. 
Please enable billing on project flutter-recette-october-2025
```

**Contexte :**
- Tentative de création de base via gcloud
- Facturation Blaze configurée mais non propagée

#### Cause

**Délai de propagation**

La configuration de facturation prend 5-15 minutes pour se propager dans tous les systèmes Google Cloud.

#### Solution

**Activation manuelle dans Firebase Console**
1. Navigation vers Firestore Database
2. Bouton "Créer une base de données"
3. Sélection du mode et de la région
4. Pas de facturation requise (quota gratuit)

---

### Problème 4 : Règles Firestore avec date d'expiration

#### Symptômes

```javascript
allow read, write: if request.time < timestamp.date(2025, 11, 22);
```

**Conséquence :**
- Accès refusé après la date limite
- Erreur de permission même avec authentification

#### Cause

**Configuration par défaut Firebase**

Firebase génère des règles temporaires en mode test avec une expiration à 30 jours.

#### Solution implémentée

**Règles simplifiées et permanentes :**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Déploiement :**
```bash
firebase deploy --only firestore:rules
```

**Résultat :**
```
+ firestore: released rules firestore.rules to cloud.firestore
+ Deploy complete!
```

---

### Problème 5 : gcloud non reconnu dans VS Code

#### Symptômes

```powershell
PS> gcloud --version
gcloud : Le terme 'gcloud' n'est pas reconnu
```

**Contexte :**
- gcloud fonctionne dans PowerShell externe
- Échec dans le terminal intégré de VS Code

#### Cause

**Variables d'environnement non rechargées**

VS Code ne recharge pas automatiquement les variables PATH après l'installation de nouveaux programmes.

#### Solution

**Redémarrage complet de VS Code**
1. Fermer toutes les fenêtres VS Code
2. Rouvrir VS Code
3. Ouvrir un nouveau terminal

**Alternative :**
Utiliser PowerShell externe pour les commandes gcloud.

---

### Problème 6 : Nom de projet incorrect dans les scripts

#### Symptômes

```
Erreur 404 malgré base de données créée
```

**Contexte :**
- Base de données Firestore créée
- Nouveau projet : flutter-recette-october-2025-1
- Script utilise : flutter-recette-october-2025

#### Cause

**Hard-coded project ID**

Le script PowerShell contenait l'ancien nom de projet en dur :
```powershell
$projectId = "flutter-recette-october-2025"
```

#### Solution

**Mise à jour du script :**
```powershell
$projectId = "flutter-recette-october-2025-1"
```

**Commit et déploiement :**
```bash
git add scripts/add_categories_gcloud.ps1
git commit -m "mise a jour du nom du projet"
git push origin main
```

---

## Solutions implémentées

### Solution 1 : Création de base de données via Console

#### Procédure complète

**Étape 1 : Accès à Firebase Console**
```
URL: https://console.firebase.google.com/project/{projectId}/firestore/databases
```

**Étape 2 : Sélection de l'édition**
- Édition Standard (recommandée)
- Documents max 1 MiB
- Indexation automatique

**Étape 3 : Configuration ID et emplacement**
- ID : (default) - Généré automatiquement
- Emplacement : europe-west3 (Frankfurt) ou eur3

**Étape 4 : Configuration des règles**
- Mode test : Permissif (30 jours)
- Mode production : Restrictif

**Étape 5 : Activation**
- Clic sur "Activer"
- Attente 30-60 secondes
- Base de données créée

#### Avantages de cette méthode

1. **Pas de facturation requise** : Utilise le quota gratuit
2. **Interface visuelle** : Pas de ligne de commande
3. **Immédiat** : Pas de délai de propagation
4. **Fiable** : Pas de problème d'authentification

---

### Solution 2 : Script PowerShell avec gcloud SDK

#### Fichier : scripts/add_categories_gcloud.ps1

#### Configuration requise

**Installation :**
```powershell
winget install Google.CloudSDK
```

**Authentification :**
```powershell
gcloud auth login
```

**Configuration du projet :**
```powershell
gcloud config set project flutter-recette-october-2025-1
```

#### Structure du script

**1. Vérification de gcloud**
```powershell
try {
    $gcloudVersion = gcloud --version 2>&1 | Select-String "Google Cloud SDK"
    Write-Host "gcloud trouvé: $gcloudVersion" -ForegroundColor Green
} catch {
    Write-Host "gcloud n'est pas installé" -ForegroundColor Red
    exit 1
}
```

**2. Authentification**
```powershell
$token = gcloud auth print-access-token 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur d'authentification" -ForegroundColor Red
    exit 1
}
```

**3. Configuration des catégories**
```powershell
$categories = @(
    @{name="Breakfast"; color="FFE8B4"},
    @{name="Lunch"; color="FFC4E1"},
    # ... 10 autres
)
```

**4. Requêtes API REST**
```powershell
$url = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/categories"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}
```

**5. Boucle d'ajout**
```powershell
foreach ($category in $categories) {
    $body = @{
        fields = @{
            name = @{stringValue = $category.name}
            color = @{stringValue = $category.color}
        }
    } | ConvertTo-Json -Depth 10
    
    Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body
}
```

#### Gestion des erreurs

```powershell
try {
    $response = Invoke-RestMethod ...
    Write-Host "✅ $($category.name) ajouté" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur pour $($category.name): $($_.Exception.Message)" -ForegroundColor Red
}
```

---

### Solution 3 : Script de suppression des icônes

#### Fichier : scripts/remove_icons_from_categories.ps1

#### Objectif

Supprimer le champ "icon" des catégories existantes sans les recréer.

#### Algorithme

**Étape 1 : Récupération des documents**
```powershell
$listUrl = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/categories"
$response = Invoke-RestMethod -Method Get -Uri $listUrl -Headers $headers
$documents = $response.documents
```

**Étape 2 : Boucle de mise à jour**
```powershell
foreach ($doc in $documents) {
    $docName = $doc.name  # Path complet
    
    # Créer nouveau body sans icon
    $updateBody = @{
        fields = @{
            name = @{stringValue = $doc.fields.name.stringValue}
            color = @{stringValue = $doc.fields.color.stringValue}
        }
    } | ConvertTo-Json -Depth 10
    
    # PATCH pour remplacer le document
    Invoke-RestMethod -Method Patch -Uri "https://firestore.googleapis.com/v1/$docName" -Headers $updateHeaders -Body $updateBody
}
```

#### Méthode HTTP utilisée

**PATCH vs PUT :**
- PATCH : Remplace complètement le document
- Permet de supprimer des champs
- Conserve l'ID du document

**Alternative (non utilisée) :**
- DELETE puis POST : Plus risqué (perte d'ID)
- Update avec field delete : Plus complexe

---

## Scripts PowerShell

### Script 1 : add_categories_gcloud.ps1

#### Utilisation

```powershell
# Depuis le dossier du projet
cd C:\projetsFirebase\projetrecette

# Exécution
.\scripts\add_categories_gcloud.ps1
```

#### Sortie attendue

```
========================================
Ajout des catégories dans Firestore
========================================

✅ gcloud trouvé: Google Cloud SDK 544.0.0

🔐 Authentification...
✅ Token obtenu

📝 Ajout des 12 catégories...

   1. ✅ Breakfast ajouté
   2. ✅ Lunch ajouté
   3. ✅ Dinner ajouté
   4. ✅ Desserts ajouté
   5. ✅ Appetizers ajouté
   6. ✅ Soups ajouté
   7. ✅ Beverages ajouté
   8. ✅ Snacks ajouté
   9. ✅ Vegetarian ajouté
   10. ✅ Seafood ajouté
   11. ✅ Pasta ajouté
   12. ✅ Pizza ajouté

========================================
✅ TERMINÉ!
========================================

Vérifiez dans Firebase Console:
https://console.firebase.google.com/project/flutter-recette-october-2025-1/firestore
```

### Script 2 : remove_icons_from_categories.ps1

#### Utilisation

```powershell
.\scripts\remove_icons_from_categories.ps1
```

#### Sortie attendue

```
========================================
Suppression des icônes des catégories
========================================

✅ Token obtenu

📝 Récupération des catégories...
✅ 12 catégories trouvées

🗑️  Suppression des icônes...

   1. ✅ Breakfast - icône supprimée
   2. ✅ Lunch - icône supprimée
   ...
   12. ✅ Pizza - icône supprimée

========================================
✅ TERMINÉ!
========================================
```

---

## Configuration Google Cloud SDK

### Installation

#### Via winget (Recommandé)

```powershell
winget install Google.CloudSDK
```

**Avantages :**
- Installation automatique
- Ajout au PATH automatique
- Pas de configuration manuelle

#### Redémarrage requis

Après installation :
1. Fermer tous les terminaux
2. Fermer VS Code
3. Rouvrir VS Code
4. Ouvrir un nouveau terminal

### Authentification

#### Commande

```powershell
gcloud auth login
```

#### Processus

1. Commande lancée dans le terminal
2. Navigateur s'ouvre automatiquement
3. Connexion avec compte Google
4. Autorisation des accès demandés
5. Message de confirmation dans le terminal

#### Vérification

```powershell
gcloud auth list
```

**Sortie attendue :**
```
            Credentialed Accounts
ACTIVE  ACCOUNT
*       rehoumahaythem@gmail.com
```

### Configuration du projet

#### Commande

```powershell
gcloud config set project flutter-recette-october-2025-1
```

#### Vérification

```powershell
gcloud config get-value project
```

**Sortie attendue :**
```
flutter-recette-october-2025-1
```

### Commandes utiles

```powershell
# Version de gcloud
gcloud --version

# Liste des projets
gcloud projects list

# Configuration actuelle
gcloud config list

# Obtenir un token d'accès
gcloud auth print-access-token

# Liste des bases Firestore
gcloud firestore databases list
```

---

## Règles Firestore

### Configuration développement

#### Fichier : firestore.rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Caractéristiques :**
- Permissif total
- Pas d'authentification requise
- Idéal pour développement
- DANGEREUX en production

### Configuration production (recommandée)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Catégories : lecture publique, écriture admin
    match /categories/{category} {
      allow read: if true;
      allow write: if request.auth != null && 
                     request.auth.token.admin == true;
    }
    
    // Autres collections : authentification requise
    match /{collection}/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Déploiement

```bash
firebase deploy --only firestore:rules
```

### Vérification

```bash
# Via Firebase CLI
firebase firestore:rules get

# Via Console
https://console.firebase.google.com/project/{projectId}/firestore/rules
```

---

## Changement de projet Firebase

### Contexte

**Ancien projet :** flutter-recette-october-2025  
**Nouveau projet :** flutter-recette-october-2025-1

### Raison du changement

Création d'un nouveau projet pour résoudre les problèmes de permissions et de configuration.

### Fichiers à mettre à jour

#### 1. Scripts PowerShell

**Fichier : scripts/add_categories_gcloud.ps1**
```powershell
# Ligne 4
$projectId = "flutter-recette-october-2025-1"
```

**Fichier : scripts/remove_icons_from_categories.ps1**
```powershell
# Ligne 3
$projectId = "flutter-recette-october-2025-1"
```

#### 2. Configuration gcloud

```powershell
gcloud config set project flutter-recette-october-2025-1
```

#### 3. Configuration Firebase (si nécessaire)

**Fichier : .firebaserc**
```json
{
  "projects": {
    "default": "flutter-recette-october-2025-1"
  }
}
```

#### 4. Options Firebase Flutter (si nouveau projet)

Régénération via FlutterFire CLI :
```bash
flutterfire configure
```

Cela met à jour :
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### Procédure complète de migration

**Étape 1 : Création du nouveau projet**
```
Firebase Console > Ajouter un projet
Nom : flutter-recette-october-2025-1
```

**Étape 2 : Configuration de la base de données**
```
Firestore Database > Créer une base de données
Mode : Test
Région : europe-west3
```

**Étape 3 : Mise à jour de la configuration locale**
```bash
# Mise à jour .firebaserc
# Mise à jour scripts PowerShell
# Commit des changements
git add .
git commit -m "migration vers nouveau projet Firebase"
git push
```

**Étape 4 : Configuration gcloud**
```powershell
gcloud config set project flutter-recette-october-2025-1
```

**Étape 5 : Test de la configuration**
```powershell
.\scripts\add_categories_gcloud.ps1
```

---

## Récapitulatif des commandes

### Firebase CLI

```bash
# Login
firebase login

# Déployer les règles
firebase deploy --only firestore:rules

# Lister les bases
firebase firestore:databases:list

# Configuration actuelle
firebase projects:list
```

### Google Cloud SDK

```bash
# Installation
winget install Google.CloudSDK

# Authentification
gcloud auth login

# Configuration projet
gcloud config set project flutter-recette-october-2025-1

# Token d'accès
gcloud auth print-access-token

# Liste des projets
gcloud projects list
```

### PowerShell Scripts

```powershell
# Ajouter catégories
.\scripts\add_categories_gcloud.ps1

# Supprimer icônes
.\scripts\remove_icons_from_categories.ps1
```

### Flutter

```bash
# Lancer l'application
flutter run -d chrome

# Tests
flutter test

# Analyser le code
flutter analyze

# Nettoyer
flutter clean

# Récupérer dépendances
flutter pub get
```

---

## Conclusion

Ce document couvre tous les problèmes rencontrés lors de l'implémentation de l'interface d'administration et des tests Firebase, ainsi que leurs solutions.

Les principaux apprentissages :
1. Toujours créer la base Firestore avant d'y accéder
2. Vérifier les noms de projet dans tous les fichiers de configuration
3. Utiliser des règles Firestore sans expiration pour le développement
4. Google Cloud SDK nécessite un redémarrage après installation
5. Firebase Console est souvent plus simple que les CLI pour la configuration initiale

---

**Fin du document**

Document suivant : [07-SCRIPTS_AUTOMATISATION.md](07-SCRIPTS_AUTOMATISATION.md)

