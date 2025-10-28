# Guide Pratique - Toutes les Commandes Exécutées dans l'Ordre

## Informations du document

**Date :** 27 octobre 2025  
**Projet :** flutter-recette-october-2025 puis flutter-recette-october-2025-1  
**Type :** Guide de référence des commandes réelles

---

## Étape 1 : Résolution problème image CORS

### Commandes exécutées

```powershell
# Créer dossier assets
New-Item -ItemType Directory -Force -Path "assets/images"

# Télécharger l'image
Invoke-WebRequest -Uri "https://pngimg.com/d/chef_PNG190.png" -OutFile "assets/images/chef.png"

# Vérifier téléchargement
Get-ChildItem -Path "assets/images/" -File
Test-Path assets/images/chef.png
```

**Résultat :**
```
Mode    LastWriteTime    Length Name
----    -------------    ------ ----
-a----  27/10/2025     129098  chef.png

True
```

### Modifications code

**pubspec.yaml** : Ajout section assets  
**app_main_screen.dart** : Image.network() vers Image.asset()

### Validation

```bash
flutter pub get
flutter clean
flutter run -d chrome
```

**Résultat :** Image s'affiche correctement

---

## Étape 2 : Ajout interface administration

### Création structure

```powershell
# Créer dossiers
New-Item -ItemType Directory -Force -Path "lib/Models"
New-Item -ItemType Directory -Force -Path "lib/Services"
```

**Résultat :**
```
Mode    LastWriteTime    Name
----    -------------    ----
d-----  27/10/2025       Models
d-----  27/10/2025       Services
```

### Installation dépendances

```bash
flutter pub get
```

**Résultat :**
```
Resolving dependencies...
Downloading packages...
  cloud_firestore 4.17.5
Got dependencies!
```

---

## Étape 3 : Commits Git de la partie statique

### Commandes Git

```bash
# Ajouter fichiers
git add assets/images/
git add .firebaserc android/app/google-services.json firebase.json firestore.indexes.json firestore.rules lib/firebase_options.dart
git add README.md android/ macos/ windows/
git add lib/main.dart pubspec.yaml pubspec.lock
git add lib/Views/app_main_screen.dart

# Vérifier
git status --short

# Commit
git commit -m "ajout de la partie statique 1 de la page home"

# Push
git push origin main
```

**Résultat :**
```
[main 78d4460] ajout de la partie statique 1 de la page home
 17 files changed, 577 insertions(+), 29 deletions(-)

To https://github.com/hrhouma1/flutter-recette-app-october-2025.git
   ef4cc9c..78d4460  main -> main
```

---

## Étape 4 : Commits Git de l'administration

### Commandes Git

```bash
# Ajouter fichiers admin
git add lib/Models/ lib/Services/ lib/Views/admin_page.dart

# Vérifier
git status --short

# Commit
git commit -m "ajout de la page d'administration et initialisation automatique des categories Firestore"

# Push
git push origin main
```

**Résultat :**
```
[main 505b36c] ajout de la page d'administration et initialisation automatique des categories Firestore
 4 files changed, 472 insertions(+)

To https://github.com/hrhouma1/flutter-recette-app-october-2025.git
   78d4460..505b36c  main -> main
```

---

## Étape 5 : Création et organisation documentation

### Documentation initiale

```bash
# Ajouter guide
git add GUIDE_ADMIN_CATEGORIES.md
git commit -m "ajout du guide d'administration et d'initialisation des categories Firestore"
git push origin main
```

**Résultat :**
```
[main ab91416] ajout du guide d'administration et d'initialisation des categories Firestore
 1 file changed, 909 insertions(+)
```

### Réorganisation

```bash
# Créer dossier
New-Item -ItemType Directory -Force -Path "documentation"

# Renommer et déplacer
git mv GUIDE_ADMIN_CATEGORIES.md 02-GUIDE_ADMIN_AUTOMATIQUE.md
git mv 01-GUIDE_ADMIN_MANUEL.md documentation/
git mv 02-GUIDE_ADMIN_AUTOMATIQUE.md documentation/

# Ajouter nouveau guide
git add 01-GUIDE_ADMIN_MANUEL.md 02-GUIDE_ADMIN_AUTOMATIQUE.md
git commit -m "reorganisation des guides: ajout methode 1 (manuelle) et renommage methode 2 (automatique)"
git push origin main
```

**Résultat :**
```
[main af04289] reorganisation des guides
 2 files changed, 767 insertions(+), 1 deletion(-)
```

---

## Étape 6 : Tests et diagnostic Firebase

### Analyse du code

```bash
flutter analyze
```

