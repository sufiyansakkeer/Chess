import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/game_state.dart' as domain;
import '../../../domain/entities/pieces/pawn.dart';
import '../../../domain/value_objects/piece_type.dart';
import 'game_event.dart';
import 'game_state.dart';

/// BLoC for managing game-related state
class GameBloc extends Bloc<GameEvent, GameState> {
  final domain.GameState _gameState;

  GameBloc(this._gameState) : super(_createInitialState(_gameState)) {
    on<PositionSelected>(_onPositionSelected);
    on<PieceMoved>(_onPieceMoved);
    on<SelectionCleared>(_onSelectionCleared);
    on<GameReset>(_onGameReset);
    on<PawnPromoted>(_onPawnPromoted);
    on<PawnPromotionCancelled>(_onPawnPromotionCancelled);
  }

  /// Create the initial state from the game state
  static GameState _createInitialState(domain.GameState gameState) {
    return GameState.initial().copyWith(
      board: gameState.board,
      currentTurn: gameState.currentTurn,
      isGameOver: gameState.isGameOver,
      winner: gameState.winner,
      isInCheck: gameState.isKingInCheck,
      moveHistory: gameState.getMoveHistory(),
      whiteCapturedPieces: gameState.whiteCapturedPieces,
      blackCapturedPieces: gameState.blackCapturedPieces,
    );
  }

  /// Create a new state from the game state
  GameState _createUpdatedState() {
    return state.copyWith(
      board: _gameState.board,
      currentTurn: _gameState.currentTurn,
      isGameOver: _gameState.isGameOver,
      winner: _gameState.winner,
      isInCheck: _gameState.isKingInCheck,
      moveHistory: _gameState.getMoveHistory(),
      whiteCapturedPieces: _gameState.whiteCapturedPieces,
      blackCapturedPieces: _gameState.blackCapturedPieces,
    );
  }

  /// Handle position selection event
  void _onPositionSelected(
    PositionSelected event,
    Emitter<GameState> emit,
  ) async {
    final position = event.position;

    // If there's a pending pawn promotion, ignore selection
    if (state.isPawnPromotion) {
      return;
    }

    // If the same position is selected again, clear the selection
    if (state.selectedPosition == position) {
      add(const SelectionCleared());
      return;
    }

    final piece = state.board[position.row][position.col];
    if (piece != null && piece.color == state.currentTurn) {
      // Select the piece and get valid moves
      final validMoves = _gameState.getValidMovesForPiece(position);
      emit(state.copyWith(selectedPosition: position, validMoves: validMoves));
    } else if (state.selectedPosition != null &&
        state.validMoves.contains(position)) {
      // Move the piece to the selected position
      final selectedPiece =
          state.board[state.selectedPosition!.row][state.selectedPosition!.col];

      // Store the piece and positions for animation before the move
      final lastMovedPiece = selectedPiece;
      final lastMovedFrom = state.selectedPosition;
      final lastMovedTo = position;

      // Check for pawn promotion
      if (selectedPiece is Pawn && selectedPiece.canPromote(position)) {
        // Set pawn promotion state
        emit(
          state.copyWith(
            isPawnPromotion: true,
            promotionPosition: position,
            lastMovedPiece: lastMovedPiece,
            lastMovedFrom: lastMovedFrom,
            lastMovedTo: lastMovedTo,
          ),
        );
      } else {
        // Regular move
        add(PieceMoved(from: state.selectedPosition!, to: position));
      }
    } else {
      // Invalid selection, clear the current selection
      add(const SelectionCleared());
    }
  }

  /// Handle piece movement event
  void _onPieceMoved(PieceMoved event, Emitter<GameState> emit) {
    // Execute the move
    final success = _gameState.movePiece(
      event.from,
      event.to,
      event.promotionType,
    );

    if (success) {
      // Update the state with the new game state and clear the selection
      final updatedState = _createUpdatedState();

      // Clear the selection
      emit(
        updatedState.copyWith(
          selectedPosition: null,
          validMoves: const [],
          isPawnPromotion: false,
          promotionPosition: null,
        ),
      );
    }
  }

  /// Handle selection cleared event
  void _onSelectionCleared(SelectionCleared event, Emitter<GameState> emit) {
    emit(state.copyWith(selectedPosition: null, validMoves: const []));
  }

  /// Handle game reset event
  void _onGameReset(GameReset event, Emitter<GameState> emit) {
    _gameState.reset();
    final updatedState = _createUpdatedState();

    emit(
      updatedState.copyWith(
        selectedPosition: null,
        validMoves: const [],
        lastMovedFrom: null,
        lastMovedTo: null,
        lastMovedPiece: null,
        isPawnPromotion: false,
        promotionPosition: null,
      ),
    );
  }

  /// Handle pawn promotion event
  void _onPawnPromoted(PawnPromoted event, Emitter<GameState> emit) {
    if (state.isPawnPromotion &&
        state.selectedPosition != null &&
        state.promotionPosition != null) {
      // Execute the move with promotion
      add(
        PieceMoved(
          from: state.selectedPosition!,
          to: state.promotionPosition!,
          promotionType: event.promotionType,
        ),
      );
    }
  }

  /// Handle pawn promotion cancelled event
  void _onPawnPromotionCancelled(
    PawnPromotionCancelled event,
    Emitter<GameState> emit,
  ) {
    emit(
      state.copyWith(
        isPawnPromotion: false,
        promotionPosition: null,
        lastMovedFrom: null,
        lastMovedTo: null,
        lastMovedPiece: null,
      ),
    );
  }

  /// Show promotion dialog
  Future<PieceType?> showPromotionDialog(BuildContext context) async {
    return showDialog<PieceType>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose promotion piece'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _promotionButton(context, PieceType.queen, '♕'),
              _promotionButton(context, PieceType.rook, '♖'),
              _promotionButton(context, PieceType.bishop, '♗'),
              _promotionButton(context, PieceType.knight, '♘'),
            ],
          ),
        );
      },
    );
  }

  /// Helper method to create a promotion button
  Widget _promotionButton(BuildContext context, PieceType type, String symbol) {
    return IconButton(
      icon: Text(symbol, style: const TextStyle(fontSize: 32)),
      onPressed: () => Navigator.of(context).pop(type),
    );
  }
}
