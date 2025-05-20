import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/value_objects/piece_type.dart';
import '../../../domain/value_objects/position.dart';

/// Base class for all game presenter events
abstract class GamePresenterEvent extends Equatable {
  const GamePresenterEvent();

  @override
  List<Object?> get props => [];
}

/// Event to select a position on the board
class SelectPosition extends GamePresenterEvent {
  final BuildContext context;
  final Position position;

  const SelectPosition({
    required this.context,
    required this.position,
  });

  @override
  List<Object?> get props => [position];
}

/// Event to clear the current selection
class ClearSelection extends GamePresenterEvent {
  const ClearSelection();
}

/// Event to reset the game
class ResetGame extends GamePresenterEvent {
  const ResetGame();
}

/// Event to promote a pawn
class PromotePawn extends GamePresenterEvent {
  final PieceType promotionType;
  final Position from;
  final Position to;

  const PromotePawn({
    required this.promotionType,
    required this.from,
    required this.to,
  });

  @override
  List<Object?> get props => [promotionType, from, to];
}

/// Event to cancel pawn promotion
class CancelPawnPromotion extends GamePresenterEvent {
  const CancelPawnPromotion();
}
