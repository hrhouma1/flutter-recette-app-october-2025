import '../Models/category_model.dart';
import 'firestore_service.dart';

class InitCategories {
  static final FirestoreService _firestoreService = FirestoreService();

  // Liste des catégories par défaut pour une application de recettes
  static List<CategoryModel> getDefaultCategories() {
    return [
      CategoryModel(
        id: '',
        name: 'Breakfast',
        icon: '🍳',
        color: 'FFE8B4',
      ),
      CategoryModel(
        id: '',
        name: 'Lunch',
        icon: '🍱',
        color: 'FFC4E1',
      ),
      CategoryModel(
        id: '',
        name: 'Dinner',
        icon: '🍽️',
        color: 'C4E1FF',
      ),
      CategoryModel(
        id: '',
        name: 'Desserts',
        icon: '🍰',
        color: 'FFD4D4',
      ),
      CategoryModel(
        id: '',
        name: 'Appetizers',
        icon: '🥗',
        color: 'D4FFD4',
      ),
      CategoryModel(
        id: '',
        name: 'Soups',
        icon: '🍲',
        color: 'FFE4C4',
      ),
      CategoryModel(
        id: '',
        name: 'Beverages',
        icon: '🥤',
        color: 'E4C4FF',
      ),
      CategoryModel(
        id: '',
        name: 'Snacks',
        icon: '🍿',
        color: 'FFFACD',
      ),
      CategoryModel(
        id: '',
        name: 'Vegetarian',
        icon: '🥬',
        color: 'C8E6C9',
      ),
      CategoryModel(
        id: '',
        name: 'Seafood',
        icon: '🦐',
        color: 'B3E5FC',
      ),
      CategoryModel(
        id: '',
        name: 'Pasta',
        icon: '🍝',
        color: 'FFCCBC',
      ),
      CategoryModel(
        id: '',
        name: 'Pizza',
        icon: '🍕',
        color: 'FFE0B2',
      ),
    ];
  }

  // Initialiser les catégories dans Firestore
  static Future<void> initializeCategories({bool force = false}) async {
    try {
      // Vérifier si les catégories existent déjà
      if (!force) {
        bool exist = await _firestoreService.categoriesExist();
        if (exist) {
          print('ℹ️ Les catégories existent déjà. Utilisez force=true pour réinitialiser.');
          return;
        }
      }

      // Obtenir les catégories par défaut
      List<CategoryModel> defaultCategories = getDefaultCategories();

      // Ajouter les catégories dans Firestore
      await _firestoreService.addMultipleCategories(defaultCategories);
      
      print('✅ Initialisation des catégories terminée avec succès!');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation des catégories: $e');
    }
  }
}

