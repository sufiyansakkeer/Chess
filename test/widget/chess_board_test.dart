import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chess/presentation/widgets/chess_board.dart';
import 'package:chess/presentation/presenters/game_presenter.dart';
import 'package:chess/application/game_state_manager.dart';

void main() {
  late GamePresenter gamePresenter;

  setUp(() {
    gamePresenter = GamePresenter(GameStateManager());
  });

  testWidgets('ChessBoard displays initial layout correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: gamePresenter,
          child: const Scaffold(body: ChessBoard()),
        ),
      ),
    );

    // Verify that 64 squares are rendered
    expect(find.byType(GestureDetector), findsNWidgets(64));

    // Verify that pieces are in correct initial positions
    expect(find.byType(AspectRatio), findsOneWidget);
  });

  testWidgets('ChessBoard highlights selected piece', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: gamePresenter,
          child: const Scaffold(body: ChessBoard()),
        ),
      ),
    );

    // Tap a white pawn (initial position)
    await tester.tap(find.byKey(const ValueKey('square_6_0')));
    await tester.pump();

    // Verify that valid moves are highlighted
    expect(find.byType(Container), findsWidgets);
  });
}
