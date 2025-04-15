import '../../value_objects/piece_color.dart';
import '../../value_objects/piece_type.dart';
import '../../value_objects/position.dart';
import '../piece_entity.dart';

class Pawn extends PieceEntity {
  Pawn({required super.color, required super.position, super.hasMoved})
    : super(type: PieceType.pawn);

  @override
  List<Position> getPossibleMoves(List<List<PieceEntity?>> board) {
    List<Position> moves = [];
    int direction = color == PieceColor.white ? -1 : 1;

    // Forward move
    Position oneStep = Position(position.row + direction, position.col);
    if (oneStep.isValid() && board[oneStep.row][oneStep.col] == null) {
      moves.add(oneStep);

      // Initial two-step move
      if (!hasMoved) {
        Position twoStep = Position(position.row + 2 * direction, position.col);
        if (twoStep.isValid() && board[twoStep.row][twoStep.col] == null) {
          moves.add(twoStep);
        }
      }
    }

    // Capture moves
    for (int colOffset in [-1, 1]) {
      Position capturePos = Position(
        position.row + direction,
        position.col + colOffset,
      );
      if (capturePos.isValid()) {
        var piece = board[capturePos.row][capturePos.col];
        if (piece != null && piece.color != color) {
          moves.add(capturePos);
        }
      }
    }

    return moves;
  }

  @override
  PieceEntity copyWith({Position? position, bool? hasMoved}) {
    return Pawn(
      color: color,
      position: position ?? this.position,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }
}
