# Guide Rapide - Ajout Manuel des Catégories dans Firebase Console

## Instructions pour l'administrateur

### Étape 1 : Accéder à Firebase Console

1. Ouvrez : https://console.firebase.google.com
2. Sélectionnez le projet : **flutter-recette-october-2025**
3. Dans le menu gauche, cliquez sur **"Firestore Database"**

### Étape 2 : Créer la collection "categories"

1. Cliquez sur **"Ajouter une collection"** ou **"Start collection"**
2. Nom de la collection : `categories`
3. Cliquez sur **"Suivant"**

### Étape 3 : Ajouter les 12 catégories

Pour chaque catégorie ci-dessous, créez un nouveau document avec ces 3 champs :
- **name** (type: string)
- **icon** (type: string)  
- **color** (type: string)

**Laissez l'ID du document vide** (généré automatiquement)

---

## Liste des 12 catégories à ajouter

### Catégorie 1
```
name   : Breakfast
icon   : 🍳
color  : FFE8B4
```

### Catégorie 2
```
name   : Lunch
icon   : 🍱
color  : FFC4E1
```

### Catégorie 3
```
name   : Dinner
icon   : 🍽️
color  : C4E1FF
```

### Catégorie 4
```
name   : Desserts
icon   : 🍰
color  : FFD4D4
```

### Catégorie 5
```
name   : Appetizers
icon   : 🥗
color  : D4FFD4
```

### Catégorie 6
```
name   : Soups
icon   : 🍲
color  : FFE4C4
```

### Catégorie 7
```
name   : Beverages
icon   : 🥤
color  : E4C4FF
```

### Catégorie 8
```
name   : Snacks
icon   : 🍿
color  : FFFACD
```

### Catégorie 9
```
name   : Vegetarian
icon   : 🥬
color  : C8E6C9
```

### Catégorie 10
```
name   : Seafood
icon   : 🦐
color  : B3E5FC
```

### Catégorie 11
```
name   : Pasta
icon   : 🍝
color  : FFCCBC
```

### Catégorie 12
```
name   : Pizza
icon   : 🍕
color  : FFE0B2
```

---

## Vérification

Après avoir ajouté toutes les catégories :

1. **Dans Firebase Console** : Vous devez voir 12 documents dans la collection "categories"
2. **Dans l'application** : 
   - Rafraîchissez la page (F5)
   - Allez dans Settings > Test Firebase
   - Cliquez sur "Refaire les tests"
   - Vous devriez voir "TOUS LES TESTS RÉUSSIS"

---

## Règles Firestore (Déjà déployées)

Les règles actuelles permettent la lecture et l'écriture complètes :

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

**Note de sécurité :** En production, vous devrez restreindre ces règles.

---

## Temps estimé

- **5-10 minutes** pour ajouter les 12 catégories manuellement

---

## Alternative Automatisée (Pour plus tard)

Si vous souhaitez automatiser ce processus à l'avenir :

### Option 1 : Via l'application Flutter
1. Lancez l'application : `flutter run -d chrome`
2. Allez dans Settings > Administration
3. Cliquez sur "Initialiser les catégories"

### Option 2 : Avec Google Cloud SDK
```bash
# Installer gcloud SDK
winget install Google.CloudSDK

# Puis utiliser les scripts dans le dossier /scripts
```

---

## Support

Si vous rencontrez des problèmes :

1. **Vérifiez les règles Firestore** dans Firebase Console
2. **Testez la connexion** dans l'application (Settings > Test Firebase)
3. **Consultez les logs** dans le terminal où tourne l'application

---

**Document créé le :** 27 octobre 2025  
**Projet :** flutter-recette-october-2025

