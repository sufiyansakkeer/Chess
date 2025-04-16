import '../../value_objects/piece_color.dart';
import '../../value_objects/piece_type.dart';
import '../../value_objects/position.dart';
import '../piece_entity.dart';

class King extends PieceEntity {
  King({required super.color, required super.position, super.hasMoved})
    : super(type: PieceType.king);

  // Castling logic is now handled in GameStateImpl.getValidMovesForPiece
  // En passant target is irrelevant for King moves
  @override
  List<Position> getPossibleMoves(
    List<List<PieceEntity?>> board, [
    Position? enPassantTarget,
  ]) {
    List<Position> moves = [];
    final directions = [
      [-1, -1], [-1, 0], [-1, 1], // top-left, top, top-right
      [0, -1], [0, 1], // left, right
      [1, -1], [1, 0], [1, 1], // bottom-left, bottom, bottom-right
    ];

    // Normal one-step moves
    for (var direction in directions) {
      final newRow = position.row + direction[0];
      final newCol = position.col + direction[1];

      Position newPos = Position(newRow, newCol);
      if (!newPos.isValid()) continue;

      final pieceAtPosition = board[newRow][newCol];
      // Can move to empty square or capture opponent's piece
      if (pieceAtPosition == null || pieceAtPosition.color != color) {
        moves.add(newPos);
      }
    }

    // Castling moves are generated and validated in GameStateImpl

    return moves;
  }

  // Removed _canCastleKingside, _canCastleQueenside, _isInCheck, _isSquareUnderDirectAttack
  // as this logic is now centralized in GameStateImpl

  @override
  PieceEntity copyWith({Position? position, bool? hasMoved}) {
    return King(
      color: color,
      position: position ?? this.position,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }
}
