// Test de base pour l'application de recettes
//
// Ce test vérifie que l'application se charge correctement
// et que les éléments principaux sont présents.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projetrecette/main.dart';

void main() {
  testWidgets('App loads and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the home screen loads
    expect(find.text('What are you\ncooking today?'), findsOneWidget);
    
    // Verify that the search bar is present
    expect(find.text('Search any recipes'), findsOneWidget);
    
    // Verify that Categories section is present
    expect(find.text('Categories'), findsOneWidget);
  });

  testWidgets('Bottom navigation bar is present', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Verify bottom navigation items are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('Meal Plan'), findsOneWidget);
    expect(find.text('Setting'), findsOneWidget);
  });
}
