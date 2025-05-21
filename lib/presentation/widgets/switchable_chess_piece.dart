import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/piece_entity.dart';
import '../../domain/value_objects/piece_color.dart';
import '../../domain/value_objects/piece_type.dart';

/// A chess piece widget that uses the new piece designs
/// with a special case for the white queen (using the crown design)
class SwitchableChessPiece extends StatelessWidget {
  final PieceEntity piece;
  final bool isSelected;
  final bool isLastMoved;

  const SwitchableChessPiece({
    super.key,
    required this.piece,
    this.isSelected = false,
    this.isLastMoved = false,
  });

  Color _getColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use the colorScheme for more consistent colors with Material 3
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

  @override
  Widget build(BuildContext context) {
    // No BlocBuilder needed, just use the original assets
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSelected ? 8 : 0),
        boxShadow:
            isSelected || isLastMoved
                ? [
                  BoxShadow(
                    color:
                        isSelected
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(128)
                            : Theme.of(
                              context,
                            ).colorScheme.secondary.withAlpha(77),
                    blurRadius: isSelected ? 10 : 5,
                    spreadRadius: isSelected ? 2 : 1,
                  ),
                ]
                : null,
      ),
      child: AnimatedScale(
        scale:
            isSelected
                ? 1.1
                : isLastMoved
                ? 1.05
                : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedRotation(
          turns: isSelected ? 0.05 : 0,
          duration: const Duration(milliseconds: 200),
          child: SvgPicture.asset(
            _getPieceAsset(),
            height: 32,
            width: 32,
            colorFilter:
                _shouldApplyColorFilter()
                    ? ColorFilter.mode(_getColor(context), BlendMode.srcIn)
                    : null,
          ),
        ),
      ),
    );
  }

  /// Determines if color filter should be applied
  bool _shouldApplyColorFilter() {
    // Don't apply color filter to the crown queen
    if (piece.color == PieceColor.white && piece.type == PieceType.queen) {
      return false;
    }
    return false;
  }

  String _getPieceAsset() {
    final color = piece.color == PieceColor.white ? 'white' : 'black';
    if (piece.type == PieceType.king) {
      return 'assets/${color}_king.svg';
    } else if (piece.type == PieceType.queen) {
      return 'assets/${color}_queen.svg';
    } else if (piece.type == PieceType.rook) {
      return 'assets/${color}_rook.svg';
    } else if (piece.type == PieceType.bishop) {
      return 'assets/${color}_bishop.svg';
    } else if (piece.type == PieceType.knight) {
      return 'assets/${color}_knight.svg';
    } else {
      return 'assets/${color}_pawn.svg';
    }
  }
}
