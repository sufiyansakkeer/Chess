import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../application/game_state_manager.dart';
import '../presenters/game_presenter.dart';
import '../widgets/chess_board.dart';
import '../providers/theme_provider.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GamePresenter(GameStateManager()),
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
            Consumer<ThemeProvider>(
              builder:
                  (context, themeProvider, _) => IconButton(
                    icon: Icon(
                      themeProvider.themeMode == ThemeMode.light
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    onPressed: themeProvider.toggleTheme,
                  ),
            ),
            Consumer<ThemeProvider>(
              builder:
                  (context, themeProvider, _) => PopupMenuButton<String>(
                    icon: const Icon(Icons.palette),
                    onSelected: (String style) {
                      themeProvider.setThemeStyle(style);
                    },
                    itemBuilder:
                        (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'classic',
                            child: Text('Classic'),
                          ),
                          const PopupMenuItem(
                            value: 'modern',
                            child: Text('Modern'),
                          ),
                          const PopupMenuItem(
                            value: 'forest',
                            child: Text('Forest'),
                          ),
                          const PopupMenuItem(
                            value: 'ocean',
                            child: Text('Ocean'),
                          ),
                          const PopupMenuItem(
                            value: 'sunset',
                            child: Text('Sunset'),
                          ),
                          const PopupMenuItem(
                            value: 'minimalist',
                            child: Text('Minimalist'),
                          ),
                        ],
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
                    const SizedBox(height: 16),
                    Consumer<GamePresenter>(
                      builder:
                          (context, presenter, _) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCapturedPieces(
                                context,
                                presenter.gameState.whiteCapturedPieces,
                                'White',
                              ),
                              _buildCapturedPieces(
                                context,
                                presenter.gameState.blackCapturedPieces,
                                'Black',
                              ),
                            ],
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

  Widget _buildCapturedPieces(BuildContext context, List pieces, String color) {
    return Column(
      children: [
        Text(
          '$color Captured Pieces',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Wrap(
          children:
              pieces.map((piece) {
                return SizedBox(
                  width: 30,
                  height: 30,
                  child: SvgPicture.asset(
                    'assets/${piece.color.toString().split('.').last}_${piece.type.toString().split('.').last}.svg',
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
