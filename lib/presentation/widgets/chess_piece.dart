import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/piece_entity.dart';
import '../blocs/theme/theme.dart';
import '../../domain/value_objects/piece_color.dart';
import '../../domain/value_objects/piece_type.dart';

class ChessPiece extends StatelessWidget {
  final PieceEntity piece;

  const ChessPiece({super.key, required this.piece});

  Color _getColor(BuildContext context) {
    final themeState = context.read<ThemeBloc>().state;
    final themeStyle = themeState.themeStyle;

    switch (themeStyle) {
      case 'modern':
        return Colors.teal.shade200;
      case 'forest':
        return Colors.green.shade200;
      case 'ocean':
        return Colors.cyan.shade200;
      case 'sunset':
        return Colors.orange.shade200;
      case 'minimalist':
        return Colors.grey.shade200;
      case 'classic':
      default:
        return Colors.blue.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Center(
          child: SvgPicture.asset(
            _getPieceAsset(),
            height: 32,
            width: 32,
            colorFilter:
                _shouldApplyColorFilter()
                    ? ColorFilter.mode(_getColor(context), BlendMode.modulate)
                    : null,
          ),
        );
      },
    );
  }

  /// Determines if color filter should be applied
  /// The crown queen and new piece designs have their own colors, so we don't apply a filter to them
  bool _shouldApplyColorFilter() {
    // Don't apply color filter to the crown queen
    if (piece.color == PieceColor.white && piece.type == PieceType.queen) {
      return false;
    }
    // Don't apply color filter to the new piece designs
    return false;
  }

  String _getPieceAsset() {
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
}
