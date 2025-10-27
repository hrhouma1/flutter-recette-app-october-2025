#!/usr/bin/env dart

// Script pour ajouter les catégories dans Firestore
// Utilisation: dart run tool/add_categories.dart

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Configuration Firebase pour Web
const firebaseConfig = {
  'apiKey': 'AIzaSyBmYg5-3PoffTGqShhVKrTsylxnHz1-XNs',
  'appId': '1:378029160591:web:59be5d6b6a08a141db98fa',
  'messagingSenderId': '378029160591',
  'projectId': 'flutter-recette-october-2025',
  'authDomain': 'flutter-recette-october-2025.firebaseapp.com',
  'storageBucket': 'flutter-recette-october-2025.firebasestorage.app',
};

final categories = [
  {'name': 'Breakfast', 'icon': '🍳', 'color': 'FFE8B4'},
  {'name': 'Lunch', 'icon': '🍱', 'color': 'FFC4E1'},
  {'name': 'Dinner', 'icon': '🍽️', 'color': 'C4E1FF'},
  {'name': 'Desserts', 'icon': '🍰', 'color': 'FFD4D4'},
  {'name': 'Appetizers', 'icon': '🥗', 'color': 'D4FFD4'},
  {'name': 'Soups', 'icon': '🍲', 'color': 'FFE4C4'},
  {'name': 'Beverages', 'icon': '🥤', 'color': 'E4C4FF'},
  {'name': 'Snacks', 'icon': '🍿', 'color': 'FFFACD'},
  {'name': 'Vegetarian', 'icon': '🥬', 'color': 'C8E6C9'},
  {'name': 'Seafood', 'icon': '🦐', 'color': 'B3E5FC'},
  {'name': 'Pasta', 'icon': '🍝', 'color': 'FFCCBC'},
  {'name': 'Pizza', 'icon': '🍕', 'color': 'FFE0B2'},
];

Future<void> main() async {
  print('🔧 Initialisation de Firebase...');
  
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: firebaseConfig['apiKey']!,
        appId: firebaseConfig['appId']!,
        messagingSenderId: firebaseConfig['messagingSenderId']!,
        projectId: firebaseConfig['projectId']!,
        authDomain: firebaseConfig['authDomain']!,
        storageBucket: firebaseConfig['storageBucket']!,
      ),
    );
    
    print('✅ Firebase initialisé avec succès');
    print('📝 Ajout de ${categories.length} catégories...\n');
    
    final firestore = FirebaseFirestore.instance;
    
    // Utiliser un batch pour plus d'efficacité
    final batch = firestore.batch();
    
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      final docRef = firestore.collection('categories').doc();
      batch.set(docRef, category);
      print('   ${i + 1}. ${category['name']}');
    }
    
    print('\n⏳ Commit du batch...');
    await batch.commit();
    
    print('✅ Toutes les catégories ont été ajoutées avec succès!');
    
    // Vérification
    final snapshot = await firestore.collection('categories').get();
    print('\n📊 Total de catégories dans Firestore: ${snapshot.docs.length}');
    
    print('\n🎉 TERMINÉ!');
    exit(0);
    
  } catch (e) {
    print('\n❌ ERREUR: $e');
    print('\nℹ️  Solution alternative:');
    print('   Lancez l\'application et allez dans Settings > Administration');
    exit(1);
  }
}

