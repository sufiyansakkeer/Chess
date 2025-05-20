import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../blocs/game/game.dart';

class MoveHistoryAndCapturedPieces extends StatelessWidget {
  const MoveHistoryAndCapturedPieces({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Move history
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Move History',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: BlocBuilder<GameBloc, GameState>(
                    buildWhen:
                        (previous, current) =>
                            previous.moveHistory != current.moveHistory,
                    builder: (context, gameState) {
                      final colorScheme = Theme.of(context).colorScheme;

                      if (gameState.moveHistory.isEmpty) {
                        return Center(
                          child: Text(
                            'No moves yet',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: gameState.moveHistory.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 12,
                              backgroundColor: colorScheme.secondaryContainer,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            title: Text(
                              gameState.moveHistory[index],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Captured pieces
        BlocBuilder<GameBloc, GameState>(
          buildWhen:
              (previous, current) =>
                  previous.whiteCapturedPieces != current.whiteCapturedPieces ||
                  previous.blackCapturedPieces != current.blackCapturedPieces,
          builder:
              (context, gameState) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildCapturedPieces(
                      context,
                      gameState.whiteCapturedPieces,
                      'White',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCapturedPieces(
                      context,
                      gameState.blackCapturedPieces,
                      'Black',
                    ),
                  ),
                ],
              ),
        ),
      ],
    );
  }

  // Helper method to get the correct asset path for each piece
  String _getPieceAsset(piece) {
    final color = piece.color.toString().split('.').last;
    final type = piece.type.toString().split('.').last;

    // Special case: Always use the clown design for the white queen
    if (color == 'white' && type == 'queen') {
      return 'assets/white_queen.svg';
    }

    // Use the tribal-style piece designs for all other pieces
    return 'assets/${color}_$type.svg';
  }

  Widget _buildCapturedPieces(BuildContext context, List pieces, String color) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              '$color Captured Pieces',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (pieces.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'None',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children:
                    pieces.map((piece) {
                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(40),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: SvgPicture.asset(_getPieceAsset(piece)),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
