import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chess/main.dart';
import 'package:chess/presentation/pages/game_page.dart';
import 'package:chess/domain/entities/pieces/king.dart';
import 'package:chess/domain/entities/pieces/queen.dart';
import 'package:chess/domain/value_objects/piece_color.dart';
import 'package:chess/domain/value_objects/position.dart';
import 'package:chess/application/game_state_impl.dart';
import 'package:provider/provider.dart';
import 'package:chess/presentation/presenters/game_presenter.dart';

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

  testWidgets('Check message is displayed when king is in check', (
    WidgetTester tester,
  ) async {
    // Build the GamePage widget with a GamePresenter
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (context) => GamePresenter(GameStateImpl()),
          child: GamePage(),
        ),
      ),
    );

    // Get the GamePresenter instance from the widget tree using Provider.of
    final gamePageFinder = find.byType(GamePage);
    final gamePresenter = Provider.of<GamePresenter>(
      tester.element(gamePageFinder),
      listen: false,
    );

    // Simulate a state where the king is in check
    gamePresenter.gameState.board[7][4] = King(
      color: PieceColor.white,
      position: Position(7, 4),
    );
    gamePresenter.gameState.board[5][4] = Queen(
      color: PieceColor.black,
      position: Position(5, 4),
    );
    gamePresenter.gameState.isKingInCheck;

    // Force a rebuild of the widget tree
    await tester.pump();

    // Verify that the check message is displayed
    expect(find.text('WHITE King is in CHECK!'), findsOneWidget);
  });
}
