import 'package:flutter/material.dart';
import '../../domain/entities/piece_entity.dart';
import '../../domain/value_objects/piece_color.dart';
import '../../domain/value_objects/piece_type.dart';

class ChessPiece extends StatelessWidget {
  final PieceEntity piece;

  const ChessPiece({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _getPieceSymbol(),
        style: TextStyle(
          fontSize: 32,
          color:
              piece.color == PieceColor.white ? Colors.black : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPieceSymbol() {
    final isWhite = piece.color == PieceColor.white;
    switch (piece.type) {
      case PieceType.king:
        return isWhite ? '♔' : '♚';
      case PieceType.queen:
        return isWhite ? '♕' : '♛';
      case PieceType.rook:
        return isWhite ? '♖' : '♜';
      case PieceType.bishop:
        return isWhite ? '♗' : '♝';
      case PieceType.knight:
        return isWhite ? '♘' : '♞';
      case PieceType.pawn:
        return isWhite ? '♙' : '♟';
    }
  }
}
