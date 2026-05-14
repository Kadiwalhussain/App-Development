// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qr_code_scanner/main.dart';

void main() {
  testWidgets('Home page displays main features', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('QR Code Pro'), findsOneWidget);

    // Verify that main feature cards are present
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Generate'), findsOneWidget);
    expect(find.text('Templates'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);

    // Verify that the quick templates section exists
    expect(find.text('Quick Templates'), findsOneWidget);

    // Verify that theme toggle button exists
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    // Verify that history button in app bar exists
    expect(find.byIcon(Icons.history), findsNWidgets(2)); // One in app bar, one in feature card
  });

  testWidgets('Theme toggle changes icon', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Initially should show dark mode icon (to switch to dark mode)
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    // Tap the theme toggle button
    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    // After toggle, should show light mode icon (to switch to light mode)
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });
}
