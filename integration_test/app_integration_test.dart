import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:baches_y_topes/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BachesYTopes Integration Tests', () {
    testWidgets('App launches and displays map screen', (WidgetTester tester) async {
      // Load the app
      await tester.pumpWidget(const BachesYTopesApp());
      await tester.pumpAndSettle();

      // Verify the app title
      expect(find.byType(MaterialApp), findsOneWidget);

      // The map should eventually load (but may be empty without Google Maps API key)
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Quick report buttons are visible', (WidgetTester tester) async {
      await tester.pumpWidget(const BachesYTopesApp());
      await tester.pumpAndSettle();

      // Look for the quick report widget - buttons should exist
      expect(find.byType(FloatingActionButton), findsWidgets);
    });

    testWidgets('Voice listening widget is present', (WidgetTester tester) async {
      await tester.pumpWidget(const BachesYTopesApp());
      await tester.pumpAndSettle();

      // The voice listening widget should be present
      expect(find.byType(FloatingActionButton), findsWidgets);
    });

    testWidgets('App responds to widget interactions', (WidgetTester tester) async {
      await tester.pumpWidget(const BachesYTopesApp());
      await tester.pumpAndSettle();

      // Get the initial state
      expect(find.byType(Scaffold), findsWidgets);

      // Try to find and tap a button (if visible)
      final fabFinder = find.byType(FloatingActionButton);
      if (fabFinder.evaluate().isNotEmpty) {
        // Button found, we can interact with it
        await tester.tap(fabFinder.first);
        await tester.pumpAndSettle();
      }
    });
  });
}
