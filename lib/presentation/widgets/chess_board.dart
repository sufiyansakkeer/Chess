import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/feedback_service.dart';
import '../../domain/value_objects/position.dart';
import '../blocs/blocs.dart';
import 'chess_piece.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final feedbackService = FeedbackService();
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
            ),
            itemCount: 64,
            itemBuilder: (context, index) {
              final row = index ~/ 8;
              final col = index % 8;
              final position = Position(row, col);
              final piece = state.board[row][col];
              final isSelected = state.selectedPosition == position;
              final isValidMove = state.validMoves.contains(position);
              final isLastMovedFrom = state.lastMovedFrom == position;
              final isLastMovedTo = state.lastMovedTo == position;

              // Determine square color
              final isLightSquare = (row + col) % 2 == 0;
              final squareColor =
                  isLightSquare
                      ? colorScheme.primary.withAlpha(25)
                      : colorScheme.primary.withAlpha(76);

              // Determine highlight colors
              final selectedColor = colorScheme.primary.withAlpha(178);
              final validMoveColor = colorScheme.secondary.withAlpha(127);
              final lastMovedFromColor = colorScheme.tertiary.withAlpha(76);
              final lastMovedToColor = colorScheme.tertiary.withAlpha(127);

              // Apply appropriate color based on square state
              Color backgroundColor = squareColor;
              if (isSelected) {
                backgroundColor = selectedColor;
              } else if (isValidMove) {
                backgroundColor = validMoveColor;
              } else if (isLastMovedFrom) {
                backgroundColor = lastMovedFromColor;
              } else if (isLastMovedTo) {
                backgroundColor = lastMovedToColor;
              }

              return GestureDetector(
                onTap: () {
                  // Handle square tap
                  context.read<GameBloc>().add(PositionSelected(position));

                  // Provide haptic feedback
                  if (piece != null) {
                    feedbackService.selectionClick();
                  } else if (isValidMove) {
                    feedbackService.lightImpact();
                  } else {
                    feedbackService.selectionClick();
                  }
                },
                child: Container(
                  color: backgroundColor,
                  child: Center(
                    child:
                        piece != null
                            ? ChessPiece(piece: piece)
                            : isValidMove
                            ? Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colorScheme.secondary.withAlpha(76),
                                shape: BoxShape.circle,
                              ),
                            )
                            : null,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
