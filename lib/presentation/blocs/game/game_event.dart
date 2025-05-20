import 'package:equatable/equatable.dart';
import '../../../domain/value_objects/piece_type.dart';
import '../../../domain/value_objects/position.dart';

/// Base class for all game-related events
abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// Event to select a position on the board
class PositionSelected extends GameEvent {
  final Position position;

  const PositionSelected(this.position);

  @override
  List<Object?> get props => [position];
}

/// Event to move a piece
class PieceMoved extends GameEvent {
  final Position from;
  final Position to;
  final PieceType? promotionType;

  const PieceMoved({
    required this.from,
    required this.to,
    this.promotionType,
  });

  @override
  List<Object?> get props => [from, to, promotionType];
}

/// Event to clear the current selection
class SelectionCleared extends GameEvent {
  const SelectionCleared();
}

/// Event to reset the game
class GameReset extends GameEvent {
  const GameReset();
}

/// Event to promote a pawn
class PawnPromoted extends GameEvent {
  final PieceType promotionType;

  const PawnPromoted(this.promotionType);

  @override
  List<Object?> get props => [promotionType];
}

/// Event to cancel a pawn promotion
class PawnPromotionCancelled extends GameEvent {
  const PawnPromotionCancelled();
}
