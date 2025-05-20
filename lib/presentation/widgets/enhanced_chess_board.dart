import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/value_objects/position.dart' as domain;
import '../../domain/entities/piece_entity.dart';
import '../blocs/game/game.dart';
import 'animated_chess_piece.dart';
import 'move_indicator.dart';

class EnhancedChessBoard extends StatefulWidget {
  const EnhancedChessBoard({super.key});

  @override
  State<EnhancedChessBoard> createState() => _EnhancedChessBoardState();
}

class _EnhancedChessBoardState extends State<EnhancedChessBoard> {
  domain.Position? _lastMovedFrom;
  domain.Position? _lastMovedTo;
  bool _isAnimating = false;
  PieceEntity? _movingPiece;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(51),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: BlocBuilder<GameBloc, GameState>(
          buildWhen: (previous, current) {
            // Only rebuild if the board, selection, or valid moves change
            // For lastMovedTo/From, we'll handle those separately
            return previous.board != current.board ||
                previous.selectedPosition != current.selectedPosition ||
                previous.validMoves != current.validMoves;
          },
          builder: (context, gameState) {
            final gameBloc = context.read<GameBloc>();

            // Check for move changes, but don't call setState directly
            if (_lastMovedTo != gameState.lastMovedTo ||
                _lastMovedFrom != gameState.lastMovedFrom) {
              // Use post-frame callback to avoid setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                // Only update the positions without triggering animation
                // The animation will be handled by the _onSquareTapped method
                setState(() {
                  _lastMovedTo = gameState.lastMovedTo;
                  _lastMovedFrom = gameState.lastMovedFrom;
                });
              });
            }

            // Use RepaintBoundary to isolate repaints
            return Stack(
              children: [
                // The chess board grid - wrap in RepaintBoundary
                RepaintBoundary(
                  child: GridView.count(
                    crossAxisCount: 8,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(64, (index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      final position = domain.Position(row, col);
                      final piece = gameState.board[row][col];
                      final isSelected =
                          position.row == gameState.selectedPosition?.row &&
                          position.col == gameState.selectedPosition?.col;
                      final isValidMove = gameState.validMoves.any(
                        (pos) =>
                            pos.row == position.row && pos.col == position.col,
                      );
                      final isLastMovedTo =
                          position.row == _lastMovedTo?.row &&
                          position.col == _lastMovedTo?.col;
                      final isLastMovedFrom =
                          position.row == _lastMovedFrom?.row &&
                          position.col == _lastMovedFrom?.col;

                      // Determine if we should show the piece
                      // Don't show if it's the piece being animated
                      final shouldShowPiece =
                          !(_isAnimating &&
                              _lastMovedFrom != null &&
                              _lastMovedFrom!.row == row &&
                              _lastMovedFrom!.col == col);

                      return RepaintBoundary(
                        child: Material(
                          color: _getSquareColor(
                            context,
                            row,
                            col,
                            isSelected,
                            isValidMove,
                            isLastMovedTo,
                            isLastMovedFrom,
                          ),
                          child: InkWell(
                            key: ValueKey('square_${row}_$col'),
                            onTap: () {
                              if (!_isAnimating) {
                                _onSquareTapped(context, gameBloc, position);
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Only show the piece if it's not the moving piece
                                if (shouldShowPiece && piece != null)
                                  AnimatedChessPiece(
                                    piece: piece,
                                    isSelected: isSelected,
                                    isLastMoved: isLastMovedTo,
                                  ),

                                // Show move indicators for valid moves
                                if (isValidMove)
                                  MoveIndicator(isCapture: piece != null),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // The moving piece animation - wrap in RepaintBoundary
                if (_isAnimating &&
                    _movingPiece != null &&
                    _lastMovedFrom != null &&
                    _lastMovedTo != null)
                  RepaintBoundary(
                    child: Stack(
                      children: [
                        MovingChessPiece(
                          piece: _movingPiece!,
                          fromPosition: Position(
                            _lastMovedFrom!.row,
                            _lastMovedFrom!.col,
                          ),
                          toPosition: Position(
                            _lastMovedTo!.row,
                            _lastMovedTo!.col,
                          ),
                          onAnimationComplete: _onAnimationComplete,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onAnimationComplete() {
    // Use a short delay before clearing the animation state
    // This ensures the animation is fully complete before updating the board
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _movingPiece = null;
        });
      }
    });
  }

  void _onSquareTapped(
    BuildContext context,
    GameBloc gameBloc,
    domain.Position position,
  ) {
    // Get the current game state
    final gameState = gameBloc.state;

    // If a piece is selected and the tapped position is a valid move
    if (gameState.selectedPosition != null &&
        gameState.validMoves.any(
          (pos) => pos.row == position.row && pos.col == position.col,
        )) {
      // Get the piece that's moving
      final selectedPiece =
          gameState.board[gameState.selectedPosition!.row][gameState
              .selectedPosition!
              .col];

      // Start the animation
      if (selectedPiece != null) {
        setState(() {
          _isAnimating = true;
          _movingPiece = selectedPiece;
          _lastMovedFrom = gameState.selectedPosition;
          _lastMovedTo = position;
        });

        // Play move sound
        HapticFeedback.mediumImpact();
      }
    }

    // Dispatch the position selected event
    gameBloc.add(PositionSelected(position));
  }

  Color _getSquareColor(
    BuildContext context,
    int row,
    int col,
    bool isSelected,
    bool isValidMove,
    bool isLastMovedTo,
    bool isLastMovedFrom,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isSelected) {
      return colorScheme.primaryContainer;
    }
    if (isValidMove) {
      return colorScheme.secondaryContainer.withAlpha(150);
    }
    if (isLastMovedTo) {
      return colorScheme.tertiaryContainer.withAlpha(150);
    }
    if (isLastMovedFrom) {
      return colorScheme.tertiaryContainer.withAlpha(80);
    }

    // Default light/dark square colors
    final isLightSquare = (row + col) % 2 == 0;
    return isLightSquare
        ? colorScheme.surface
        : colorScheme.surfaceContainerHighest;
  }
}

/// Widget to animate a chess piece moving from one position to another
class MovingChessPiece extends StatefulWidget {
  final PieceEntity piece;
  final Position fromPosition;
  final Position toPosition;
  final VoidCallback onAnimationComplete;

  const MovingChessPiece({
    super.key,
    required this.piece,
    required this.fromPosition,
    required this.toPosition,
    required this.onAnimationComplete,
  });

  @override
  State<MovingChessPiece> createState() => _MovingChessPieceState();
}

class _MovingChessPieceState extends State<MovingChessPiece>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward().then((_) => widget.onAnimationComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final squareSize = MediaQuery.of(context).size.width / 8;
        final fromX = widget.fromPosition.col * squareSize;
        final fromY = widget.fromPosition.row * squareSize;
        final toX = widget.toPosition.col * squareSize;
        final toY = widget.toPosition.row * squareSize;

        final currentX = fromX + (toX - fromX) * _animation.value;
        final currentY = fromY + (toY - fromY) * _animation.value;

        return Positioned(
          left: currentX,
          top: currentY,
          width: squareSize,
          height: squareSize,
          child: AnimatedChessPiece(
            piece: widget.piece,
            isSelected: false,
            isLastMoved: false,
          ),
        );
      },
    );
  }
}

/// Helper class for position in the UI
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);
}
