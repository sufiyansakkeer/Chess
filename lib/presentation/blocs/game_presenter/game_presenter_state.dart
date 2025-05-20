import 'package:equatable/equatable.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/piece_entity.dart';
import '../../../domain/value_objects/piece_color.dart';
import '../../../domain/value_objects/position.dart';

/// State class for the GamePresenterBloc
class GamePresenterState extends Equatable {
  final GameState gameState;
  final Position? selectedPosition;
  final List<Position> validMoves;
  final Position? lastMovedFrom;
  final Position? lastMovedTo;
  final PieceEntity? lastMovedPiece;
  final bool isPawnPromotion;
  final Position? promotionPosition;

  const GamePresenterState({
    required this.gameState,
    required this.selectedPosition,
    required this.validMoves,
    required this.lastMovedFrom,
    required this.lastMovedTo,
    required this.lastMovedPiece,
    required this.isPawnPromotion,
    required this.promotionPosition,
  });

  /// Initial state with empty board
  factory GamePresenterState.initial(GameState gameState) => GamePresenterState(
        gameState: gameState,
        selectedPosition: null,
        validMoves: const [],
        lastMovedFrom: null,
        lastMovedTo: null,
        lastMovedPiece: null,
        isPawnPromotion: false,
        promotionPosition: null,
      );

  /// Create a copy of this state with optional new values
  GamePresenterState copyWith({
    GameState? gameState,
    Position? selectedPosition,
    List<Position>? validMoves,
    Position? lastMovedFrom,
    Position? lastMovedTo,
    PieceEntity? lastMovedPiece,
    bool? isPawnPromotion,
    Position? promotionPosition,
  }) {
    return GamePresenterState(
      gameState: gameState ?? this.gameState,
      selectedPosition: selectedPosition,
      validMoves: validMoves ?? this.validMoves,
      lastMovedFrom: lastMovedFrom ?? this.lastMovedFrom,
      lastMovedTo: lastMovedTo ?? this.lastMovedTo,
      lastMovedPiece: lastMovedPiece ?? this.lastMovedPiece,
      isPawnPromotion: isPawnPromotion ?? this.isPawnPromotion,
      promotionPosition: promotionPosition ?? this.promotionPosition,
    );
  }

  // Convenience getters to access gameState properties
  PieceColor get currentTurn => gameState.currentTurn;
  List<List<PieceEntity?>> get board => gameState.board;
  bool get isGameOver => gameState.isGameOver;
  String? get winner => gameState.winner?.toString();
  List<String> get moveHistory => gameState.getMoveHistory();

  @override
  List<Object?> get props => [
        gameState,
        selectedPosition,
        validMoves,
        lastMovedFrom,
        lastMovedTo,
        lastMovedPiece,
        isPawnPromotion,
        promotionPosition,
      ];
}
