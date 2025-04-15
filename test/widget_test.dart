// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chess/main.dart';
import 'package:chess/presentation/pages/game_page.dart';

void main() {
  testWidgets('Chess game initial layout test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ChessApp());

    // Verify that the game page is rendered
    expect(find.byType(GamePage), findsOneWidget);

    // Verify that the chess board is rendered
    expect(find.byType(GridView), findsOneWidget);

    // Verify that the app title is displayed
    expect(find.text('Chess Game'), findsOneWidget);
  });
}