**Résultat :**
```
Analyzing projetrecette...
   info - Don't invoke 'print' in production code (16 occurrences)
   info - Parameter could be a super parameter (5 occurrences)
16 issues found. (ran in 74.9s)
```

### Tests unitaires

```bash
# Première tentative (échec)
flutter test
```

**Erreur :**
```
00:01 +0 -1: Counter increments smoke test [E]
Test failed. See exception logs above.
00:02 +0 -1: Some tests failed.
```

**Modification test/widget_test.dart puis :**

```bash
flutter test
```

**Résultat :**
```
00:01 +2: All tests passed!
```

### Compilation Web

```bash
# Première tentative (échec)
flutter build web
```

**Erreur :**
```
Target web_release_bundle failed: IconTreeShakerException: Font subsetting failed with exit code -1.
Error: Failed to compile application for the Web.
```

**Solution :**

```bash
flutter build web --no-tree-shake-icons
```

**Résultat :**
```
Compiling lib\main.dart for the Web...  59.4s
√ Built build\web
```

---

## Étape 7 : Problème connexion Firestore

### Test dans l'application

```bash
flutter run -d chrome
# Navigation : Settings > Test Firebase
```

**Résultat :**
```
ÉCHEC DE LA CONNEXION
Test 1: Firebase initialisé ✅
Test 2: Test de connexion Firestore...
❌ ERREUR: TimeoutException after 0:00:10.000000: Future not completed
```

### Vérification règles Firestore

```bash
firebase deploy --only firestore:rules
```

**Résultat :**
```
=== Deploying to 'flutter-recette-october-2025'...
i  deploying firestore
+  cloud.firestore: rules file firestore.rules compiled successfully
+  firestore: released rules firestore.rules to cloud.firestore
+  Deploy complete!
```

**Test après déploiement :** ÉCHEC - Timeout persiste

---

## Étape 8 : Installation Google Cloud SDK

### Installation

```powershell
winget install Google.CloudSDK
```

**Résultat :**
```
Trouvé Google Cloud SDK [Google.CloudSDK] Version 544.0.0
Téléchargement en cours https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe
  ██████████████████████████████   261 KB /  261 KB
Démarrage du package d'installation... Merci de patienter.
Le programme d'installation demande à s'exécuter en tant qu'administrateur.
```

Installation réussie.

### Vérification PATH

**Dans VS Code :**
```powershell
gcloud --version
```

**Erreur :**
```
gcloud : Le terme 'gcloud' n'est pas reconnu
```

**Dans PowerShell externe :**
```powershell
gcloud --version
```

**Succès :**
```
Google Cloud SDK 544.0.0
```

**Solution :** Utiliser PowerShell externe ou redémarrer VS Code

---

## Étape 9 : Tentatives création base Firestore

### TOUTES LES TENTATIVES (avec erreurs)

**Tentative 1 :**
```bash
gcloud firestore databases create --location=europe-west --project=flutter-recette-october-2025
```

**Erreur :**
```
ERROR: (gcloud.firestore.databases.create) INVALID_ARGUMENT: Invalid locationId: europe-west
```

**Tentative 2 :**
```bash
gcloud firestore databases create --location=us-central --project=flutter-recette-october-2025
```

**Erreur :**
```
ERROR: (gcloud.firestore.databases.create) INVALID_ARGUMENT: Invalid locationId: us-central
```

**Tentative 3 :**
```bash
gcloud firestore databases create --location=us-central-1 --project=flutter-recette-october-2025
```

**Erreur :**
```
ERROR: (gcloud.firestore.databases.create) INVALID_ARGUMENT: Invalid locationId: us-central-1
```

**Tentative 4 :**
```bash
gcloud firestore databases create --location=europe-west3 --project=flutter-recette-october-2025
```

**Erreur :**
```
ERROR: (gcloud.firestore.databases.create) [rehoumahaythem@gmail.com] does not have permission to access projects instance [flutter-recette-october-2025] (or it may not exist): This API method requires billing to be enabled. Please enable billing on project flutter-recette-october-2025 by visiting https://console.developers.google.com/billing/enable?project=flutter-recette-october-2025 then retry. If you enabled billing for this project recently, wait a few minutes for the action to propagate to our systems and retry. This command is authenticated as rehoumahaythem@gmail.com which is the active account specified by the [core/account] property.
```

**Formats de région valides :**
- europe-west3 (CORRECT)
- us-central1 (CORRECT)
- europe-west (INCORRECT)
- us-central (INCORRECT)
- us-central-1 (INCORRECT - pas de tiret)

---

## Étape 10 : Tentatives avec Firebase CLI

