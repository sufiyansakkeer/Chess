import '../../value_objects/piece_type.dart';
import '../../value_objects/position.dart';
import '../piece_entity.dart';

class Knight extends PieceEntity {
  Knight({required super.color, required super.position, super.hasMoved})
    : super(type: PieceType.knight);

  @override
  List<Position> getPossibleMoves(
    List<List<PieceEntity?>> board, [
    Position? enPassantTarget,
  ]) {
    List<Position> moves = [];
    final movesOffsets = [
      [-2, -1], [-2, 1], // Up 2, left/right 1
      [2, -1], [2, 1], // Down 2, left/right 1
      [-1, -2], [1, -2], // Left 2, up/down 1
      [-1, 2], [1, 2], // Right 2, up/down 1
    ];

    for (var offset in movesOffsets) {
      final newRow = position.row + offset[0];
      final newCol = position.col + offset[1];

      Position newPos = Position(newRow, newCol);
      if (!newPos.isValid()) continue;

      var pieceAtPosition = board[newRow][newCol];
      if (pieceAtPosition == null || pieceAtPosition.color != color) {
        moves.add(newPos);
      }
    }

    return moves;
  }

  @override
  PieceEntity copyWith({Position? position, bool? hasMoved}) {
    return Knight(
      color: color,
      position: position ?? this.position,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }
}
