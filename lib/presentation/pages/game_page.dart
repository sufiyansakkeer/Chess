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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<GamePresenter>(
                  builder: (context, presenter, _) {
                    if (presenter.isGameOver) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          presenter.winner != null
                              ? '${presenter.winner} wins!'
                              : 'Game Over - Draw!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 20),
                const ChessBoard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
