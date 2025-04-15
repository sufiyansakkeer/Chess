import '../value_objects/piece_color.dart';
import '../value_objects/position.dart';
import 'piece_entity.dart';

abstract class GameState {
  List<List<PieceEntity?>> get board;
  PieceColor get currentTurn;
  bool get isGameOver;
  PieceColor? get winner;
  List<Position> getValidMovesForPiece(Position position);
  bool movePiece(Position from, Position to);
  void reset();
}