**Tentative 1 :**
```bash
firebase firestore:databases:create default --location=europe-west
```

**Erreur :**
```
Error: Request to https://firestore.googleapis.com/v1/projects/flutter-recette-october-2025/databases?databaseId=default had HTTP Error: 400, Invalid locationId: europe-west
```

**Tentative 2 :**
```bash
firebase firestore:databases:create default --location=europe-west3
```

**Erreur :**
```
Error: Request to https://firestore.googleapis.com/v1/projects/flutter-recette-october-2025/databases?databaseId=default had HTTP Error: 403, This API method requires billing to be enabled.
```

**Conclusion :** Firebase CLI rencontre mêmes problèmes

---

## Étape 11 : Vérification liste bases de données

```bash
firebase firestore:databases:list
```

**Résultat :**
```
┌────────────────────────────────────────────────────────────┐
│ Database Name                                              │
├────────────────────────────────────────────────────────────┤
│ projects/flutter-recette-october-2025/databases/default    │
└────────────────────────────────────────────────────────────┘
```

**Constat :** La base existe déjà dans l'ancien projet

---

## Étape 12 : Création nouveau projet Firebase

### Via Firebase Console

**URL :** https://console.firebase.google.com

**Actions :**
1. Clic "Ajouter un projet"
2. Nom : flutter-recette-october-2025-1
3. Google Analytics : Oui
4. Compte Analytics : Par défaut
5. Clic "Créer le projet"
6. Attente : 1-2 minutes

**Résultat :**
Projet créé : flutter-recette-october-2025-1

### Création base Firestore via Console

**URL :** https://console.firebase.google.com/project/flutter-recette-october-2025-1/firestore/databases

**Actions :**
1. Clic "Créer une base de données"
2. Édition : Standard
3. Clic "Suivant"
4. Mode : Test (sélectionné)
5. Région : eur3
6. Clic "Activer"
7. Attente : 30-60 secondes

**Résultat :** Base créée avec succès

---

## Étape 13 : Mise à jour scripts PowerShell

### Modification du script

**Fichier :** scripts/add_categories_gcloud.ps1  
**Ligne 4 :** `$projectId = "flutter-recette-october-2025"` vers `$projectId = "flutter-recette-october-2025-1"`

```bash
git add scripts/add_categories_gcloud.ps1
git commit -m "mise a jour du nom du projet dans le script gcloud"
git push origin main
```

---

## Étape 14 : Configuration gcloud

```bash
# Configurer projet
gcloud config set project flutter-recette-october-2025-1
```

**Résultat :**
```
Updated property [core/project].
```

**Vérification :**
```bash
gcloud config get-value project
```

**Résultat :**
```
flutter-recette-october-2025-1
```

---

## Étape 15 : Exécutions script (avec erreurs puis succès)

### Exécution 1 (échec)

```powershell
.\scripts\add_categories_gcloud.ps1
```

**Résultat :**
```
✅ gcloud trouvé: Google Cloud SDK 544.0.0
✅ Token obtenu
   1. ❌ Erreur pour Breakfast: Le serveur distant a retourné une erreur : (404) Introuvable.
   ... (12 échecs)
```

### Exécution 2 (échec)

```powershell
.\scripts\add_categories_gcloud.ps1
```

**Résultat :** Identique - 12 échecs 404

### Exécution 3 (échec)

```powershell
.\scripts\add_categories_gcloud.ps1
```

**Résultat :** Identique - 12 échecs 404

### Exécution 4 (échec)

```powershell
.\scripts\add_categories_gcloud.ps1
```

**Résultat :** Identique - 12 échecs 404

**Cause des échecs répétés :**
Script local pas mis à jour, utilisait toujours l'ancien nom de projet malgré le commit.

### Exécution 5 (SUCCÈS)

**Après mise à jour manuelle ou rechargement :**

```powershell
.\scripts\add_categories_gcloud.ps1
```

**Résultat :**
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

---

## Étape 16 : Suppression icônes des catégories

### Exécution 1

```powershell
git pull
.\scripts\remove_icons_from_categories.ps1
```

**Résultat :**
```
========================================
Suppression des icônes des catégories
========================================

✅ Token obtenu

📝 Récupération des catégories...
✅ 12 catégories trouvées

🗑️  Suppression des icônes...

   1. ✅ Dinner - icône supprimée
   2. ✅ Pizza - icône supprimée
   3. ✅ Snacks - icône supprimée
   4. ✅ Beverages - icône supprimée
   5. ✅ Breakfast - icône supprimée
   6. ✅ Vegetarian - icône supprimée
   7. ✅ Soups - icône supprimée
   8. ✅ Appetizers - icône supprimée
   9. ✅ Lunch - icône supprimée
   10. ✅ Seafood - icône supprimée
   11. ✅ Pasta - icône supprimée
   12. ✅ Desserts - icône supprimée

========================================
✅ TERMINÉ!
========================================
```

