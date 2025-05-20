import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/piece_entity.dart';
import '../../domain/entities/pieces/pawn.dart'; // Import Pawn
import '../../domain/value_objects/piece_color.dart';
import '../../domain/value_objects/piece_type.dart'; // Import PieceType
import '../../domain/value_objects/position.dart';

class GamePresenter extends ChangeNotifier {
  final GameState _gameState;
  Position? _selectedPosition;
  List<Position> _validMoves = [];
  Position? _lastMovedFrom;
  Position? _lastMovedTo;
  PieceEntity? _lastMovedPiece;

  GamePresenter(this._gameState);

  GameState get gameState => _gameState;
  PieceColor get currentTurn => _gameState.currentTurn;
  List<List<PieceEntity?>> get board => _gameState.board;
  bool get isGameOver => _gameState.isGameOver;
  String? get winner => _gameState.winner?.toString();
  Position? get selectedPosition => _selectedPosition;
  List<Position> get validMoves => _validMoves;
  List<String> get moveHistory => _gameState.getMoveHistory();
  Position? get lastMovedFrom => _lastMovedFrom;
  Position? get lastMovedTo => _lastMovedTo;

  // Get the last moved piece for animation purposes
  PieceEntity? getLastMovedPiece() => _lastMovedPiece;

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

  Widget _promotionButton(BuildContext context, PieceType type, String symbol) {
    return IconButton(
      icon: Text(symbol, style: const TextStyle(fontSize: 32)),
      onPressed: () => Navigator.of(context).pop(type),
    );
  }

  void selectPosition(BuildContext context, Position position) async {
    if (_selectedPosition == position) {
      _clearSelection();
      return;
    }

    final piece = board[position.row][position.col];
    if (piece != null && piece.color == currentTurn) {
      _selectedPosition = position;
      _validMoves = _gameState.getValidMovesForPiece(position);
      notifyListeners();
    } else if (_selectedPosition != null && _validMoves.contains(position)) {
      final selectedPiece =
          board[_selectedPosition!.row][_selectedPosition!.col];

      // Store the piece and positions for animation before the move
      _lastMovedPiece = selectedPiece;
      _lastMovedFrom = _selectedPosition;
      _lastMovedTo = position;

      // Check for pawn promotion using the piece's method and the target position
      if (selectedPiece is Pawn && selectedPiece.canPromote(position)) {
        // Handle pawn promotion
        final promotionType = await showPromotionDialog(
          context,
        ); // Use the passed context
        if (promotionType != null) {
          // Call the updated movePiece method with promotionType
          _gameState.movePiece(
            _selectedPosition!,
            position,
            promotionType, // Pass promotion type here
          );
        } else {
          // If the dialog is dismissed (promotionType is null), don't make the move.
          // The selection remains active.
          _lastMovedFrom = null;
          _lastMovedTo = null;
          _lastMovedPiece = null;
          notifyListeners(); // Update UI to reflect potentially cleared selection state if needed elsewhere
          return; // Exit without clearing selection or making a move
        }
      } else {
        // Regular move or other special move (castling, en passant)
        _gameState.movePiece(_selectedPosition!, position);
      }
      _clearSelection(); // Clear selection after a successful move
    } else {
      _clearSelection(); // Clear selection if clicking on an invalid square
    }
  }

  void _clearSelection() {
    _selectedPosition = null;
    _validMoves = [];
    notifyListeners();
  }

  void resetGame() {
    _gameState.reset();
    _clearSelection();
    _lastMovedFrom = null;
    _lastMovedTo = null;
    _lastMovedPiece = null;
    notifyListeners();
  }
}
