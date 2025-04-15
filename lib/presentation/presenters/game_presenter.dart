import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/value_objects/position.dart';

class GamePresenter extends ChangeNotifier {
  final GameState _gameState;
  Position? _selectedPosition;
  List<Position> _validMoves = [];

  GamePresenter(this._gameState);

  List<List<dynamic>> get board => _gameState.board;
  bool get isGameOver => _gameState.isGameOver;
  String? get winner => _gameState.winner?.toString();
  Position? get selectedPosition => _selectedPosition;
  List<Position> get validMoves => _validMoves;

  void selectPosition(Position position) {
    if (_selectedPosition == position) {
      _clearSelection();
      return;
    }

    final piece = board[position.row][position.col];
    if (piece != null && piece.color == _gameState.currentTurn) {
      _selectedPosition = position;
      _validMoves = _gameState.getValidMovesForPiece(position);
    } else if (_selectedPosition != null && _validMoves.contains(position)) {
      _gameState.movePiece(_selectedPosition!, position);
      _clearSelection();
    } else {
      _clearSelection();
    }
    notifyListeners();
  }

  void _clearSelection() {
    _selectedPosition = null;
    _validMoves = [];
    notifyListeners();
  }

  void resetGame() {
    _gameState.reset();
    _clearSelection();
  }
}
