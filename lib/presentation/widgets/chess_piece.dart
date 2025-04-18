import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/piece_entity.dart';
import '../providers/theme_provider.dart';
import '../../domain/value_objects/piece_color.dart';
import '../../domain/value_objects/piece_type.dart';

class ChessPiece extends StatelessWidget {
  final PieceEntity piece;

  const ChessPiece({super.key, required this.piece});

  Color _getColor(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeStyle = themeProvider.themeStyle;

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Center(
          child: SvgPicture.asset(
            _getPieceAsset(),
            height: 32,
            width: 32,
            colorFilter: ColorFilter.mode(
              _getColor(context),
              BlendMode.modulate,
            ),
          ),
        );
      },
    );
  }

  String _getPieceAsset() {
    final color = piece.color == PieceColor.white ? 'white' : 'black';
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
