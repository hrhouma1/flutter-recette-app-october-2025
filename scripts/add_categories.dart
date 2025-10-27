import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  print('🔧 Initialisation de Firebase...');
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  
  print('✅ Firebase initialisé');
  print('📝 Ajout des catégories...\n');

  final firestore = FirebaseFirestore.instance;
  
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

  try {
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      await firestore.collection('categories').add(category);
      print('✅ ${i + 1}/12 - ${category['name']} ajouté');
    }
    
    print('\n🎉 SUCCÈS ! Toutes les catégories ont été ajoutées');
    
    // Vérification
    final snapshot = await firestore.collection('categories').get();
    print('\n📊 Total de catégories dans Firestore: ${snapshot.docs.length}');
    
  } catch (e) {
    print('\n❌ ERREUR: $e');
  }
}

