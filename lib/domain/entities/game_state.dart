import '../value_objects/piece_color.dart';
import '../value_objects/piece_type.dart'; // Import PieceType
import '../value_objects/position.dart';
import 'piece_entity.dart';

abstract class GameState {
  List<List<PieceEntity?>> get board;
  PieceColor get currentTurn;
  bool get isGameOver;
  PieceColor? get winner;
  List<Position> getValidMovesForPiece(Position position);
  // Add optional promotionType parameter
  bool movePiece(Position from, Position to, [PieceType? promotionType]);
  // Remove movePieceWithPromotion as it's merged into movePiece
  // bool movePieceWithPromotion(
  //   Position from,
  //   Position to,
  //   PieceType promotionType,
  // );
  void reset();
}