### Exécution 2 (vérification)

```powershell
.\scripts\remove_icons_from_categories.ps1
```

**Résultat :** Identique (opération idempotente)

---

## Étape 17 : Reconfiguration Firebase dans l'application

### Problème identifié

**Application affiche toujours :**
```
Projet Firebase: flutter-recette-october-2025
```

**Fichier problématique :** `lib/firebase_options.dart`

### Mise à jour .firebaserc

```bash
# Modification manuelle
# .firebaserc ligne 3 : "default": "flutter-recette-october-2025-1"

git add .firebaserc
```

### Reconfiguration complète

```bash
flutterfire configure --project=flutter-recette-october-2025-1 --platforms=web,android,ios,macos,windows --yes
```

**Durée :** ~60-90 secondes

**Sortie (étapes) :**
```
⠋ Fetching available Firebase projects...
i Found 6 Firebase projects. Selecting project flutter-recette-october-2025-1.
i Selected platforms: android,ios,macos,web,windows

⠋ Fetching registered android Firebase apps...
i Firebase android app com.example.projetrecette is not registered.
⠋ Registering new Firebase android app...
i Registered a new Firebase android app.

⠋ Fetching registered ios Firebase apps...
i Firebase ios app com.example.projetrecette is not registered.
⠋ Registering new Firebase ios app...
i Registered a new Firebase ios app.

⠋ Fetching registered macos Firebase apps...
i Firebase macos app com.example.projetrecette is already registered.

⠋ Fetching registered web Firebase apps...
i Firebase web app is not registered.
⠋ Registering new Firebase web app...
i Registered a new Firebase web app.

⠋ Fetching registered windows Firebase apps...
i Firebase windows app projetrecette (windows) is not registered.
⠋ Registering new Firebase windows app...
i Registered a new Firebase windows app.

Firebase configuration file lib\firebase_options.dart generated successfully with the following Firebase apps:

Platform  Firebase App Id
web       1:778895779513:web:053a5b9e891ebd0366dd68
android   1:778895779513:android:53e85a211663cfb466dd68
ios       1:778895779513:ios:77a4087aa3861cb866dd68
macos     1:778895779513:ios:77a4087aa3861cb866dd68
windows   1:778895779513:web:5ce4989fd9c4446766dd68
```

**Fichiers mis à jour :**
- lib/firebase_options.dart
- android/app/google-services.json
- (Autres configs générées)

---

## Étape 18 : Relancement application

```bash
flutter run -d chrome
```

**Attendu :**
- Application charge
- Projet : flutter-recette-october-2025-1 (nouveau)
- Test Firebase réussi
- Connexion Firestore opérationnelle

---

## Résumé des commandes essentielles

### Installation et configuration

```powershell
# Installer gcloud
winget install Google.CloudSDK

# Authentification (ouvre navigateur)
gcloud auth login

# Configurer projet
gcloud config set project flutter-recette-october-2025-1

# Vérifier
gcloud config get-value project
```

### Firebase

```bash
# Login Firebase CLI
firebase login

# Déployer règles
firebase deploy --only firestore:rules

# Liste bases de données
firebase firestore:databases:list

# Reconfigurer projet Flutter
flutterfire configure --project=flutter-recette-october-2025-1 --platforms=web,android,ios,macos,windows --yes
```

### Flutter

```bash
# Dépendances
flutter pub get

# Nettoyage
flutter clean

# Analyse
flutter analyze

# Tests
flutter test

# Build Web
flutter build web --no-tree-shake-icons

# Run
flutter run -d chrome
```

### Scripts PowerShell

```powershell
# Naviguer vers projet
cd C:\projetsFirebase\projetrecette

# Ajouter catégories
.\scripts\add_categories_gcloud.ps1

# Supprimer icônes
.\scripts\remove_icons_from_categories.ps1
```

### Git

```bash
# Status
git status
git status --short

# Ajouter
git add -A
git add fichier.dart

# Commit
git commit -m "message"

# Push
git push origin main

# Pull
git pull

# Log
git log --oneline -5
```

---

## Erreurs courantes et solutions

### Erreur : gcloud non reconnu

**Commande :**
```powershell
gcloud --version
```

**Erreur :**
```
gcloud : Le terme 'gcloud' n'est pas reconnu
```

