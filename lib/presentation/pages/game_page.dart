import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/game_state_impl.dart';
import '../presenters/game_presenter.dart';
import '../widgets/chess_board.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GamePresenter(GameStateImpl()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chess Game'),
          actions: [
            Consumer<GamePresenter>(
              builder:
                  (context, presenter, _) => IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: presenter.resetGame,
                  ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<GamePresenter>(
                      builder: (context, presenter, _) {
                        if (presenter.gameState.isGameOver) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              presenter.winner != null
                                  ? '${presenter.winner} wins!'
                                  : 'Game Over - Draw!',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          );
                        } else if (presenter.gameState.isKingInCheck) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${presenter.currentTurn.toString().split('.').last.toUpperCase()} King is in CHECK!',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox(height: 16);
                      },
                    ),
                    Consumer<GamePresenter>(
                      builder:
                          (context, presenter, _) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Current Turn: ${presenter.currentTurn.toString().split('.').last.toUpperCase()}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                    ),
                    const SizedBox(height: 8),
                    const ChessBoard(),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: Consumer<GamePresenter>(
                        builder: (context, presenter, _) {
                          return ListView.builder(
                            itemCount: presenter.moveHistory.length,
                            itemBuilder: (context, index) {
                              return Text(presenter.moveHistory[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
