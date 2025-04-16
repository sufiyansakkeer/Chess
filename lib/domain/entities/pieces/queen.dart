import '../../value_objects/piece_type.dart';
import '../../value_objects/position.dart';
import '../piece_entity.dart';

class Queen extends PieceEntity {
  Queen({required super.color, required super.position, super.hasMoved})
    : super(type: PieceType.queen);

  @override
  List<Position> getPossibleMoves(
    List<List<PieceEntity?>> board, [
    Position? enPassantTarget,
  ]) {
    List<Position> moves = [];
    final directions = [
      [-1, -1], [-1, 0], [-1, 1], // top left, top, top right
      [0, -1], [0, 1], // left, right
      [1, -1], [1, 0], [1, 1], // bottom left, bottom, bottom right
    ];

    for (var direction in directions) {
      var currentRow = position.row;
      var currentCol = position.col;

      while (true) {
        currentRow += direction[0];
        currentCol += direction[1];

        Position newPos = Position(currentRow, currentCol);
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
  List<Position> getRawPossibleMoves(
    List<List<PieceEntity?>> board, [
    Position? enPassantTarget,
  ]) {
    return getPossibleMoves(board, enPassantTarget);
  }

  @override
  PieceEntity copyWith({Position? position, bool? hasMoved}) {
    return Queen(
      color: color,
      position: position ?? this.position,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }
}
