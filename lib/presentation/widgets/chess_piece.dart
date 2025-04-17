import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/piece_entity.dart';
import '../../domain/value_objects/piece_color.dart';
import '../../domain/value_objects/piece_type.dart';

class ChessPiece extends StatelessWidget {
  final PieceEntity piece;

  const ChessPiece({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(_getPieceAsset(), height: 32, width: 32),
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
