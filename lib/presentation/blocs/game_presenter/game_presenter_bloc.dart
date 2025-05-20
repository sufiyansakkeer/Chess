import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/game_state.dart';
import '../../../domain/entities/pieces/pawn.dart';
import '../../../domain/value_objects/piece_type.dart';

import 'game_presenter_event.dart';
import 'game_presenter_state.dart';

/// BLoC for managing game presenter state
class GamePresenterBloc extends Bloc<GamePresenterEvent, GamePresenterState> {
  final GameState _gameState;

  GamePresenterBloc(this._gameState)
    : super(GamePresenterState.initial(_gameState)) {
    on<SelectPosition>(_onSelectPosition);
    on<ClearSelection>(_onClearSelection);
    on<ResetGame>(_onResetGame);
    on<PromotePawn>(_onPromotePawn);
    on<CancelPawnPromotion>(_onCancelPawnPromotion);
  }

  /// Handle position selection event
  void _onSelectPosition(
    SelectPosition event,
    Emitter<GamePresenterState> emit,
  ) async {
    final position = event.position;

    // If the same position is selected again, clear the selection
    if (state.selectedPosition == position) {
      add(const ClearSelection());
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
            lastMovedPiece: lastMovedPiece,
            lastMovedFrom: lastMovedFrom,
            lastMovedTo: lastMovedTo,
            isPawnPromotion: true,
            promotionPosition: position,
          ),
        );

        // Show promotion dialog
        final promotionType = await showPromotionDialog(event.context);
        if (promotionType != null) {
          add(
            PromotePawn(
              promotionType: promotionType,
              from: state.selectedPosition!,
              to: position,
            ),
          );
        } else {
          // If the dialog is dismissed, cancel the promotion
          add(const CancelPawnPromotion());
        }
      } else {
        // Regular move
        _gameState.movePiece(state.selectedPosition!, position);

        // Update state with the new game state and clear the selection
        emit(
          state.copyWith(
            gameState: _gameState,
            selectedPosition: null,
            validMoves: const [],
            lastMovedPiece: lastMovedPiece,
            lastMovedFrom: lastMovedFrom,
            lastMovedTo: lastMovedTo,
          ),
        );
      }
    } else {
      // Invalid selection, clear the current selection
      add(const ClearSelection());
    }
  }

  /// Handle selection cleared event
  void _onClearSelection(
    ClearSelection event,
    Emitter<GamePresenterState> emit,
  ) {
    emit(state.copyWith(selectedPosition: null, validMoves: const []));
  }

  /// Handle game reset event
  void _onResetGame(ResetGame event, Emitter<GamePresenterState> emit) {
    _gameState.reset();
    emit(
      state.copyWith(
        gameState: _gameState,
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
  void _onPromotePawn(PromotePawn event, Emitter<GamePresenterState> emit) {
    // Execute the move with promotion
    _gameState.movePiece(event.from, event.to, event.promotionType);

    // Update state with the new game state and clear the selection
    emit(
      state.copyWith(
        gameState: _gameState,
        selectedPosition: null,
        validMoves: const [],
        isPawnPromotion: false,
        promotionPosition: null,
      ),
    );
  }

  /// Handle pawn promotion cancelled event
  void _onCancelPawnPromotion(
    CancelPawnPromotion event,
    Emitter<GamePresenterState> emit,
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
