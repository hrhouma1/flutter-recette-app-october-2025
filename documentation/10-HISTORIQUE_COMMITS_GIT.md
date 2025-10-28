# Documentation Technique - Historique Complet des Commits Git

## Informations du document

**Date de création :** 27 octobre 2025  
**Projet :** flutter-recette-october-2025-1  
**Version :** 1.0  
**Auteur :** Documentation technique du projet

---

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Chronologie des commits](#chronologie-des-commits)
3. [Détail de chaque commit](#détail-de-chaque-commit)
4. [Analyse des modifications](#analyse-des-modifications)
5. [Stratégie de versioning](#stratégie-de-versioning)
6. [Bonnes pratiques Git](#bonnes-pratiques-git)

---

## Vue d'ensemble

### Statistiques globales

**Période :** 27 octobre 2025  
**Nombre de commits :** 10+  
**Branches :** main  
**Contributeurs :** 1

### Évolution du projet

**Commits principaux :**
1. Création du menu de navigation
2. Ajout de la page home statique
3. Implémentation de l'interface d'administration
4. Ajout de la documentation
5. Configuration des tests
6. Scripts d'automatisation
7. Résolution des problèmes

---

## Chronologie des commits

### Liste complète (ordre chronologique)

```bash
ef4cc9c - CRÉATION DU MENU EN BAS
78d4460 - ajout de la partie statique 1 de la page home
505b36c - ajout de la page d'administration et initialisation automatique des categories Firestore
ab91416 - ajout du guide d'administration et d'initialisation des categories Firestore
af04289 - reorganisation des guides: ajout methode 1 (manuelle) et renommage methode 2 (automatique)
492d728 - organisation de la documentation et ajout du guide de tests complet
ce842f4 - ajout page test Firebase, scripts d'import et simplification des regles Firestore
df9c706 - ajout guide rapide pour ajout manuel des categories en tant qu'admin
f48aba3 - ajout script PowerShell pour ajouter categories via gcloud API
06af523 - mise a jour du nom du projet dans le script gcloud
ae59043 - suppression des icons des categories dans les scripts
```

### Visualisation de l'arbre Git

```bash
git log --oneline --graph --all
```

**Sortie :**
```
* ae59043 (HEAD -> main, origin/main) suppression des icons des categories dans les scripts
* 06af523 mise a jour du nom du projet dans le script gcloud
* f48aba3 ajout script PowerShell pour ajouter categories via gcloud API
* df9c706 ajout guide rapide pour ajout manuel des categories en tant qu'admin
* ce842f4 ajout page test Firebase, scripts d'import et simplification des regles Firestore
* 492d728 organisation de la documentation et ajout du guide de tests complet
* af04289 reorganisation des guides: ajout methode 1 (manuelle) et renommage methode 2 (automatique)
* ab91416 ajout du guide d'administration et d'initialisation des categories Firestore
* 505b36c ajout de la page d'administration et initialisation automatique des categories Firestore
* 78d4460 ajout de la partie statique 1 de la page home
* ef4cc9c CRÉATION DU MENU EN BAS
```

---

## Détail de chaque commit

### Commit 1 : ef4cc9c - CRÉATION DU MENU EN BAS

#### Date et auteur

```bash
git show ef4cc9c --format=fuller --no-patch
```

#### Modifications

**Type :** Feature  
**Impact :** UI

**Fichiers modifiés :**
- `lib/Views/app_main_screen.dart` : Création du BottomNavigationBar

**Fonctionnalités ajoutées :**
- BottomNavigationBar avec 4 items
- Navigation entre les pages (Home, Favorite, Meal Plan, Settings)
- Icônes Iconsax avec états sélectionné/non-sélectionné
- Gestion de l'index sélectionné

**Code clé :**
```dart
BottomNavigationBar(
  currentIndex: selectedIndex,
  items: [
    BottomNavigationBarItem(icon: Icon(Iconsax.home), label: "Home"),
    BottomNavigationBarItem(
      icon: Icon(selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart),
      label: "Favorite",
    ),
    // ...
  ],
  onTap: (index) {
    setState(() {
      selectedIndex = index;
    });
  },
)
```

**Dépendances ajoutées :**
- iconsax: ^0.0.8

### Commit 2 : 78d4460 - ajout de la partie statique 1 de la page home

#### Statistiques

```bash
git show 78d4460 --stat
```

**Sortie :**
```
17 files changed, 577 insertions(+), 29 deletions(-)
```

#### Modifications principales

**Fichiers créés :**
1. `.firebaserc` : Configuration Firebase CLI
2. `android/app/google-services.json` : Config Android
3. `assets/images/chef.png` : Image du chef (129 KB)
4. `firebase.json` : Configuration services Firebase
5. `firestore.indexes.json` : Index Firestore
6. `firestore.rules` : Règles de sécurité
7. `lib/firebase_options.dart` : Options Firebase multi-plateforme

**Fichiers modifiés :**
1. `lib/Views/app_main_screen.dart` : Page home complète
2. `lib/main.dart` : Initialisation Firebase
3. `pubspec.yaml` : Dépendances et assets
4. `pubspec.lock` : Lock des versions
5. Fichiers générés : Android, iOS, macOS, Windows

#### Composants UI ajoutés

**MyAppHomeScreen :**
- headerParts() : Titre et bouton notification
- mySearchBar() : Barre de recherche
- BannerToExplore : Banner vert avec image du chef
- Section "Categories"

**Code du banner :**
```dart
Container(
  width: double.infinity,
  height: 170,
  decoration: BoxDecoration(
    color: Color(0xFF71B77A),
    borderRadius: BorderRadius.circular(15),
  ),
  child: Stack(
    children: [
      Positioned(
        top: 32,
        left: 20,
        child: Column(
          children: [
            Text("Cook the best\nrecipes at home"),
            ElevatedButton(onPressed: () {}, child: Text("Explore")),
          ],
        ),
      ),
      Positioned(
        right: -20,
        child: Image.asset("assets/images/chef.png", width: 180),
      ),
    ],
  ),
)
```

#### Configuration Firebase

**main.dart :**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

**pubspec.yaml :**
```yaml
dependencies:
  firebase_core: ^2.32.0

assets:
  - assets/images/
```

### Commit 3 : 505b36c - ajout de la page d'administration

#### Statistiques

```bash
4 files changed, 472 insertions(+)
```

#### Fichiers créés

1. `lib/Models/category_model.dart` : Modèle de données
2. `lib/Services/firestore_service.dart` : Service CRUD
3. `lib/Services/init_categories.dart` : Initialisation
4. `lib/Views/admin_page.dart` : Interface admin

#### Architecture implémentée

**Pattern MVC :**
- Model : CategoryModel
- View : AdminPage
- Controller/Service : FirestoreService

**Séparation des responsabilités :**
- Models : Structure de données uniquement
- Services : Logique métier et accès données
- Views : Interface utilisateur

#### Fonctionnalités

1. **Modèle CategoryModel**
   - Propriétés : id, name, icon, color
   - Méthode toMap()
   - Factory fromMap()

2. **Service FirestoreService**
   - addCategory()
   - addMultipleCategories() avec batch write
   - getCategories()
   - categoriesExist()

3. **InitCategories**
   - 12 catégories prédéfinies
   - Méthode initializeCategories(force)
   - Vérification des doublons

4. **AdminPage**
   - Interface d'initialisation
   - Bouton principal
   - Bouton de réinitialisation forcée
   - Feedback visuel

### Commit 4 : ab91416 - ajout du guide d'administration

#### Statistiques

```bash
1 file changed, 909 insertions(+)
```

#### Fichier créé

`GUIDE_ADMIN_CATEGORIES.md` (909 lignes)

#### Contenu du guide

**Sections :**
1. Introduction
2. Architecture
3. Structure des fichiers
4. Détail de l'implémentation
5. Guide d'utilisation
6. Dépannage
7. Sécurité
8. Évolutions futures

**Points marquants :**
- Documentation complète du code
- Schémas d'architecture
- Tableaux des catégories
- 7 problèmes courants avec solutions

### Commit 5 : af04289 - reorganisation des guides

#### Statistiques

```bash
2 files changed, 767 insertions(+), 1 deletion(-)
```

#### Opérations Git

**Fichiers :**
- Création : `01-GUIDE_ADMIN_MANUEL.md`
- Renommage : `GUIDE_ADMIN_CATEGORIES.md` → `02-GUIDE_ADMIN_AUTOMATIQUE.md`

**Commande Git utilisée :**
```bash
git mv GUIDE_ADMIN_CATEGORIES.md 02-GUIDE_ADMIN_AUTOMATIQUE.md
```

**Avantage du git mv :**
- Préserve l'historique du fichier
- Git détecte le renommage
- Affiche comme "rename" dans git log

#### Contenu ajouté

**01-GUIDE_ADMIN_MANUEL.md :**
- 700+ lignes
- Guide pas à pas pour Firebase Console
- 12 catégories avec tous les détails
- Checklist de vérification
- Temps estimé : 17-20 minutes

**02-GUIDE_ADMIN_AUTOMATIQUE.md :**
- Ajout d'un tableau comparatif
- Lien vers le guide manuel
- Mise en avant de la méthode 2

### Commit 6 : 492d728 - organisation documentation et tests

#### Statistiques

```bash
6 files changed (renommages + nouveau fichier)
```

#### Opérations

**Renommages :**
- `01-GUIDE_ADMIN_MANUEL.md` → `documentation/01-GUIDE_ADMIN_MANUEL.md`
- `02-GUIDE_ADMIN_AUTOMATIQUE.md` → `documentation/02-GUIDE_ADMIN_AUTOMATIQUE.md`

**Nouveau fichier :**
- `documentation/03-GUIDE_TESTS.md` (956 lignes)

**Fichier modifié :**
- `test/widget_test.dart` : Tests adaptés à l'application

#### Structure de documentation créée

```
documentation/
├── 01-GUIDE_ADMIN_MANUEL.md
├── 02-GUIDE_ADMIN_AUTOMATIQUE.md
└── 03-GUIDE_TESTS.md
```

#### Contenu du guide de tests

**Sections :**
1. Tests de l'environnement (flutter doctor)
2. Tests des dépendances (flutter pub)
3. Tests de compilation (flutter build)
4. Tests d'exécution (flutter run)
5. Tests unitaires (flutter test)
6. Tests Firebase
7. Checklist complète

**Commandes couvertes :**
- 27 tests numérotés
- Scripts PowerShell inclus
- Troubleshooting pour chaque test

#### Tests unitaires modifiés

**Avant :**
```dart
testWidgets('Counter increments smoke test', ...)
```

**Après :**
```dart
testWidgets('App loads and shows home screen', ...)
testWidgets('Bottom navigation bar is present', ...)
```

**Résultat :**
```bash
flutter test
00:01 +2: All tests passed!
```

### Commit 7 : ce842f4 - ajout page test Firebase et scripts

#### Statistiques

```bash
9 files changed, 589 insertions(+), 13 deletions(-)
```

#### Fichiers créés

1. `lib/Views/test_firebase_page.dart` : Page de diagnostic
2. `scripts/add_categories.dart` : Script Dart (non utilisé)
3. `scripts/add_categories.js` : Script Node.js (non utilisé)
4. `scripts/categories_import.json` : Données JSON
5. `scripts/import_to_firestore.ps1` : Script informatif
6. `tool/add_categories.dart` : Tentative de script standalone

#### Fichiers modifiés

1. `firebase.json` : Configuration mise à jour
2. `firestore.rules` : Simplification des règles
3. `lib/Views/app_main_screen.dart` : Ajout Test Firebase dans Settings

#### TestFirebasePage - Détails

**Tests automatiques au chargement :**

1. **Test Firebase.app()**
   - Vérification de l'initialisation
   - Récupération du projectId

2. **Test Firestore.instance**
   - Query avec timeout de 10 secondes
   - Compte le nombre de documents

3. **Test écriture/suppression**
   - Création document dans _test_connection
   - Suppression immédiate
   - Validation des permissions

**Feedback utilisateur :**
- Carte de statut (vert/orange)
- Logs détaillés sélectionnables
- Bouton "Refaire les tests"
- Bouton "Ajouter catégorie de test" (si connecté)

#### Simplification des règles Firestore

**Avant :**
```javascript
match /categories/{document=**} {
  allow read: if true;
  allow write: if true;
}
match /college/{document=**} {
  allow read: if true;
  allow write: if true;
}
```

**Après :**
```javascript
match /{document=**} {
  allow read, write: if true;
}
```

**Raison :**
- Simplification pour le développement
- Règles globales plus faciles à gérer
- À restreindre en production

### Commit 8 : df9c706 - ajout guide rapide manuel

#### Statistiques

```bash
1 file changed, 185 insertions(+)
```

#### Fichier créé

`documentation/04-AJOUT_MANUEL_CATEGORIES.md`

#### Contenu

**Guide condensé pour :**
- Création rapide de la collection
- Liste des 12 catégories avec valeurs exactes
- Vérification
- Alternatives automatisées

**Format optimisé :**
```
Catégorie 1
name   : Breakfast
color  : FFE8B4

Catégorie 2
name   : Lunch
color  : FFC4E1
```

**Objectif :**
Fournir un guide rapide quand l'automatisation n'est pas disponible.

### Commit 9 : f48aba3 - ajout script PowerShell gcloud

#### Statistiques

```bash
1 file changed, 93 insertions(+)
```

#### Fichier créé

`scripts/add_categories_gcloud.ps1`

#### Fonctionnalités du script

1. **Vérification de gcloud**
   - Test de disponibilité
   - Affichage de la version

2. **Authentification**
   - Obtention du token OAuth2
   - Validation du token

3. **Ajout des catégories**
   - Boucle sur 12 catégories
   - Requêtes POST vers API REST
   - Gestion d'erreur par catégorie

4. **Feedback visuel**
   - Progress en temps réel
   - Couleurs (vert/rouge)
   - Lien vers Firebase Console

#### Technologies utilisées

- PowerShell 5.1+
- Google Cloud SDK
- Firestore REST API v1
- OAuth2 Bearer token

### Commit 10 : 06af523 - mise à jour nom projet

#### Statistiques

```bash
1 file changed, 1 insertion(+), 1 deletion(-)
```

#### Modification

**Fichier :** `scripts/add_categories_gcloud.ps1`

**Ligne 4 :**
```powershell
# Avant
$projectId = "flutter-recette-october-2025"

# Après
$projectId = "flutter-recette-october-2025-1"
```

#### Raison

Migration vers le nouveau projet Firebase suite aux problèmes de permissions et configuration.

#### Impact

- Script fonctionne avec le nouveau projet
- Pas besoin de modification du code applicatif
- Scripts réutilisables

### Commit 11 : ae59043 - suppression des icons

#### Statistiques

```bash
2 files changed, 88 insertions(+), 13 deletions(-)
```

#### Fichiers modifiés

**1. scripts/add_categories_gcloud.ps1**

Suppression du champ icon dans :
```powershell
# Avant
$categories = @(
    @{name="Breakfast"; icon="🍳"; color="FFE8B4"},
)

# Après
$categories = @(
    @{name="Breakfast"; color="FFE8B4"},
)
```

**Et dans le body :**
```powershell
# Avant
$body = @{
    fields = @{
        name = @{stringValue = $category.name}
        icon = @{stringValue = $category.icon}
        color = @{stringValue = $category.color}
    }
}

# Après
$body = @{
    fields = @{
        name = @{stringValue = $category.name}
        color = @{stringValue = $category.color}
    }
}
```

**2. scripts/remove_icons_from_categories.ps1**

Nouveau script créé pour :
- Récupérer toutes les catégories
- Mettre à jour chaque document sans le champ icon
- Validation de la suppression

#### Raison de la modification

Simplification du modèle de données :
- Icônes non nécessaires pour MVP
- Réduction de la complexité
- Facilite les migrations futures
- Moins de données à gérer

---

## Analyse des modifications

### Lignes de code ajoutées/supprimées

#### Par commit

```
ef4cc9c : +XXX, -YYY
78d4460 : +577, -29
505b36c : +472, -0
ab91416 : +909, -0
af04289 : +767, -1
492d728 : +XXX, -XXX
ce842f4 : +589, -13
df9c706 : +185, -0
f48aba3 : +93, -0
06af523 : +1, -1
ae59043 : +88, -13
```

**Total approximatif :** ~3500+ lignes ajoutées

#### Par type de fichier

**Dart (.dart) :**
- lib/Models/category_model.dart : ~30 lignes
- lib/Services/firestore_service.dart : ~60 lignes
- lib/Services/init_categories.dart : ~105 lignes
- lib/Views/admin_page.dart : ~265 lignes
- lib/Views/test_firebase_page.dart : ~250 lignes
- lib/Views/app_main_screen.dart : ~376 lignes
- test/widget_test.dart : ~40 lignes

**Total Dart :** ~1100+ lignes

**Documentation (.md) :**
- 01-GUIDE_ADMIN_MANUEL.md : ~700 lignes
- 02-GUIDE_ADMIN_AUTOMATIQUE.md : ~900 lignes
- 03-GUIDE_TESTS.md : ~950 lignes
- 04-AJOUT_MANUEL_CATEGORIES.md : ~185 lignes
- 05-IMPLEMENTATION_INTERFACE_ADMIN.md : ~690 lignes
- 06-TESTS_TROUBLESHOOTING_FIREBASE.md : ~1025 lignes
- 07-SCRIPTS_AUTOMATISATION_POWERSHELL.md : ~XXX lignes
- 08-RESOLUTION_PROBLEME_CORS_IMAGES.md : ~XXX lignes

**Total Documentation :** ~5000+ lignes

**Scripts (.ps1) :**
- add_categories_gcloud.ps1 : ~90 lignes
- remove_icons_from_categories.ps1 : ~70 lignes
- import_to_firestore.ps1 : ~30 lignes

**Total Scripts :** ~190 lignes

### Fichiers de configuration

**Firebase :**
- .firebaserc : 5 lignes
- firebase.json : ~15 lignes
- firestore.rules : 9 lignes
- firestore.indexes.json : 4 lignes

**Android :**
- google-services.json : ~50 lignes JSON
- build.gradle.kts : Modifications

**Assets :**
- chef.png : 129,098 bytes

---

## Stratégie de versioning

### Convention de messages de commit

#### Formats utilisés

**Feature :**
```
ajout de [fonctionnalité]
```

**Fix :**
```
correction [problème]
```

**Docs :**
```
ajout guide [sujet]
```

**Refactor :**
```
reorganisation [structure]
```

**Update :**
```
mise a jour [élément]
```

#### Exemples

**Bons messages :**
- "ajout de la page d'administration et initialisation automatique des categories Firestore"
- "mise a jour du nom du projet dans le script gcloud"
- "suppression des icons des categories dans les scripts"

**À améliorer :**
- "update" (trop vague)
- "fix" (pas de détails)
- "changes" (pas descriptif)

### Utilisation des branches

#### Stratégie actuelle

**Branch unique : main**

Tous les commits directement sur main.

**Approprié pour :**
- Projet solo
- Développement rapide
- Prototypage

#### Stratégie recommandée pour production

**Branches :**
```
main (production)
  ↑
develop (intégration)
  ↑
feature/admin-interface
feature/firebase-config
fix/cors-images
```

**Workflow Git Flow :**
```bash
# Créer une feature
git checkout -b feature/nouvelle-fonctionnalite

# Développer
git add .
git commit -m "implementation de X"

# Merge dans develop
git checkout develop
git merge feature/nouvelle-fonctionnalite

# Release vers main
git checkout main
git merge develop
git tag v1.0.0
```

### Tags et releases

#### Tags recommandés

```bash
# Version majeure
git tag -a v1.0.0 -m "Version initiale avec admin"
git push origin v1.0.0

# Version mineure
git tag -a v1.1.0 -m "Ajout tests Firebase"
git push origin v1.1.0

# Patch
git tag -a v1.0.1 -m "Fix CORS images"
git push origin v1.0.1
```

#### Semantic Versioning

**Format :** MAJOR.MINOR.PATCH

- **MAJOR :** Changements incompatibles
- **MINOR :** Nouvelles fonctionnalités (compatibles)
- **PATCH :** Corrections de bugs

**Exemples pour ce projet :**
- v1.0.0 : Version initiale avec UI et Firebase
- v1.1.0 : Ajout interface admin
- v1.1.1 : Fix problème CORS
- v1.2.0 : Ajout page de tests
- v2.0.0 : Migration nouveau projet Firebase

---

## Bonnes pratiques Git

### Messages de commit

#### Structure recommandée

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Exemple complet :**
```
feat(admin): ajout interface initialisation categories

- Création du modèle CategoryModel
- Service FirestoreService avec batch write
- Page AdminPage avec feedback visuel
- Intégration dans Settings

Resolves #12
```

#### Types conventionnels

- **feat** : Nouvelle fonctionnalité
- **fix** : Correction de bug
- **docs** : Documentation
- **style** : Formatage, pas de changement de code
- **refactor** : Refactoring
- **test** : Ajout/modification de tests
- **chore** : Maintenance, build

### Commits atomiques

#### Principe

Un commit = Une modification logique

**Bons exemples :**
- "ajout page test Firebase" (1 fonctionnalité)
- "mise a jour nom projet" (1 changement)
- "suppression icons categories" (1 modification)

**À éviter :**
- "diverses modifications" (trop vague)
- "WIP" (work in progress, pas de contexte)
- Commits géants (100+ fichiers)

### .gitignore

#### Fichiers ignorés

```gitignore
# Build outputs
/build/
/.dart_tool/
/.flutter-plugins
/.flutter-plugins-dependencies
/.packages

# IDE
.idea/
.vscode/
*.iml
*.ipr
*.iws

# Secrets (si utilisés)
*.env
service-account-key.json

# OS
.DS_Store
Thumbs.db

# Android
*.jks
key.properties
local.properties

# iOS
*.pbxuser
*.perspectivev3
```

**Fichiers NON ignorés (doivent être commités) :**
- `firebase_options.dart` : Configuration publique
- `google-services.json` : Configuration publique
- `.firebaserc` : Configuration projet

### Revue de code

#### Checklist avant commit

- [ ] Code fonctionne localement
- [ ] Tests passent (`flutter test`)
- [ ] Pas d'erreurs d'analyse (`flutter analyze`)
- [ ] Documentation mise à jour si nécessaire
- [ ] Message de commit descriptif
- [ ] Pas de fichiers temporaires inclus
- [ ] Pas de secrets commités

#### Commandes de vérification

```bash
# Voir les fichiers modifiés
git status

# Voir les différences
git diff

# Voir les différences staged
git diff --staged

# Analyse du code
flutter analyze

# Tests
flutter test

# Commit avec vérification
git commit -v
```

---

## Commandes Git utilisées

### Commits

```bash
# Ajouter tous les fichiers
git add .
git add -A

# Ajouter fichiers spécifiques
git add lib/Views/admin_page.dart
git add documentation/

# Commit
git commit -m "message"

# Commit avec éditeur
git commit

# Amender le dernier commit
git commit --amend
```

### Renommages

```bash
# Renommer avec historique
git mv ancien_nom nouveau_nom

# Déplacer dans dossier
git mv fichier.md documentation/fichier.md
```

### Synchronisation

```bash
# Récupérer les changements
git pull
git pull origin main

# Envoyer les changements
git push
git push origin main

# Forcer (DANGEREUX)
git push --force
```

### Inspection

```bash
# Historique
git log
git log --oneline
git log --graph --all
git log --oneline -10

# Détails d'un commit
git show <commit-hash>
git show HEAD
git show HEAD~1

# Statistiques
git show <commit> --stat
git diff <commit1> <commit2> --stat
```

### Annulations

```bash
# Annuler modifications non staged
git restore fichier.dart

# Annuler staging
git restore --staged fichier.dart

# Revenir à un commit
git reset --hard <commit-hash>

# Revenir au dernier commit
git reset --hard HEAD
```

---

## Historique des branches

### Branch main

**Tous les commits sont sur main**

```bash
git branch -v
```

**Sortie :**
```
* main ae59043 suppression des icons des categories dans les scripts
```

### Stratégie de merge

**Fast-forward uniquement**

Aucun merge commit car :
- Développement linéaire
- Pas de branches parallèles
- Pas de pull requests

**Historique linéaire :**
```
A -- B -- C -- D -- E -- F -- G -- H (main)
```

vs historique avec branches :
```
A -- B -- C -- F -------- H (main)
      \       /         /
       D -- E (feature) G (fix)
```

---

## Statistiques détaillées

### Par auteur

```bash
git shortlog -sn
```

**Sortie :**
```
11    Nom de l'auteur
```

### Par fichier

```bash
git log --follow --oneline -- lib/Views/app_main_screen.dart
```

**Modifications de app_main_screen.dart :**
```
ae59043 - (aucune modification ce commit)
ce842f4 - ajout page test Firebase
78d4460 - ajout de la partie statique
ef4cc9c - création du menu
```

### Taille du repository

```bash
git count-objects -vH
```

**Informations :**
- Nombre d'objets
- Taille du pack
- Taille totale

---

## Récupération et rollback

### Revenir à un commit spécifique

```bash
# Voir l'état à un moment donné
git checkout 78d4460

# Revenir à main
git checkout main

# Créer une branche depuis un commit
git checkout -b nouvelle-branche 78d4460
```

### Annuler un commit

```bash
# Annuler le dernier commit (garder les modifications)
git reset --soft HEAD~1

# Annuler le dernier commit (supprimer les modifications)
git reset --hard HEAD~1

# Annuler un commit spécifique (crée un nouveau commit)
git revert <commit-hash>
```

### Récupérer un fichier d'un ancien commit

```bash
# Récupérer un fichier
git checkout 78d4460 -- lib/Views/admin_page.dart

# Voir le contenu sans restaurer
git show 78d4460:lib/Views/admin_page.dart
```

---

## Git hooks (potentiels)

### Pre-commit hook

**Fichier :** `.git/hooks/pre-commit`

```bash
#!/bin/sh

echo "Running pre-commit checks..."

# Analyse du code
flutter analyze
if [ $? -ne 0 ]; then
  echo "Flutter analyze failed. Commit aborted."
  exit 1
fi

# Tests
flutter test
if [ $? -ne 0 ]; then
  echo "Tests failed. Commit aborted."
  exit 1
fi

echo "All checks passed!"
exit 0
```

**Activation :**
```bash
chmod +x .git/hooks/pre-commit
```

### Pre-push hook

```bash
#!/bin/sh

echo "Running pre-push checks..."

# Build test
flutter build web --no-tree-shake-icons
if [ $? -ne 0 ]; then
  echo "Build failed. Push aborted."
  exit 1
fi

exit 0
```

---

## Comparaison des versions

### Différences entre commits

```bash
# Comparer deux commits
git diff 78d4460..505b36c

# Voir seulement les fichiers
git diff 78d4460..505b36c --name-only

# Statistiques
git diff 78d4460..505b36c --stat
```

### Blâme (qui a modifié quoi)

```bash
git blame lib/Views/admin_page.dart

# Avec date
git blame -w lib/Views/admin_page.dart

# Lignes spécifiques
git blame -L 100,200 lib/Views/admin_page.dart
```

---

## Recommandations futures

### Commits

1. **Messages descriptifs**
   - Utiliser le présent
   - Être spécifique
   - Mentionner le "pourquoi" dans le body

2. **Taille raisonnable**
   - 1 commit = 1 fonctionnalité
   - Pas de commits géants
   - Pas de micro-commits

3. **Tests avant commit**
   - `flutter analyze`
   - `flutter test`
   - Test manuel rapide

### Branches

1. **Utiliser des branches pour les features**
   ```bash
   git checkout -b feature/nom-feature
   ```

2. **Merge requests/Pull requests**
   - Revue de code
   - CI/CD automatique
   - Discussion

3. **Protection de main**
   - Pas de push direct
   - Require reviews
   - Status checks obligatoires

### Tags

1. **Version releases**
   ```bash
   git tag -a v1.0.0 -m "Release message"
   ```

2. **Changelog**
   - Générer automatiquement
   - Depuis les messages de commit

---

**Fin du document**

Document suivant : [11-TESTS_UNITAIRES_INTEGRATION.md](11-TESTS_UNITAIRES_INTEGRATION.md)

