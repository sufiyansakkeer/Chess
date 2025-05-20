import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/piece_entity.dart';
import '../../domain/value_objects/piece_color.dart';
import '../../domain/value_objects/piece_type.dart';
import 'switchable_chess_piece.dart';

class AnimatedChessPiece extends StatelessWidget {
  final PieceEntity piece;
  final bool isSelected;
  final bool isLastMoved;
  final bool isCapturing;

  const AnimatedChessPiece({
    super.key,
    required this.piece,
    this.isSelected = false,
    this.isLastMoved = false,
    this.isCapturing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'chess_piece_${piece.position.row}_${piece.position.col}',
      child: SwitchableChessPiece(
        piece: piece,
        isSelected: isSelected,
        isLastMoved: isLastMoved,
      ),
    );
  }
}

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
  late Animation<double> _progressAnimation;

  // Store the piece image to avoid rebuilding during animation
  late String _pieceAsset;
  late Color _pieceColor;

  @override
  void initState() {
    super.initState();

    // Pre-calculate the piece asset and color to avoid rebuilds
    _pieceAsset = _getPieceAsset(widget.piece);

    // Create a controller with a fixed duration
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 200,
      ), // Slightly faster for smoother feel
      vsync: this,
    );

    // Create a simple animation from 0.0 to 1.0 with a nice curve
    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad, // Smoother acceleration/deceleration
    );

    // Start the animation after a very brief delay to ensure layout is complete
    Future.delayed(const Duration(milliseconds: 10), () {
      if (mounted) {
        _controller.forward().then((_) {
          if (mounted) {
            // Ensure we're still mounted before calling the callback
            widget.onAnimationComplete();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the piece color only once during build
    _pieceColor = _getPieceColor(context, widget.piece);

    return AnimatedBuilder(
      // Only rebuild when the animation value changes
      animation: _progressAnimation,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Get the size of the board and calculate square size
            final boardWidth = constraints.maxWidth;
            final squareSize = boardWidth / 8;

            // Calculate the starting position (in pixels)
            final startX = widget.fromPosition.col * squareSize;
            final startY = widget.fromPosition.row * squareSize;

            // Calculate the ending position (in pixels)
            final endX = widget.toPosition.col * squareSize;
            final endY = widget.toPosition.row * squareSize;

            // Calculate the current position based on the animation value
            final currentX =
                startX + (endX - startX) * _progressAnimation.value;
            final currentY =
                startY + (endY - startY) * _progressAnimation.value;

            // Calculate a slight scaling effect for the piece during movement
            final scale =
                1.0 +
                0.1 * (1.0 - (2.0 * _progressAnimation.value - 1.0).abs());

            // Return a properly positioned widget without using Positioned
            // This avoids the ParentDataWidget error
            return Transform.translate(
              offset: Offset(currentX, currentY),
              child: SizedBox(
                width: squareSize,
                height: squareSize,
                child: Center(
                  child: Transform.scale(
                    scale: scale,
                    child: SvgPicture.asset(
                      _pieceAsset,
                      width: squareSize * 0.7,
                      height: squareSize * 0.7,
                      colorFilter:
                          _shouldApplyColorFilter(widget.piece)
                              ? ColorFilter.mode(_pieceColor, BlendMode.srcIn)
                              : null,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to determine if color filter should be applied
  bool _shouldApplyColorFilter(PieceEntity piece) {
    // Don't apply color filter to the crown queen
    if (piece.color == PieceColor.white && piece.type == PieceType.queen) {
      return false;
    }

    // Don't apply color filter to the new piece designs
    return false;
  }

  // Helper method to get the piece asset path
  String _getPieceAsset(PieceEntity piece) {
    final color = piece.color == PieceColor.white ? 'white' : 'black';

    // Special case: Always use the clown design for the white queen
    if (piece.color == PieceColor.white && piece.type == PieceType.queen) {
      return 'assets/white_queen.svg';
    }

    // Use the tribal-style piece designs for all other pieces
    switch (piece.type) {
      case PieceType.king:
        return 'assets/${color}_king.svg';
      case PieceType.queen:
        return 'assets/${color}_queen.svg';
      case PieceType.rook:
        return 'assets/${color}_rook.svg';
      case PieceType.bishop:
        return 'assets/${color}_bishop.svg';
      case PieceType.knight:
        return 'assets/${color}_knight.svg';
      case PieceType.pawn:
        return 'assets/${color}_pawn.svg';
    }
  }

  // Helper method to get the piece color
  Color _getPieceColor(BuildContext context, PieceEntity piece) {
    final colorScheme = Theme.of(context).colorScheme;

    if (piece.color == PieceColor.white) {
      return colorScheme.brightness == Brightness.light
          ? Colors.white
          : Colors.grey[300]!;
    } else {
      return colorScheme.brightness == Brightness.light
          ? Colors.black
          : Colors.grey[800]!;
    }
  }
}

// Helper class to represent a position
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';
}
