import 'package:flutter/material.dart';
import '../Services/init_categories.dart';
import '../constants.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isLoading = false;
  String _message = '';

  Future<void> _initializeCategories({bool force = false}) async {
    setState(() {
      _isLoading = true;
      _message = 'Initialisation en cours...';
    });

    try {
      await InitCategories.initializeCategories(force: force);
      setState(() {
        _isLoading = false;
        _message = '✅ Catégories ajoutées avec succès!';
      });

      // Afficher un SnackBar de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catégories initialisées avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = '❌ Erreur: $e';
      });

      // Afficher un SnackBar d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: kprimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gestion des Données',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Initialisez les catégories par défaut dans Firestore',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            
            // Carte d'information
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: kprimaryColor),
                        const SizedBox(width: 10),
                        const Text(
                          'Catégories à ajouter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildCategoryChip('🍳 Breakfast'),
                    _buildCategoryChip('🍱 Lunch'),
                    _buildCategoryChip('🍽️ Dinner'),
                    _buildCategoryChip('🍰 Desserts'),
                    _buildCategoryChip('🥗 Appetizers'),
                    _buildCategoryChip('🍲 Soups'),
                    _buildCategoryChip('🥤 Beverages'),
                    _buildCategoryChip('🍿 Snacks'),
                    const Text(
                      '... et 4 autres catégories',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Bouton d'initialisation
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _initializeCategories(force: false),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(
                _isLoading ? 'Initialisation...' : 'Initialiser les catégories',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kprimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Bouton de réinitialisation forcée
            OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      // Demander confirmation
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmation'),
                          content: const Text(
                            'Êtes-vous sûr de vouloir réinitialiser les catégories? '
                            'Cela ajoutera les catégories même si elles existent déjà.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _initializeCategories(force: true);
                              },
                              child: const Text('Confirmer'),
                            ),
                          ],
                        ),
                      );
                    },
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Forcer la réinitialisation',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: const BorderSide(color: Colors.orange),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Message de statut
            if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _message.contains('✅')
                      ? Colors.green.shade50
                      : _message.contains('❌')
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _message.contains('✅')
                        ? Colors.green
                        : _message.contains('❌')
                            ? Colors.red
                            : Colors.blue,
                  ),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    fontSize: 14,
                    color: _message.contains('✅')
                        ? Colors.green.shade900
                        : _message.contains('❌')
                            ? Colors.red.shade900
                            : Colors.blue.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

