import 'package:equatable/equatable.dart';
import '../../../domain/entities/piece_entity.dart';
import '../../../domain/value_objects/piece_color.dart';
import '../../../domain/value_objects/position.dart';

/// State class for the GameBloc
class GameState extends Equatable {
  final List<List<PieceEntity?>> board;
  final PieceColor currentTurn;
  final bool isGameOver;
  final PieceColor? winner;
  final bool isInCheck;
  final Position? selectedPosition;
  final List<Position> validMoves;
  final List<String> moveHistory;
  final List<PieceEntity> whiteCapturedPieces;
  final List<PieceEntity> blackCapturedPieces;
  final Position? lastMovedFrom;
  final Position? lastMovedTo;
  final PieceEntity? lastMovedPiece;
  final bool isPawnPromotion;
  final Position? promotionPosition;

  const GameState({
    required this.board,
    required this.currentTurn,
    required this.isGameOver,
    required this.winner,
    required this.isInCheck,
    required this.selectedPosition,
    required this.validMoves,
    required this.moveHistory,
    required this.whiteCapturedPieces,
    required this.blackCapturedPieces,
    required this.lastMovedFrom,
    required this.lastMovedTo,
    required this.lastMovedPiece,
    required this.isPawnPromotion,
    required this.promotionPosition,
  });

  /// Initial state with empty board
  factory GameState.initial() => const GameState(
        board: [],
        currentTurn: PieceColor.white,
        isGameOver: false,
        winner: null,
        isInCheck: false,
        selectedPosition: null,
        validMoves: [],
        moveHistory: [],
        whiteCapturedPieces: [],
        blackCapturedPieces: [],
        lastMovedFrom: null,
        lastMovedTo: null,
        lastMovedPiece: null,
        isPawnPromotion: false,
        promotionPosition: null,
      );

  /// Create a copy of this state with optional new values
  GameState copyWith({
    List<List<PieceEntity?>>? board,
    PieceColor? currentTurn,
    bool? isGameOver,
    PieceColor? winner,
    bool? isInCheck,
    Position? selectedPosition,
    List<Position>? validMoves,
    List<String>? moveHistory,
    List<PieceEntity>? whiteCapturedPieces,
    List<PieceEntity>? blackCapturedPieces,
    Position? lastMovedFrom,
    Position? lastMovedTo,
    PieceEntity? lastMovedPiece,
    bool? isPawnPromotion,
    Position? promotionPosition,
  }) {
    return GameState(
      board: board ?? this.board,
      currentTurn: currentTurn ?? this.currentTurn,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: winner ?? this.winner,
      isInCheck: isInCheck ?? this.isInCheck,
      selectedPosition: selectedPosition,
      validMoves: validMoves ?? this.validMoves,
      moveHistory: moveHistory ?? this.moveHistory,
      whiteCapturedPieces: whiteCapturedPieces ?? this.whiteCapturedPieces,
      blackCapturedPieces: blackCapturedPieces ?? this.blackCapturedPieces,
      lastMovedFrom: lastMovedFrom ?? this.lastMovedFrom,
      lastMovedTo: lastMovedTo ?? this.lastMovedTo,
      lastMovedPiece: lastMovedPiece ?? this.lastMovedPiece,
      isPawnPromotion: isPawnPromotion ?? this.isPawnPromotion,
      promotionPosition: promotionPosition ?? this.promotionPosition,
    );
  }

  @override
  List<Object?> get props => [
        board,
        currentTurn,
        isGameOver,
        winner,
        isInCheck,
        selectedPosition,
        validMoves,
        moveHistory,
        whiteCapturedPieces,
        blackCapturedPieces,
        lastMovedFrom,
        lastMovedTo,
        lastMovedPiece,
        isPawnPromotion,
        promotionPosition,
      ];
}
