import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/game_controller.dart';
import 'models/piece.dart';
import 'models/position.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(),
      child: MaterialApp(
        navigatorKey: GameController.navigatorKey,
        title: 'Chess Game',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const ChessBoard(),
      ),
    );
  }
}

class ChessBoard extends StatelessWidget {
  const ChessBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GameController>().resetGame();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<GameController>(
                  builder: (context, gameController, child) {
                    if (gameController.isGameOver) {
                      return Text(
                        gameController.winner != null
                            ? '${gameController.winner == PieceColor.white ? "White" : "Black"} wins!'
                            : 'Stalemate!',
                        style: Theme.of(context).textTheme.headlineMedium,
                      );
                    }
                    return Text(
                      '${gameController.currentTurn == PieceColor.white ? "White" : "Black"}\'s turn',
                      style: Theme.of(context).textTheme.headlineSmall,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Consumer<GameController>(
                        builder: (context, gameController, child) {
                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8,
                                ),
                            itemCount: 64,
                            itemBuilder: (context, index) {
                              final row = index ~/ 8;
                              final col = index % 8;
                              final isSelected =
                                  gameController.selectedPosition?.row == row &&
                                  gameController.selectedPosition?.col == col;
                              final isValidMove = gameController.possibleMoves
                                  .any(
                                    (pos) => pos.row == row && pos.col == col,
                                  );

                              return GestureDetector(
                                onTap: () {
                                  gameController.selectPosition(
                                    Position(row, col),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getSquareColor(
                                      row,
                                      col,
                                      isSelected,
                                      isValidMove,
                                    ),
                                  ),
                                  child: _buildPiece(
                                    gameController.board[row][col],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Consumer<GameController>(
            builder: (context, gameController, child) {
              return Container(
                width: 200,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Move History',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: (gameController.moveHistory.length + 1) ~/ 2,
                        itemBuilder: (context, index) {
                          final moveNumber = index + 1;
                          final whiteMove =
                              gameController.moveHistory[index * 2];
                          final blackMove =
                              index * 2 + 1 < gameController.moveHistory.length
                                  ? gameController.moveHistory[index * 2 + 1]
                                  : '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    '$moveNumber.',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(whiteMove)),
                                      Expanded(child: Text(blackMove)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getSquareColor(int row, int col, bool isSelected, bool isValidMove) {
    if (isSelected) {
      return Colors.blue.withOpacity(0.5);
    }
    if (isValidMove) {
      return Colors.green.withOpacity(0.3);
    }
    return (row + col) % 2 == 0 ? Colors.white : Colors.brown[300]!;
  }

  Widget _buildPiece(Piece? piece) {
    if (piece == null) return const SizedBox();

    IconData icon;
    switch (piece.type) {
      case PieceType.pawn:
        icon =
            piece.color == PieceColor.white
                ? Icons.person
                : Icons.person_outline;
        break;
      case PieceType.rook:
        icon = piece.color == PieceColor.white ? Icons.castle : Icons.fort;
        break;
      case PieceType.knight:
        icon =
            piece.color == PieceColor.white ? Icons.pets : Icons.pets_outlined;
        break;
      case PieceType.bishop:
        icon =
            piece.color == PieceColor.white
                ? Icons.account_balance
                : Icons.account_balance_outlined;
        break;
      case PieceType.queen:
        icon =
            piece.color == PieceColor.white
                ? Icons.diamond
                : Icons.diamond_outlined;
        break;
      case PieceType.king:
        icon =
            piece.color == PieceColor.white
                ? Icons.stars
                : Icons.stars_outlined;
        break;
    }

    return Icon(
      icon,
      size: 32,
      color: piece.color == PieceColor.white ? Colors.white70 : Colors.black87,
    );
  }
}
