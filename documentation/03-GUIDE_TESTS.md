# Guide de Tests - Application de Recettes Flutter

## Table des matières

1. [Introduction](#introduction)
2. [Prérequis](#prérequis)
3. [Configuration initiale](#configuration-initiale)
4. [Tests de l'environnement](#tests-de-lenvironnement)
5. [Tests des dépendances](#tests-des-dépendances)
6. [Tests de compilation](#tests-de-compilation)
7. [Tests d'exécution](#tests-dexécution)
8. [Tests unitaires](#tests-unitaires)
9. [Tests d'intégration](#tests-dintégration)
10. [Tests Firebase](#tests-firebase)
11. [Résolution des problèmes](#résolution-des-problèmes)

---

## Introduction

Ce guide vous explique comment tester votre application Flutter de recettes étape par étape, avec toutes les commandes nécessaires.

### Objectifs des tests

- Vérifier que l'environnement de développement est correctement configuré
- S'assurer que toutes les dépendances sont installées
- Tester la compilation sur différentes plateformes
- Valider le fonctionnement de l'application
- Vérifier la connexion Firebase
- Tester l'ajout de catégories

---

## Prérequis

### Logiciels requis

- Flutter SDK (version 3.8.0 ou supérieure)
- Dart SDK (inclus avec Flutter)
- Git
- Un éditeur de code (VS Code, Android Studio, ou IntelliJ)
- Un navigateur moderne (Chrome recommandé)

### Comptes requis

- Compte Google (pour Firebase)
- Accès au projet Firebase configuré

---

## Configuration initiale

### Étape 1 : Vérifier le répertoire de travail

Ouvrez un terminal et naviguez vers votre projet :

```bash
cd C:\projetsFirebase\projetrecette
```

**Vérification :**
```bash
pwd
```

**Résultat attendu :**
```
C:\projetsFirebase\projetrecette
```

### Étape 2 : Lister les fichiers du projet

```bash
ls
```

ou sur Windows PowerShell :

```powershell
Get-ChildItem
```

**Résultat attendu :**
Vous devez voir les dossiers : `android`, `ios`, `lib`, `web`, `documentation`, etc.

---

## Tests de l'environnement

### Test 1 : Vérifier l'installation de Flutter

```bash
flutter --version
```

**Résultat attendu :**
```
Flutter 3.x.x • channel stable • https://github.com/flutter/flutter.git
Framework • revision xxx
Engine • revision xxx
Tools • Dart 3.x.x • DevTools 2.x.x
```

**Que vérifier :**
- Version de Flutter >= 3.8.0
- Channel : stable
- Dart SDK installé

**Si la commande échoue :**
- Flutter n'est pas installé ou pas dans le PATH
- Suivez : https://docs.flutter.dev/get-started/install

### Test 2 : Vérifier l'installation de Dart

```bash
dart --version
```

**Résultat attendu :**
```
Dart SDK version: 3.x.x (stable)
```

### Test 3 : Diagnostic Flutter complet

```bash
flutter doctor
```

**Résultat attendu :**
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Microsoft Windows...)
[✓] Windows Version (Installed version of Windows is version 10 or higher)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Visual Studio - develop Windows apps
[✓] VS Code
[✓] Connected device (3 available)
[✓] Network resources

• No issues found!
```

**Que vérifier :**
- Tous les éléments avec [✓] sont validés
- Si [!] ou [✗], suivez les instructions pour corriger

**Obtenir plus de détails :**
```bash
flutter doctor -v
```

### Test 4 : Vérifier les appareils disponibles

```bash
flutter devices
```

**Résultat attendu :**
```
3 connected devices:

Windows (desktop) • windows • windows-x64    • Microsoft Windows...
Chrome (web)      • chrome  • web-javascript • Google Chrome...
Edge (web)        • edge    • web-javascript • Microsoft Edge...
```

**Que vérifier :**
- Au moins un appareil est disponible
- Chrome est présent pour les tests web

---

## Tests des dépendances

### Test 5 : Afficher les dépendances du projet

```bash
flutter pub deps
```

**Résultat attendu :**
Liste complète de toutes les dépendances avec leur version.

**Dépendances principales à vérifier :**
- firebase_core
- cloud_firestore
- iconsax
- cupertino_icons

### Test 6 : Récupérer les dépendances

```bash
flutter pub get
```

**Résultat attendu :**
```
Running "flutter pub get" in projetrecette...
Resolving dependencies...
Got dependencies!
```

**Si des avertissements apparaissent :**
- Lecture normale, pas d'inquiétude si c'est juste des versions plus récentes disponibles

### Test 7 : Vérifier les versions obsolètes

```bash
flutter pub outdated
```

**Résultat attendu :**
Tableau montrant les versions actuelles et disponibles.

**Action :**
- Pour le développement, ce n'est pas nécessaire de tout mettre à jour
- Pour la production, considérez les mises à jour

### Test 8 : Analyser le code

```bash
flutter analyze
```

**Résultat attendu :**
```
Analyzing projetrecette...
No issues found!
```

**Si des issues apparaissent :**
- Warnings : À corriger mais pas bloquant
- Errors : Doivent être corrigés avant de continuer
- Info : Suggestions d'amélioration

---

## Tests de compilation

### Test 9 : Nettoyage du projet

Avant de compiler, nettoyez le cache :

```bash
flutter clean
```

**Résultat attendu :**
```
Deleting build...
Deleting .dart_tool...
Deleting .flutter-plugins-dependencies...
```

**Quand utiliser :**
- Après modification du pubspec.yaml
- En cas de problèmes de compilation
- Avant un build de production

### Test 10 : Compilation pour le Web

```bash
flutter build web
```

**Résultat attendu :**
```
Building without sound null safety
Compiling lib/main.dart for the Web...
Built build/web
```

**Durée :** 1-3 minutes selon votre machine

**Que vérifier :**
- Aucune erreur de compilation
- Le dossier `build/web` est créé

**Si la compilation échoue :**
- Vérifier les erreurs dans le terminal
- Corriger le code
- Relancer `flutter clean` puis `flutter build web`

### Test 11 : Compilation pour Android (optionnel)

```bash
flutter build apk
```

**Résultat attendu :**
```
Running Gradle task 'assembleRelease'...
Built build/app/outputs/flutter-apk/app-release.apk (XX MB)
```

**Durée :** 3-10 minutes pour la première compilation

**Note :** Nécessite Android SDK installé

### Test 12 : Compilation pour Windows (optionnel)

```bash
flutter build windows
```

**Résultat attendu :**
```
Building Windows application...
Built build\windows\runner\Release\
```

**Durée :** 2-5 minutes

---

## Tests d'exécution

### Test 13 : Lancer l'application en mode debug sur Chrome

**Commande :**
```bash
flutter run -d chrome
```

**Résultat attendu :**
```
Launching lib/main.dart on Chrome in debug mode...
Building application for the web...
Waiting for connection from debug service on Chrome...
This app is linked to the debug service: ws://127.0.0.1:xxxxx
Debug service listening on ws://127.0.0.1:xxxxx

Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

Running with sound null safety

An Observatory debugger and profiler on Chrome is available at: http://127.0.0.1:xxxxx
The Flutter DevTools debugger and profiler on Chrome is available at: http://127.0.0.1:xxxxx
```

**Que vérifier :**
- L'application s'ouvre dans Chrome
- Aucune erreur dans le terminal
- L'interface s'affiche correctement

**Actions à tester dans l'application :**
1. Vérifier que la page d'accueil s'affiche
2. Cliquer sur les onglets de navigation (Home, Favorite, Meal Plan, Settings)
3. Vérifier que le header s'affiche : "What are you cooking today?"
4. Vérifier que la barre de recherche est visible
5. Vérifier que le banner vert avec le chef s'affiche
6. Vérifier que la section "Categories" est présente

### Test 14 : Hot Reload

Pendant que l'application tourne, modifiez quelque chose dans le code (ex: changez une couleur).

**Commande dans le terminal où l'app tourne :**
```
r
```
(appuyez sur la touche "r")

**Résultat attendu :**
```
Performing hot reload...
Reloaded 1 of xxx libraries in xxx ms.
```

**Que vérifier :**
- Les changements apparaissent immédiatement
- Pas besoin de relancer l'application

### Test 15 : Hot Restart

**Commande dans le terminal où l'app tourne :**
```
R
```
(appuyez sur la touche "R" majuscule)

**Résultat attendu :**
```
Performing hot restart...
Restarted application in xxx ms.
```

**Quand utiliser :**
- Après modification de la méthode main()
- Après changement de configuration Firebase
- En cas de comportement étrange

### Test 16 : Arrêter l'application

**Commande :**
```
q
```
(appuyez sur la touche "q")

**Résultat attendu :**
```
Application finished.
```

### Test 17 : Lancer en mode release (production)

```bash
flutter run -d chrome --release
```

**Résultat attendu :**
- Application plus rapide
- Taille réduite
- Pas de debug tools

**Durée :** Plus long au démarrage (optimisation)

---

## Tests unitaires

### Test 18 : Lister les tests disponibles

```bash
Get-ChildItem -Path test -Recurse -Filter "*.dart"
```

**Résultat attendu :**
```
test/widget_test.dart
```

### Test 19 : Exécuter tous les tests

```bash
flutter test
```

**Résultat attendu :**
```
00:01 +1: All tests passed!
```

**Que vérifier :**
- Tous les tests passent (marqués par +)
- Aucun test ne échoue
- Temps d'exécution raisonnable

**Si des tests échouent :**
```
00:01 +0 -1: test description
  Expected: ...
  Actual: ...
```

**Action :** Corriger le code ou le test

### Test 20 : Exécuter un test spécifique

```bash
flutter test test/widget_test.dart
```

**Résultat attendu :**
```
00:01 +1: All tests passed!
```

### Test 21 : Exécuter les tests avec couverture

```bash
flutter test --coverage
```

**Résultat attendu :**
```
00:01 +1: All tests passed!
Writing coverage information to coverage/lcov.info
```

**Visualiser la couverture (optionnel) :**
```bash
# Installer lcov (Windows)
choco install lcov

# Générer le rapport HTML
genhtml coverage/lcov.info -o coverage/html

# Ouvrir dans le navigateur
start coverage/html/index.html
```

---

## Tests d'intégration

### Test 22 : Navigation entre les pages

**Scénario de test :**

1. Lancer l'application :
   ```bash
   flutter run -d chrome
   ```

2. **Test de la page Home :**
   - Vérifier que c'est la page par défaut
   - Vérifier le titre : "What are you cooking today?"
   - Vérifier la barre de recherche
   - Vérifier le banner vert

3. **Test de navigation vers Favorite :**
   - Cliquer sur l'onglet "Favorite" (icône cœur)
   - Vérifier que le texte change : "Page index: 1"
   - Vérifier que l'icône change (cœur plein)

4. **Test de navigation vers Meal Plan :**
   - Cliquer sur l'onglet "Meal Plan" (icône calendrier)
   - Vérifier que le texte change : "Page index: 2"
   - Vérifier que l'icône change (calendrier plein)

5. **Test de navigation vers Settings :**
   - Cliquer sur l'onglet "Settings" (icône paramètres)
   - Vérifier que la page Settings s'affiche
   - Vérifier le titre : "Settings"
   - Vérifier que l'option "Administration" est présente

### Test 23 : Page d'administration

**Scénario de test :**

1. Depuis Settings, cliquer sur "Administration"

2. **Vérifications sur la page Admin :**
   - Titre : "Administration"
   - Carte d'information avec la liste des catégories
   - Bouton "Initialiser les catégories" (bleu)
   - Bouton "Forcer la réinitialisation" (orange)

3. **Test du bouton d'initialisation :**
   - Cliquer sur "Initialiser les catégories"
   - Vérifier l'apparition du CircularProgressIndicator
   - Attendre le message de succès
   - Vérifier le SnackBar vert

4. **Vérifier dans Firebase Console :**
   - Ouvrir https://console.firebase.google.com
   - Aller dans Firestore Database
   - Vérifier que la collection "categories" contient 12 documents

### Test 24 : Test de l'image du chef

**Scénario de test :**

1. Sur la page Home, vérifier que l'image du chef s'affiche dans le banner vert

2. **Si l'image ne s'affiche pas :**
   - Ouvrir la console Chrome (F12)
   - Aller dans l'onglet Console
   - Vérifier les erreurs de chargement d'image

3. **Vérifier que l'asset existe :**
   ```bash
   Test-Path assets/images/chef.png
   ```
   
   **Résultat attendu :** `True`

---

## Tests Firebase

### Test 25 : Vérifier la connexion Firebase

**Dans le terminal où l'app tourne, cherchez :**
```
[FirebaseCore] Firebase initialized successfully
```

**Si vous ne voyez pas ce message :**
- Firebase n'est pas initialisé
- Vérifier `lib/main.dart`
- Vérifier `lib/firebase_options.dart`

### Test 26 : Test manuel des services Firestore

**Créer un fichier de test temporaire :**

`test/firestore_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Firestore connection test', () async {
    // Ce test nécessite Firebase configuré
    // À exécuter manuellement dans l'app
  });
}
```

**Pour tester réellement :**
1. Lancer l'application
2. Aller dans Administration
3. Cliquer sur "Initialiser les catégories"
4. Vérifier les logs dans le terminal

### Test 27 : Vérifier les règles de sécurité Firestore

**Accéder à Firebase Console :**
1. Ouvrir https://console.firebase.google.com
2. Sélectionner votre projet
3. Aller dans Firestore Database > Rules

**Règles à vérifier :**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /categories/{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Test de lecture :**
```bash
# Dans l'application lancée
1. Aller dans Settings > Administration
2. Les catégories doivent se charger sans erreur
```

**Test d'écriture :**
```bash
# Dans l'application lancée
1. Cliquer sur "Initialiser les catégories"
2. Vérifier le message de succès
```

---

## Résolution des problèmes

### Problème 1 : Flutter command not found

**Erreur :**
```
'flutter' is not recognized as an internal or external command
```

**Solution :**
1. Vérifier l'installation de Flutter
2. Ajouter Flutter au PATH système :
   ```
   Panneau de configuration > Système > Variables d'environnement
   Ajouter : C:\path\to\flutter\bin
   ```
3. Redémarrer le terminal

### Problème 2 : Build failed

**Erreur :**
```
FAILURE: Build failed with an exception.
```

**Solutions :**
```bash
# 1. Nettoyer le projet
flutter clean

# 2. Récupérer les dépendances
flutter pub get

# 3. Réessayer
flutter run -d chrome
```

### Problème 3 : Firebase not initialized

**Erreur :**
```
[core/no-app] No Firebase App '[DEFAULT]' has been created
```

**Solutions :**
1. Vérifier que `Firebase.initializeApp()` est appelé dans `main()`
2. Vérifier que `firebase_options.dart` existe
3. Régénérer la configuration :
   ```bash
   flutterfire configure
   ```

### Problème 4 : Tests échouent

**Erreur :**
```
Expected: ...
Actual: ...
```

**Solutions :**
1. Lire attentivement l'erreur
2. Vérifier le code testé
3. Mettre à jour le test si le comportement a changé
4. Exécuter un seul test pour déboguer :
   ```bash
   flutter test test/widget_test.dart
   ```

### Problème 5 : Hot reload ne fonctionne pas

**Solutions :**
1. Essayer Hot restart (R)
2. Arrêter et relancer l'application
3. Pour les assets, un restart complet est nécessaire :
   ```bash
   q  # Quitter
   flutter run -d chrome  # Relancer
   ```

### Problème 6 : Chrome ne s'ouvre pas

**Solutions :**
1. Vérifier que Chrome est installé
2. Spécifier le chemin de Chrome :
   ```bash
   flutter run -d chrome --web-browser-flag="--user-data-dir=C:\temp\chrome"
   ```
3. Essayer avec Edge :
   ```bash
   flutter run -d edge
   ```

---

## Checklist complète des tests

Utilisez cette checklist pour valider votre projet :

### Tests de base
- [ ] `flutter --version` fonctionne
- [ ] `flutter doctor` sans erreurs
- [ ] `flutter devices` montre au moins un appareil
- [ ] `flutter pub get` réussit
- [ ] `flutter analyze` sans erreurs critiques

### Tests de compilation
- [ ] `flutter clean` réussit
- [ ] `flutter build web` réussit
- [ ] Dossier `build/web` créé

### Tests d'exécution
- [ ] `flutter run -d chrome` lance l'application
- [ ] Page Home s'affiche correctement
- [ ] Navigation entre les onglets fonctionne
- [ ] Image du chef s'affiche
- [ ] Barre de recherche présente

### Tests de fonctionnalités
- [ ] Page Settings accessible
- [ ] Page Administration accessible
- [ ] Liste des catégories visible
- [ ] Bouton "Initialiser les catégories" fonctionne
- [ ] Message de succès s'affiche

### Tests Firebase
- [ ] Firebase initialisé (vérifier les logs)
- [ ] Collection "categories" créée dans Firestore
- [ ] 12 documents ajoutés
- [ ] Chaque document a les 3 champs (name, icon, color)

### Tests de qualité
- [ ] `flutter test` tous les tests passent
- [ ] Aucune warning critique dans la console
- [ ] Performance acceptable (pas de lag)

---

## Scripts utiles

### Script de test complet (PowerShell)

Créez un fichier `test_projet.ps1` :

```powershell
# Script de test complet du projet Flutter

Write-Host "=== Test du projet Flutter - Application de Recettes ===" -ForegroundColor Green

# Test 1 : Flutter version
Write-Host "`n1. Verification de Flutter..." -ForegroundColor Cyan
flutter --version

# Test 2 : Flutter doctor
Write-Host "`n2. Diagnostic Flutter..." -ForegroundColor Cyan
flutter doctor

# Test 3 : Appareils disponibles
Write-Host "`n3. Appareils disponibles..." -ForegroundColor Cyan
flutter devices

# Test 4 : Nettoyage
Write-Host "`n4. Nettoyage du projet..." -ForegroundColor Cyan
flutter clean

# Test 5 : Récupération des dépendances
Write-Host "`n5. Recuperation des dependances..." -ForegroundColor Cyan
flutter pub get

# Test 6 : Analyse du code
Write-Host "`n6. Analyse du code..." -ForegroundColor Cyan
flutter analyze

# Test 7 : Tests unitaires
Write-Host "`n7. Execution des tests..." -ForegroundColor Cyan
flutter test

# Test 8 : Build Web
Write-Host "`n8. Compilation pour le Web..." -ForegroundColor Cyan
flutter build web

Write-Host "`n=== Tous les tests sont termines ===" -ForegroundColor Green
Write-Host "Pour lancer l'application : flutter run -d chrome" -ForegroundColor Yellow
```

**Utilisation :**
```powershell
.\test_projet.ps1
```

### Script de lancement rapide

Créez un fichier `run.ps1` :

```powershell
# Lancement rapide de l'application

Write-Host "Lancement de l'application sur Chrome..." -ForegroundColor Green
flutter run -d chrome
```

**Utilisation :**
```powershell
.\run.ps1
```

---

## Commandes de référence rapide

### Commandes essentielles

```bash
# Environnement
flutter --version                 # Version de Flutter
flutter doctor                    # Diagnostic complet
flutter devices                   # Liste des appareils

# Dépendances
flutter pub get                   # Installer les dépendances
flutter pub outdated              # Vérifier les versions
flutter pub upgrade               # Mettre à jour les dépendances

# Nettoyage
flutter clean                     # Nettoyer le cache

# Analyse
flutter analyze                   # Analyser le code

# Tests
flutter test                      # Exécuter tous les tests
flutter test --coverage           # Tests avec couverture

# Build
flutter build web                 # Compiler pour Web
flutter build apk                 # Compiler pour Android
flutter build windows             # Compiler pour Windows

# Exécution
flutter run -d chrome             # Lancer sur Chrome
flutter run -d chrome --release   # Mode production
flutter run -d edge               # Lancer sur Edge
flutter run -d windows            # Lancer sur Windows
```

### Commandes pendant l'exécution

```
r     # Hot reload
R     # Hot restart
h     # Aide
d     # Détacher
c     # Clear console
q     # Quitter
```

---

## Conclusion

Ce guide vous a permis de tester complètement votre application Flutter de recettes. 

### Résumé des tests effectués

1. Environnement de développement
2. Dépendances du projet
3. Compilation multi-plateformes
4. Exécution et navigation
5. Fonctionnalités Firebase
6. Tests unitaires
7. Tests d'intégration

### Prochaines étapes

Après avoir validé tous les tests :

1. **Développer les fonctionnalités manquantes**
   - Affichage des catégories dans l'UI
   - Ajout de recettes
   - Filtrage par catégorie

2. **Améliorer les tests**
   - Ajouter plus de tests unitaires
   - Créer des tests d'intégration complets
   - Mettre en place CI/CD

3. **Optimiser l'application**
   - Performance
   - SEO pour le web
   - Accessibilité

4. **Préparer le déploiement**
   - Configuration production Firebase
   - Build optimisé
   - Déploiement sur Firebase Hosting

---

**Document créé le :** 27 octobre 2025  
**Version :** 1.0  
**Projet :** Application de Recettes Flutter avec Firebase

