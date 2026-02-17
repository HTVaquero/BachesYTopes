// This is a basic Flutter widget test for BachesYTopes app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baches_y_topes/main.dart';

void main() {
  testWidgets('BachesYTopes app launches and displays map', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BachesYTopesApp());

    // Verify that the app title exists
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify that the map screen is displayed
    expect(find.byType(Scaffold), findsWidgets);
  });
}
