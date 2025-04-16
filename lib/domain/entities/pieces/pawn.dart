import '../../value_objects/piece_color.dart';
import '../../value_objects/piece_type.dart';
import '../../value_objects/position.dart';
import '../piece_entity.dart';

// Remove the mixin as en passant state is managed in GameStateImpl
class Pawn extends PieceEntity {
  // final bool _isEnPassantEligible; // Removed

  Pawn({
    required super.color,
    required super.position,
    super.hasMoved,
    // bool isEnPassantEligible = false, // Removed
  }) : // _isEnPassantEligible = isEnPassantEligible, // Removed
       super(type: PieceType.pawn);

  // @override
  // bool get isEnPassantEligible => _isEnPassantEligible; // Removed

  // Check if moving *to* a given position results in promotion
  bool canPromote(Position to) =>
      (color == PieceColor.white && to.row == 0) ||
      (color == PieceColor.black && to.row == 7);

  @override
  List<Position> getPossibleMoves(
    List<List<PieceEntity?>> board, [
    Position? enPassantTarget,
  ]) {
    List<Position> moves = [];
    int direction = color == PieceColor.white ? -1 : 1;

    // Forward move
    Position oneStep = Position(position.row + direction, position.col);
    if (oneStep.isValid() && board[oneStep.row][oneStep.col] == null) {
      moves.add(oneStep);

      // Initial two-step move
      if (!hasMoved) {
        Position twoStep = Position(position.row + 2 * direction, position.col);
        // Check square in front is also clear for the double move
        if (twoStep.isValid() && board[twoStep.row][twoStep.col] == null) {
          moves.add(twoStep);
        }
      }
    }

    // Captures (Regular and En Passant)
    for (int colOffset in [-1, 1]) {
      Position capturePos = Position(
        position.row + direction,
        position.col + colOffset,
      );
      if (!capturePos.isValid()) continue;

      // Regular capture
      final targetPiece = board[capturePos.row][capturePos.col];
      if (targetPiece != null && targetPiece.color != color) {
        moves.add(capturePos);
      }

      // En passant capture
      // Check if the capture position matches the en passant target square passed from GameState
      if (capturePos == enPassantTarget) {
        // Check if the pawn being captured is actually adjacent
        final adjacentPawnPos = Position(
          position.row,
          position.col + colOffset,
        );
        if (adjacentPawnPos.isValid()) {
          final adjacentPiece = board[adjacentPawnPos.row][adjacentPawnPos.col];
          if (adjacentPiece != null &&
              adjacentPiece.type == PieceType.pawn &&
              adjacentPiece.color != color) {
            moves.add(capturePos);
          }
        }
      }
    }

    return moves;
  }

  // Remove isEnPassantEligible from copyWith as it's now managed by GameStateImpl._enPassantTargetSquare
  @override
  PieceEntity copyWith({
    Position? position,
    bool? hasMoved,
    // bool? isEnPassantEligible, // Removed
  }) {
    return Pawn(
      color: color,
      position: position ?? this.position,
      hasMoved: hasMoved ?? this.hasMoved,
      // isEnPassantEligible: isEnPassantEligible ?? _isEnPassantEligible, // Removed
    );
  }
}

// Mixin is no longer needed as the flag is removed from Pawn state
// mixin EnPassantEligible {
//   bool get isEnPassantEligible;
// }
