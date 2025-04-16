import '../../value_objects/piece_type.dart';
import '../../value_objects/position.dart';
import '../piece_entity.dart';

class Rook extends PieceEntity {
  Rook({required super.color, required super.position, super.hasMoved})
    : super(type: PieceType.rook);

  @override
  List<Position> getPossibleMoves(
    List<List<PieceEntity?>> board, [
    Position? enPassantTarget,
  ]) {
    List<Position> moves = [];
    final directions = [
      [0, 1], // right
      [0, -1], // left
      [1, 0], // down
      [-1, 0], // up
    ];

    for (var direction in directions) {
      var currentRow = position.row;
      var currentCol = position.col;

      while (true) {
        currentRow += direction[0];
        currentCol += direction[1];

        Position newPos = Position(currentRow, currentCol);
        print("Rook: Checking position: $newPos"); // Add logging
        if (!newPos.isValid()) break;

        var pieceAtPosition = board[currentRow][currentCol];
        if (pieceAtPosition == null) {
          moves.add(newPos);
        } else {
          if (pieceAtPosition.color != color) {
            moves.add(newPos);
          }
          break;
        }
      }
    }

    return moves;
  }

  @override
  PieceEntity copyWith({Position? position, bool? hasMoved}) {
    return Rook(
      color: color,
      position: position ?? this.position,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }
}
