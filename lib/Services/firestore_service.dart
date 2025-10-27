import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/category_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection de catégories
  CollectionReference get categoriesCollection =>
      _firestore.collection('categories');

  // Ajouter une catégorie
  Future<void> addCategory(CategoryModel category) async {
    try {
      await categoriesCollection.add(category.toMap());
      print('✅ Catégorie "${category.name}" ajoutée avec succès');
    } catch (e) {
      print('❌ Erreur lors de l\'ajout de la catégorie: $e');
    }
  }

  // Ajouter plusieurs catégories
  Future<void> addMultipleCategories(List<CategoryModel> categories) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (var category in categories) {
        DocumentReference docRef = categoriesCollection.doc();
        batch.set(docRef, category.toMap());
      }
      
      await batch.commit();
      print('✅ ${categories.length} catégories ajoutées avec succès');
    } catch (e) {
      print('❌ Erreur lors de l\'ajout des catégories: $e');
    }
  }

  // Récupérer toutes les catégories
  Future<List<CategoryModel>> getCategories() async {
    try {
      QuerySnapshot snapshot = await categoriesCollection.get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      print('❌ Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }

  // Vérifier si les catégories existent déjà
  Future<bool> categoriesExist() async {
    try {
      QuerySnapshot snapshot = await categoriesCollection.limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Erreur lors de la vérification des catégories: $e');
      return false;
    }
  }
}

