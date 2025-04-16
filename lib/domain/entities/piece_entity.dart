import '../value_objects/piece_color.dart';
import '../value_objects/piece_type.dart';
import '../value_objects/position.dart';

abstract class PieceEntity {
  final PieceType type;
  final PieceColor color;
  final Position position;
  bool hasMoved;

  PieceEntity({
    required this.type,
    required this.color,
    required this.position,
    this.hasMoved = false,
  });

  List<Position> getPossibleMoves(
    List<List<PieceEntity?>> board, [
    Position? enPassantTarget,
  ]);

  bool isValidMove(Position target, List<List<PieceEntity?>> board) {
    return getPossibleMoves(board).any((pos) => pos == target);
  }

  PieceEntity copyWith({Position? position, bool? hasMoved});
}
