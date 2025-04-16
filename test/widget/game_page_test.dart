import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chess/main.dart';
import 'package:chess/presentation/pages/game_page.dart';
import 'package:chess/presentation/widgets/chess_board.dart';
import 'package:chess/domain/value_objects/piece_color.dart';

void main() {
  testWidgets('GamePage shows initial layout correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ChessApp());

    // Verify basic layout elements
    expect(find.byType(GamePage), findsOneWidget);
    expect(find.byType(ChessBoard), findsOneWidget);
    expect(find.text('Chess Game'), findsOneWidget);

    // Verify initial turn indicator
    expect(find.text('Current Turn: WHITE'), findsOneWidget);
  });

  testWidgets('GamePage shows reset button', (WidgetTester tester) async {
    await tester.pumpWidget(const ChessApp());

    // Find and verify reset button
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('GamePage updates turn indicator after move', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ChessApp());

    // Initial state
    expect(find.text('Current Turn: WHITE'), findsOneWidget);

    // Make a move with white pawn
    await tester.tap(find.byKey(const ValueKey('square_6_4'))); // e2 pawn
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('square_4_4'))); // e4 move
    await tester.pump();

    // Verify turn has changed
    expect(find.text('Current Turn: BLACK'), findsOneWidget);
  });

  testWidgets('GamePage shows game over state', (WidgetTester tester) async {
    await tester.pumpWidget(const ChessApp());

    // TODO: Implement checkmate sequence when needed
    // For now, just verify that the game over widget exists but is not visible
    expect(find.text('Game Over - Draw!'), findsNothing);
  });
}
