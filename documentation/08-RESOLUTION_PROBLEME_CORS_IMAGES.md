# Documentation Technique - Résolution du Problème CORS Images

## Informations du document

**Date de création :** 27 octobre 2025  
**Projet :** flutter-recette-october-2025-1  
**Version :** 1.0  
**Auteur :** Documentation technique du projet

---

## Table des matières

1. [Problématique initiale](#problématique-initiale)
2. [Analyse du problème](#analyse-du-problème)
3. [Solution implémentée](#solution-implémentée)
4. [Configuration des assets](#configuration-des-assets)
5. [Migration Image.network vers Image.asset](#migration-imagenetwork-vers-imageasset)
6. [Tests et validation](#tests-et-validation)
7. [Bonnes pratiques](#bonnes-pratiques)

---

## Problématique initiale

### Contexte

Lors de l'exécution de l'application Flutter sur le navigateur Chrome, l'image du chef ne s'affichait pas dans le banner de la page d'accueil.

### Code initial problématique

**Fichier :** `lib/Views/app_main_screen.dart`

```dart
Positioned(
  top: 0,
  bottom: 0,
  right: -20,
  child: Image.network(
    "https://pngimg.com/d/chef_PNG190.png",
    width: 180,
  ),
),
```

### Symptômes observés

1. **Sur Flutter Web (Chrome) :**
   - Image ne s'affiche pas
   - Espace vide à la place de l'image
   - Console Chrome affiche une erreur CORS

2. **Erreur dans la console :**
```
HTTP request failed, statusCode: 0, https://pngimg.com/d/chef_PNG190.png
```

3. **Logs Flutter :**
```
Image provider: NetworkImage("https://pngimg.com/d/chef_PNG190.png", scale: 1.0)
Image key: NetworkImage("https://pngimg.com/d/chef_PNG190.png", scale: 1.0)
```

---

## Analyse du problème

### CORS (Cross-Origin Resource Sharing)

#### Définition

CORS est un mécanisme de sécurité du navigateur qui restreint les requêtes HTTP cross-origin initiées depuis des scripts.

#### Fonctionnement

**Requête cross-origin :**
```
Application Flutter Web (localhost:port)
        ↓ GET request
Site externe (pngimg.com)
        ↓ Response
Navigateur vérifie les headers CORS
        ↓
Si pas de header "Access-Control-Allow-Origin"
        → BLOCAGE
```

#### Headers CORS requis

Pour autoriser l'accès, le serveur distant doit envoyer :

```http
Access-Control-Allow-Origin: *
```

ou spécifiquement :

```http
Access-Control-Allow-Origin: http://localhost:port
```

### Vérification du problème

#### Test dans Chrome DevTools

1. Ouvrir Chrome DevTools (F12)
2. Onglet "Console"
3. Erreur visible :
```
Access to image at 'https://pngimg.com/d/chef_PNG190.png' from origin 'http://localhost:xxxxx' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

4. Onglet "Network"
5. Filtrer par "Img"
6. Voir la requête vers pngimg.com
7. Status : (failed) ou CORS error

#### Test de téléchargement direct

**Vérification que l'URL est valide :**

```powershell
Invoke-WebRequest -Uri "https://pngimg.com/d/chef_PNG190.png" -OutFile "test.png"
```

**Résultat :**
- Téléchargement réussi
- Fichier test.png créé
- Taille : ~129 KB

**Conclusion :**
- L'URL est valide
- Le problème est bien lié à CORS, pas à l'URL

### Pourquoi ça ne fonctionne que sur Web

#### Flutter Mobile (Android/iOS)

```dart
Image.network("https://...")
```

Fonctionne sans problème car :
- Les requêtes HTTP natives ne sont pas soumises à CORS
- Pas de navigateur intermédiaire
- Requêtes directes du système d'exploitation

#### Flutter Web (Chrome/Edge)

```dart
Image.network("https://...")
```

Converti en :
```html
<img src="https://..." />
```

Le navigateur applique les règles CORS :
- Requête JavaScript cross-origin
- Vérification des headers CORS
- Blocage si headers manquants

---

## Solution implémentée

### Stratégie choisie

**Conversion en asset local**

Au lieu de charger l'image depuis Internet, la télécharger une fois et l'inclure dans l'application.

**Avantages :**
1. Pas de problème CORS
2. Performance améliorée (pas de requête réseau)
3. Application fonctionne offline
4. Contrôle total sur l'image
5. Pas de dépendance externe

**Inconvénients :**
1. Taille de l'application augmentée (~129 KB)
2. Image figée (pas de mise à jour dynamique)
3. Nécessite rebuild pour changer l'image

### Étapes de mise en œuvre

#### Étape 1 : Création de la structure de dossiers

**Commande PowerShell :**
```powershell
New-Item -ItemType Directory -Force -Path "assets/images"
```

**Résultat :**
```
Répertoire : C:\projetsFirebase\projetrecette\assets

Mode    LastWriteTime    Length Name
----    -------------    ------ ----
d-----  27/10/2025       0      images
```

**Structure créée :**
```
projetrecette/
└── assets/
    └── images/
```

#### Étape 2 : Téléchargement de l'image

**Commande PowerShell :**
```powershell
Invoke-WebRequest -Uri "https://pngimg.com/d/chef_PNG190.png" -OutFile "assets/images/chef.png"
```

**Paramètres :**
- `-Uri` : URL source de l'image
- `-OutFile` : Chemin de destination

**Vérification :**
```powershell
Get-ChildItem -Path "assets/images/" -File
```

**Résultat :**
```
Mode    LastWriteTime    Length Name
----    -------------    ------ ----
-a----  27/10/2025      129098 chef.png
```

**Propriétés de l'image :**
- Nom : chef.png
- Taille : 129,098 bytes (129 KB)
- Format : PNG
- Transparence : Oui

#### Étape 3 : Configuration du pubspec.yaml

**Fichier :** `pubspec.yaml`

**Modification :**

Avant :
```yaml
flutter:
  uses-material-design: true
  
  # assets:
  #   - images/a_dot_burr.jpeg
```

Après :
```yaml
flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
```

**Syntaxe importante :**
- Indentation : 2 espaces sous `flutter:`
- Tiret `-` pour la liste
- Slash final `/` : Inclut tous les fichiers du dossier
- Alternative : Lister les fichiers individuellement
  ```yaml
  assets:
    - assets/images/chef.png
  ```

**Différence :**
- Avec `/` : Inclut tous les fichiers présents et futurs
- Sans `/` : Seulement les fichiers listés

#### Étape 4 : Mise à jour du code Flutter

**Fichier :** `lib/Views/app_main_screen.dart`

**Avant :**
```dart
child: Image.network(
  "https://pngimg.com/d/chef_PNG190.png",
  width: 180,
),
```

**Après :**
```dart
child: Image.asset(
  "assets/images/chef.png",
  width: 180,
),
```

**Changements :**
- `Image.network()` → `Image.asset()`
- URL complète → Chemin relatif asset
- Reste identique : `width: 180`

#### Étape 5 : Installation des dépendances

**Commande :**
```bash
flutter pub get
```

**Sortie :**
```
Running "flutter pub get" in projetrecette...
Resolving dependencies...
Got dependencies!
```

**Processus :**
1. Lecture du pubspec.yaml
2. Résolution des dépendances
3. Téléchargement des packages
4. Enregistrement des assets

**Fichier généré :**
`.flutter-plugins-dependencies`

#### Étape 6 : Nettoyage et reconstruction

**Commandes :**
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

**Pourquoi flutter clean ?**

Après modification des assets dans pubspec.yaml :
- Le cache de build doit être nettoyé
- Les assets doivent être ré-empaquetés
- Le manifest doit être regénéré

**Fichiers affectés par clean :**
- `build/` : Supprimé
- `.dart_tool/` : Supprimé
- `build/flutter_assets/AssetManifest.json` : Regénéré

---

## Configuration des assets

### Structure du système d'assets Flutter

#### Fichiers générés

**AssetManifest.json :**
```json
{
  "assets/images/chef.png": [
    "assets/images/chef.png"
  ],
  "packages/cupertino_icons/assets/CupertinoIcons.ttf": [
    "packages/cupertino_icons/assets/CupertinoIcons.ttf"
  ]
}
```

**AssetManifest.bin :**
- Version binaire du manifest
- Plus rapide à charger
- Utilisé par le runtime Flutter

**FontManifest.json :**
```json
[
  {
    "family": "MaterialIcons",
    "fonts": [
      {
        "asset": "fonts/MaterialIcons-Regular.otf"
      }
    ]
  }
]
```

#### Processus de chargement

```
1. Application démarre
2. Lecture de AssetManifest.json
3. Vérification de l'existence des assets
4. Image.asset() appelle rootBundle
5. rootBundle charge depuis le bundle
6. Image décodée et affichée
```

### Résolution des assets

#### Formats supportés

Flutter supporte automatiquement les résolutions multiples :

```
assets/
  images/
    chef.png          # 1x (base)
    2.0x/
      chef.png        # 2x (haute densité)
    3.0x/
      chef.png        # 3x (très haute densité)
```

**Sélection automatique :**
- Flutter choisit selon le devicePixelRatio
- Fallback sur 1x si résolution non disponible

#### Chemins valides

**Relatif au pubspec.yaml :**
```dart
Image.asset("assets/images/chef.png")
```

**Avec package :**
```dart
Image.asset("packages/my_package/image.png")
```

**Invalide :**
```dart
Image.asset("/assets/images/chef.png")  // Slash initial
Image.asset("./assets/images/chef.png")  // Point-slash
Image.asset("assets\\images\\chef.png")  // Backslash Windows
```

### Alternatives à Image.asset

#### AssetImage

```dart
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage("assets/images/chef.png"),
    ),
  ),
)
```

#### rootBundle

```dart
import 'package:flutter/services.dart' show rootBundle;

Future<ByteData> loadImage() async {
  return await rootBundle.load('assets/images/chef.png');
}
```

---

## Migration Image.network vers Image.asset

### Comparaison des widgets

#### Image.network

**Signature :**
```dart
Image.network(
  String src,
  {
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
    BlendMode? colorBlendMode,
    Widget Function(BuildContext, Widget, int?, bool)? frameBuilder,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }
)
```

**Caractéristiques :**
- Charge depuis HTTP/HTTPS
- Cache automatique
- Supporte les placeholders
- Gestion d'erreur intégrée

**Exemple avec loading :**
```dart
Image.network(
  "https://example.com/image.png",
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return CircularProgressIndicator(
      value: loadingProgress.expectedTotalBytes != null
          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
          : null,
    );
  },
)
```

#### Image.asset

**Signature :**
```dart
Image.asset(
  String name,
  {
    AssetBundle? bundle,
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
    BlendMode? colorBlendMode,
    Widget Function(BuildContext, Widget, int?, bool)? frameBuilder,
    String? package,
  }
)
```

**Caractéristiques :**
- Charge depuis le bundle de l'application
- Pas de requête réseau
- Chargement instantané
- Pas de gestion de cache nécessaire

**Exemple basique :**
```dart
Image.asset(
  "assets/images/chef.png",
  width: 180,
  fit: BoxFit.cover,
)
```

### Paramètres conservés lors de la migration

Dans notre cas :
```dart
// Avant
Image.network(
  "https://pngimg.com/d/chef_PNG190.png",
  width: 180,
)

// Après
Image.asset(
  "assets/images/chef.png",
  width: 180,
)
```

**Paramètres identiques :**
- `width: 180` : Largeur de l'image

**Paramètres par défaut :**
- `fit: null` : Comportement par défaut (contain)
- `height: null` : Calculé automatiquement selon le ratio
- `alignment: Alignment.center`

### Impact sur le rendu

**Aucun changement visuel :**
- Même taille
- Même position
- Même qualité

**Amélioration de la performance :**
- Chargement instantané (pas de délai réseau)
- Pas de spinner de chargement
- Expérience utilisateur fluide

---

## Configuration des assets

### Modification du pubspec.yaml

#### Localisation dans le fichier

**Ligne 55-64 :**
```yaml
flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
```

#### Syntaxe YAML

**Points critiques :**

1. **Indentation stricte**
   ```yaml
   flutter:               # Colonne 0
     uses-material-design # 2 espaces
     assets:              # 2 espaces
       - assets/images/   # 4 espaces + tiret
   ```

2. **Tiret pour les listes**
   ```yaml
   assets:
     - assets/images/     # Premier élément
     - assets/fonts/      # Deuxième élément (si nécessaire)
   ```

3. **Slash final**
   ```yaml
   - assets/images/       # Inclut tout le dossier
   - assets/images/chef.png  # Un seul fichier
   ```

#### Erreurs courantes

**Erreur 1 : Indentation incorrecte**
```yaml
flutter:
uses-material-design: true  # ERREUR : Pas d'indentation
```

**Erreur 2 : Utilisation de tabulations**
```yaml
flutter:
	uses-material-design: true  # ERREUR : Tab au lieu d'espaces
```

**Erreur 3 : Path Windows avec backslash**
```yaml
assets:
  - assets\images\  # ERREUR : Utiliser / même sur Windows
```

#### Validation du YAML

**Commande :**
```bash
flutter pub get
```

**Si erreur de syntaxe :**
```
Error on line 63, column 5: Expected a key while parsing a block mapping.
```

**Outils en ligne :**
- http://www.yamllint.com/
- Copier-coller le pubspec.yaml
- Vérifier les erreurs

### Enregistrement des assets

#### Processus lors de flutter pub get

```
1. Lecture de pubspec.yaml
2. Parsing de la section 'assets'
3. Vérification de l'existence des fichiers
4. Génération de .flutter-plugins-dependencies
5. Mise à jour de .packages
6. Assets enregistrés pour le build
```

#### Vérification de l'enregistrement

**Commande :**
```bash
flutter pub get
```

**Logs à vérifier :**
```
Running "flutter pub get" in projetrecette...
Resolving dependencies...
Got dependencies!
```

Aucune erreur = Assets correctement enregistrés

---

## Tests et validation

### Test 1 : Vérification de l'existence du fichier

**Commande PowerShell :**
```powershell
Test-Path assets/images/chef.png
```

**Résultat attendu :** `True`

**Si False :**
- Fichier non téléchargé
- Chemin incorrect
- Recréer avec Invoke-WebRequest

### Test 2 : Vérification de la taille

```powershell
(Get-Item assets/images/chef.png).Length
```

**Résultat attendu :** `129098` (bytes)

**Si différent :**
- Téléchargement corrompu
- Retélécharger l'image

### Test 3 : Build de l'application

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

**Points de vérification :**
1. Pas d'erreur lors de `flutter pub get`
2. Pas d'erreur lors de `flutter run`
3. Application démarre correctement
4. Image visible dans le banner

### Test 4 : Inspection du bundle

**Vérification des assets empaquetés :**

```powershell
Get-Content build/flutter_assets/AssetManifest.json | ConvertFrom-Json
```

**Contenu attendu :**
```json
{
  "assets/images/chef.png": ["assets/images/chef.png"],
  "packages/iconsax/icons/bold/...": [...]
}
```

### Test 5 : DevTools Network

**Dans Chrome DevTools :**
1. F12 pour ouvrir
2. Onglet "Network"
3. Actualiser la page (F5)
4. Filtrer par "Img"

**Résultat attendu :**
- Aucune requête vers pngimg.com
- Pas d'erreur CORS
- Image chargée depuis le bundle local

---

## Bonnes pratiques

### Gestion des assets

#### 1. Organisation des dossiers

**Structure recommandée :**
```
assets/
├── images/
│   ├── backgrounds/
│   ├── icons/
│   ├── logos/
│   └── chef.png
├── fonts/
│   └── custom_font.ttf
└── data/
    └── categories.json
```

#### 2. Nommage des fichiers

**Conventions :**
- Tout en minuscules
- Underscores pour les espaces : `chef_icon.png`
- Pas de caractères spéciaux
- Extensions en minuscules : `.png`, `.jpg`

**Exemples :**
- Bon : `chef_cooking.png`
- Mauvais : `Chef Cooking.PNG`

#### 3. Formats d'image

**PNG :**
- Transparence supportée
- Bonne qualité
- Taille moyenne
- Idéal pour icônes, logos

**JPG/JPEG :**
- Pas de transparence
- Compression avec perte
- Taille réduite
- Idéal pour photos

**WebP :**
- Meilleure compression
- Transparence supportée
- Pas supporté partout
- Vérifier compatibilité

**SVG :**
- Vectoriel
- Scalable sans perte
- Package requis : `flutter_svg`

#### 4. Optimisation des images

**Avant ajout dans assets :**

1. **Compression**
   - Outils : TinyPNG, ImageOptim
   - Réduction 50-70% sans perte visible

2. **Dimensionnement**
   - Taille maximale affichée : 180px
   - Image source : ~360px (pour 2x)
   - Pas besoin de 2000px

3. **Format approprié**
   - Transparence nécessaire : PNG
   - Photo : JPG
   - Icône simple : SVG (avec package)

### Migration d'autres images réseau

#### Checklist

Si vous avez d'autres `Image.network()` :

- [ ] Identifier toutes les occurrences
  ```bash
  grep -r "Image.network" lib/
  ```

- [ ] Télécharger les images
  ```powershell
  Invoke-WebRequest -Uri "URL" -OutFile "assets/images/nom.png"
  ```

- [ ] Ajouter au pubspec.yaml (déjà fait si dossier assets/)

- [ ] Remplacer le code
  ```dart
  Image.asset("assets/images/nom.png")
  ```

- [ ] Tester sur toutes les plateformes

#### Script de migration automatique

**PowerShell :**
```powershell
# Liste des images à télécharger
$images = @(
    @{url="https://example.com/image1.png"; name="image1.png"},
    @{url="https://example.com/image2.png"; name="image2.png"}
)

foreach ($img in $images) {
    Invoke-WebRequest -Uri $img.url -OutFile "assets/images/$($img.name)"
    Write-Host "Downloaded: $($img.name)"
}
```

### Cache des images réseau

**Si vous devez garder Image.network() :**

```dart
Image.network(
  "https://example.com/image.png",
  cacheWidth: 500,  // Optimisation mémoire
  cacheHeight: 500,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.error);  // Fallback
  },
)
```

**Package pour cache avancé :**
```yaml
dependencies:
  cached_network_image: ^3.3.0
```

**Utilisation :**
```dart
CachedNetworkImage(
  imageUrl: "https://example.com/image.png",
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

---

## Impact sur les plateformes

### Flutter Web

**Avant (avec Image.network) :**
- Problème CORS
- Dépendance réseau
- Temps de chargement variable

**Après (avec Image.asset) :**
- Pas de CORS
- Chargé avec l'application
- Instantané

**Taille du bundle Web :**
```
build/web/
├── main.dart.js    (~1-2 MB avec optimisation)
├── flutter_service_worker.js
└── assets/
    └── assets/images/chef.png (129 KB)
```

**Total augmentation :** +129 KB

### Flutter Mobile (Android/iOS)

**Impact minimal :**
- Image déjà incluse dans l'APK/IPA
- Pas de CORS de toute façon
- Légère augmentation de la taille de l'app

**APK/IPA size :**
- Avant : ~15-20 MB
- Après : ~15.1-20.1 MB (+129 KB)

### Flutter Desktop (Windows/Mac/Linux)

**Aucun impact négatif :**
- Assets copiés dans le dossier de build
- Chargement local ultra-rapide

---

## Alternatives non retenues

### Alternative 1 : CORS Proxy

**Concept :**
Utiliser un serveur proxy qui ajoute les headers CORS.

**Implémentation :**
```dart
Image.network(
  "https://cors-anywhere.herokuapp.com/https://pngimg.com/d/chef_PNG190.png",
)
```

**Pourquoi non retenu :**
- Dépendance à un service tiers
- Latence supplémentaire
- Service peut être down
- Pas recommandé en production

### Alternative 2 : Backend proxy

**Concept :**
Créer un endpoint sur votre backend qui proxy l'image.

**Implémentation :**
```dart
Image.network(
  "https://votreapi.com/proxy-image?url=https://pngimg.com/...",
)
```

**Pourquoi non retenu :**
- Complexité excessive pour une image statique
- Coût serveur
- Latence augmentée
- Maintenance supplémentaire

### Alternative 3 : Base64 embedded

**Concept :**
Encoder l'image en Base64 et l'inclure directement dans le code.

**Implémentation :**
```dart
Image.memory(
  base64Decode("iVBORw0KGgoAAAANSUhEUgAA..."),
)
```

**Pourquoi non retenu :**
- Code source extrêmement long
- Difficile à maintenir
- Pas de bénéfice par rapport aux assets
- Pollution du code

### Alternative 4 : Firebase Storage

**Concept :**
Upload l'image sur Firebase Storage et la charger depuis là.

**Implémentation :**
```dart
Image.network(
  "https://firebasestorage.googleapis.com/v0/b/project/o/chef.png?alt=media",
)
```

**Pourquoi non retenu :**
- Configuration supplémentaire
- Coût de stockage
- Dépendance réseau maintenue
- Pas nécessaire pour image statique

---

## Commits Git liés

### Commit 1 : Ajout de l'image et configuration

```bash
commit 78d4460
Author: ...
Date: 27 octobre 2025

ajout de la partie statique 1 de la page home

Fichiers modifiés:
- assets/images/chef.png (nouveau)
- pubspec.yaml (assets ajoutés)
- lib/Views/app_main_screen.dart (Image.asset)
```

**Détails du commit :**
- 17 fichiers modifiés
- 577 insertions, 29 suppressions
- Nouveaux fichiers : assets/, firebase config
- Image du chef : 129,098 bytes

---

## Dépannage

### Problème : Image ne s'affiche pas après migration

#### Cause 1 : Assets non enregistrés

**Vérification :**
```bash
flutter pub get
```

**Si erreur :**
```
Error: Unable to load asset: assets/images/chef.png
```

**Solution :**
- Vérifier le chemin dans pubspec.yaml
- Vérifier l'indentation
- Relancer `flutter pub get`

#### Cause 2 : Fichier manquant

**Vérification :**
```powershell
Test-Path assets/images/chef.png
```

**Si False :**
```powershell
Invoke-WebRequest -Uri "https://pngimg.com/d/chef_PNG190.png" -OutFile "assets/images/chef.png"
```

#### Cause 3 : Cache de build

**Solution :**
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

#### Cause 4 : Hot reload insuffisant

**Après modification du pubspec.yaml :**
- Hot reload (r) : Ne suffit PAS
- Hot restart (R) : Ne suffit PAS
- Full restart requis : Arrêter (q) et relancer

### Problème : Erreur "assets/assets/images/chef.png"

#### Symptôme

```
Error while trying to load an asset: Flutter Web engine failed to fetch "assets/assets/images/chef.png"
```

#### Cause

**Double "assets" dans le chemin**

Possible si dans le code :
```dart
Image.asset("assets/assets/images/chef.png")  // ERREUR
```

Ou dans pubspec.yaml :
```yaml
assets:
  - assets/assets/images/  # ERREUR
```

#### Solution

**Dans le code :**
```dart
Image.asset("assets/images/chef.png")  // CORRECT
```

**Dans pubspec.yaml :**
```yaml
assets:
  - assets/images/  # CORRECT
```

---

## Performance

### Comparaison de performance

#### Image.network

**Temps de chargement :**
```
1. Requête DNS         : ~50-100ms
2. Connexion TCP       : ~50-100ms
3. SSL Handshake       : ~100-200ms
4. Requête HTTP        : ~50-100ms
5. Téléchargement      : ~200-500ms (selon connexion)
6. Décodage           : ~50-100ms
Total                 : ~500-1100ms (0.5-1.1s)
```

**Utilisation réseau :**
- 129 KB par chargement
- Multiplié par le nombre de vues de la page

#### Image.asset

**Temps de chargement :**
```
1. Lecture du bundle   : ~10-20ms
2. Décodage           : ~50-100ms
Total                 : ~60-120ms (0.06-0.12s)
```

**Utilisation réseau :**
- 0 KB (déjà dans l'application)

**Gain de performance :** ~8-10x plus rapide

### Optimisation du build Web

#### Tree-shaking des icônes

**Problème rencontré lors du build :**
```
Font subsetting failed with exit code -1
```

**Solution :**
```bash
flutter build web --no-tree-shake-icons
```

**Explication :**
- Tree-shaking : Suppression des icônes non utilisées
- Bug avec certaines versions Flutter
- --no-tree-shake-icons : Désactive l'optimisation
- Impact : Bundle légèrement plus gros (~200 KB)

#### Taille finale du build

**Commande :**
```bash
flutter build web --release --no-tree-shake-icons
```

**Résultat :**
```
build/web/
├── main.dart.js (~1.5 MB)
├── assets/ (~500 KB)
└── ... autres fichiers
Total: ~3-4 MB
```

---

## Documentation de référence

### Flutter Assets

- Guide officiel : https://docs.flutter.dev/ui/assets/assets-and-images
- pubspec.yaml : https://dart.dev/tools/pub/pubspec
- Image class : https://api.flutter.dev/flutter/widgets/Image-class.html

### CORS

- MDN CORS : https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
- Flutter Web CORS : https://docs.flutter.dev/platform-integration/web/faq

### Formats d'image

- PNG Specification : http://www.libpng.org/pub/png/spec/1.2/
- Image optimization : https://web.dev/fast/#optimize-your-images

---

**Fin du document**

Document suivant : [09-CONFIGURATION_FIREBASE_COMPLETE.md](09-CONFIGURATION_FIREBASE_COMPLETE.md)

