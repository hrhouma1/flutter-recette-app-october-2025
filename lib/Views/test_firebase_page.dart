import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class TestFirebasePage extends StatefulWidget {
  const TestFirebasePage({Key? key}) : super(key: key);

  @override
  State<TestFirebasePage> createState() => _TestFirebasePageState();
}

class _TestFirebasePageState extends State<TestFirebasePage> {
  String _connectionStatus = 'Vérification en cours...';
  String _projectId = '';
  bool _isConnected = false;
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  Future<void> _testFirebaseConnection() async {
    try {
      // Test 1: Vérifier que Firebase est initialisé
      setState(() {
        _connectionStatus = 'Test 1: Vérification de Firebase...';
      });

      final app = Firebase.app();
      final projectId = app.options.projectId;

      setState(() {
        _projectId = projectId;
        _connectionStatus = 'Test 1: Firebase initialisé ✅\nProjet: $projectId';
      });

      await Future.delayed(const Duration(seconds: 1));

      // Test 2: Vérifier la connexion Firestore
      setState(() {
        _connectionStatus += '\n\nTest 2: Test de connexion Firestore...';
      });

      final firestore = FirebaseFirestore.instance;
      
      // Tenter de lire une collection (même vide)
      final snapshot = await firestore
          .collection('categories')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      setState(() {
        _connectionStatus += '\n✅ Connexion Firestore réussie!';
        _connectionStatus += '\n\nDocuments trouvés: ${snapshot.docs.length}';
      });

      await Future.delayed(const Duration(seconds: 1));

      // Test 3: Essayer d'écrire un document de test
      setState(() {
        _connectionStatus += '\n\nTest 3: Test d\'écriture...';
      });

      await firestore.collection('_test_connection').doc('test').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Test de connexion',
      });

      // Supprimer le document de test
      await firestore.collection('_test_connection').doc('test').delete();

      setState(() {
        _connectionStatus += '\n✅ Écriture/Suppression réussie!';
        _isConnected = true;
        _testResult = 'TOUS LES TESTS RÉUSSIS';
      });
    } catch (e) {
      setState(() {
        _connectionStatus += '\n\n❌ ERREUR: $e';
        _isConnected = false;
        _testResult = 'ÉCHEC DE LA CONNEXION';
      });
    }
  }

  Future<void> _testAddCategory() async {
    setState(() {
      _testResult = 'Ajout d\'une catégorie de test...';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      await firestore.collection('categories').add({
        'name': 'Test Category',
        'icon': '🧪',
        'color': 'FF0000',
      });

      setState(() {
        _testResult = '✅ Catégorie de test ajoutée avec succès!';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firebase'),
        backgroundColor: kprimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                elevation: 3,
                color: _isConnected ? Colors.green.shade50 : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isConnected ? Icons.check_circle : Icons.info,
                            color: _isConnected ? Colors.green : Colors.orange,
                            size: 32,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _testResult.isEmpty ? 'Tests en cours...' : _testResult,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _isConnected ? Colors.green.shade900 : Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_projectId.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        Text(
                          'Projet Firebase:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SelectableText(
                          _projectId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // Résultats détaillés
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Résultats des tests:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SelectableText(
                        _connectionStatus,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Boutons de test
              if (_isConnected) ...[
                ElevatedButton.icon(
                  onPressed: _testAddCategory,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une catégorie de test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kprimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                const SizedBox(height: 15),
              ],

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _connectionStatus = 'Vérification en cours...';
                    _testResult = '';
                    _isConnected = false;
                  });
                  _testFirebaseConnection();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refaire les tests'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kprimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