**Solutions :**
1. Utiliser PowerShell externe (pas VS Code)
2. Redémarrer VS Code
3. Vérifier installation : `winget list Google.CloudSDK`

### Erreur : Invalid locationId

**Commande :**
```bash
gcloud firestore databases create --location=europe-west
```

**Erreur :**
```
ERROR: INVALID_ARGUMENT: Invalid locationId: europe-west
```

**Solutions :**
Utiliser format correct :
- europe-west3 (bon)
- us-central1 (bon)
- asia-northeast1 (bon)

### Erreur : Billing required

**Commande :**
```bash
gcloud firestore databases create --location=europe-west3 --project=mon-projet
```

**Erreur :**
```
ERROR: This API method requires billing to be enabled.
```

**Solutions :**
1. Activer facturation via Console
2. Attendre 10-15 minutes propagation
3. OU créer base via Console (pas de facturation requise)

### Erreur : 404 Not Found

**Commande :**
```powershell
.\scripts\add_categories_gcloud.ps1
```

**Erreur :**
```
❌ Erreur : Le serveur distant a retourné une erreur : (404) Introuvable.
```

**Solutions :**
1. Vérifier base de données existe
2. Vérifier nom de projet correct dans script
3. Vérifier gcloud config : `gcloud config get-value project`
4. Créer base via Console si inexistante

### Erreur : TimeoutException Firestore

**Dans application :**
```
❌ ERREUR: TimeoutException after 0:00:10.000000: Future not completed
```

**Solutions :**
1. Vérifier base de données créée
2. Vérifier firebase_options.dart (bon projet)
3. Vérifier règles Firestore (allow read, write: if true)
4. Reconfigurer : `flutterfire configure`

---

## Checklist configuration complète

### Installation

- [ ] Google Cloud SDK installé (`winget install Google.CloudSDK`)
- [ ] Firebase CLI installé (`npm install -g firebase-tools`)
- [ ] FlutterFire CLI installé (`dart pub global activate flutterfire_cli`)
- [ ] Flutter SDK installé et dans PATH

### Authentification

- [ ] `gcloud auth login` exécuté
- [ ] `firebase login` exécuté
- [ ] Token obtenu : `gcloud auth print-access-token`

### Configuration projet

- [ ] Projet Firebase créé via Console
- [ ] Base Firestore créée via Console (mode test)
- [ ] Région sélectionnée (eur3 ou europe-west3)
- [ ] gcloud configuré : `gcloud config set project PROJECT_ID`
- [ ] .firebaserc mis à jour

### Configuration application

- [ ] `flutterfire configure` exécuté
- [ ] firebase_options.dart généré
- [ ] Toutes plateformes enregistrées
- [ ] google-services.json téléchargé

### Validation

- [ ] `flutter pub get` sans erreur
- [ ] `flutter analyze` warnings acceptables
- [ ] `flutter test` tous passent
- [ ] `flutter build web --no-tree-shake-icons` réussit
- [ ] Application lance : `flutter run -d chrome`
- [ ] Test Firebase dans app : SUCCÈS
- [ ] Scripts PowerShell : SUCCÈS

---

## Temps estimés

| Tâche | Temps estimé | Temps réel (avec troubleshooting) |
|-------|--------------|-----------------------------------|
| Installation gcloud | 5 min | 10 min |
| Création projet Firebase | 5 min | 10 min |
| Création base Firestore | 2 min | 3-4 heures (avec erreurs) |
| Configuration gcloud | 2 min | 5 min |
| Exécution scripts | 1 min | 30 min (tentatives) |
| Reconfiguration app | 3 min | 90 secondes |
| **TOTAL** | **~20 min** | **~4-5 heures** |

**Avec ce guide :** 20 minutes pour tout configurer correctement dès le début.

---

## Ordre optimal (sans erreurs)

**Si vous recommenciez à zéro :**

```bash
# 1. Créer projet via Firebase Console
# 2. Créer base Firestore via Console (mode test, eur3)

# 3. Installer outils
winget install Google.CloudSDK

# 4. Authentification
gcloud auth login
firebase login

# 5. Configuration
gcloud config set project flutter-recette-october-2025-1

# 6. Configuration Flutter
flutterfire configure --project=flutter-recette-october-2025-1 --platforms=web,android,ios,macos,windows --yes

# 7. Dépendances
flutter pub get

# 8. Déployer règles
firebase deploy --only firestore:rules

# 9. Exécuter scripts
.\scripts\add_categories_gcloud.ps1

# 10. Vérifier
flutter run -d chrome
# Settings > Test Firebase
```

**Total :** 15-20 minutes

---

**Fin du guide pratique**

