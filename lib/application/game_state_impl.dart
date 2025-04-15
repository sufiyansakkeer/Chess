import 'package:flutter/foundation.dart';
import '../domain/entities/game_state.dart';
import '../domain/entities/pieces/bishop.dart';
import '../domain/entities/pieces/king.dart';
import '../domain/entities/pieces/knight.dart';
import '../domain/entities/pieces/pawn.dart';
import '../domain/entities/pieces/queen.dart';
import '../domain/entities/pieces/rook.dart';
import '../domain/entities/piece_entity.dart';
import '../domain/value_objects/piece_color.dart';
import '../domain/value_objects/piece_type.dart';
import '../domain/value_objects/position.dart';

class GameStateImpl extends ChangeNotifier implements GameState {
  late List<List<PieceEntity?>> _board;
  late PieceColor _currentTurn;
  bool _isGameOver = false;
  PieceColor? _winner;

  GameStateImpl() {
    reset();
  }

  @override
  List<List<PieceEntity?>> get board =>
      List.from(_board.map((row) => List<PieceEntity?>.from(row)).toList());

  @override
  PieceColor get currentTurn => _currentTurn;

  @override
  bool get isGameOver => _isGameOver;

  @override
  PieceColor? get winner => _winner;

  @override
  List<Position> getValidMovesForPiece(Position position) {
    final piece = _board[position.row][position.col];
    if (piece == null || piece.color != _currentTurn) return [];

    List<Position> possibleMoves = piece.getPossibleMoves(_board);
    return possibleMoves
        .where((pos) => !_wouldPutKingInCheck(position, pos))
        .toList();
  }

  @override
  bool movePiece(Position from, Position to) {
    final piece = _board[from.row][from.col];
    if (piece == null || piece.color != _currentTurn) return false;

    final validMoves = getValidMovesForPiece(from);
    if (!validMoves.contains(to)) return false;

    // Execute move
    _board[to.row][to.col] = piece.copyWith(position: to, hasMoved: true);
    _board[from.row][from.col] = null;

    // Handle castling
    if (piece.type == PieceType.king && (to.col - from.col).abs() == 2) {
      _handleCastling(from, to);
    }

    // Check if game is over
    if (_isCheckmate(_getOppositeColor(_currentTurn))) {
      _isGameOver = true;
      _winner = _currentTurn;
    } else if (_isStalemate(_getOppositeColor(_currentTurn))) {
      _isGameOver = true;
      _winner = null;
    }

    _currentTurn = _getOppositeColor(_currentTurn);
    notifyListeners();
    return true;
  }

  @override
  void reset() {
    _board = List.generate(8, (_) => List.filled(8, null));
    _currentTurn = PieceColor.white;
    _isGameOver = false;
    _winner = null;
    _initializeBoard();
    notifyListeners();
  }

  void _initializeBoard() {
    // Initialize pawns
    for (int col = 0; col < 8; col++) {
      _board[1][col] = Pawn(
        color: PieceColor.black,
        position: Position(1, col),
      );
      _board[6][col] = Pawn(
        color: PieceColor.white,
        position: Position(6, col),
      );
    }

    // Initialize other pieces
    _initializeBackRow(0, PieceColor.black);
    _initializeBackRow(7, PieceColor.white);
  }

  void _initializeBackRow(int row, PieceColor color) {
    _board[row][0] = Rook(color: color, position: Position(row, 0));
    _board[row][1] = Knight(color: color, position: Position(row, 1));
    _board[row][2] = Bishop(color: color, position: Position(row, 2));
    _board[row][3] = Queen(color: color, position: Position(row, 3));
    _board[row][4] = King(color: color, position: Position(row, 4));
    _board[row][5] = Bishop(color: color, position: Position(row, 5));
    _board[row][6] = Knight(color: color, position: Position(row, 6));
    _board[row][7] = Rook(color: color, position: Position(row, 7));
  }

  void _handleCastling(Position from, Position to) {
    final int rookFromCol = to.col > from.col ? 7 : 0;
    final int rookToCol = to.col > from.col ? 5 : 3;

    final rook = _board[from.row][rookFromCol];
    _board[from.row][rookToCol] = rook?.copyWith(
      position: Position(from.row, rookToCol),
      hasMoved: true,
    );
    _board[from.row][rookFromCol] = null;
  }

  bool _isCheckmate(PieceColor color) {
    if (!_isInCheck(color)) return false;
    return _hasNoValidMoves(color);
  }

  bool _isStalemate(PieceColor color) {
    if (_isInCheck(color)) return false;
    return _hasNoValidMoves(color);
  }

  bool _hasNoValidMoves(PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _board[row][col];
        if (piece != null && piece.color == color) {
          final moves = getValidMovesForPiece(Position(row, col));
          if (moves.isNotEmpty) return false;
        }
      }
    }
    return true;
  }

  bool _isInCheck(PieceColor color) {
    // Find king position
    Position? kingPosition;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _board[row][col];
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == color) {
          kingPosition = Position(row, col);
          break;
        }
      }
      if (kingPosition != null) break;
    }

    if (kingPosition == null) return false;

    // Check if any opponent piece can capture the king
    final oppositeColor = _getOppositeColor(color);
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _board[row][col];
        if (piece != null && piece.color == oppositeColor) {
          final moves = piece.getPossibleMoves(_board);
          if (moves.contains(kingPosition)) return true;
        }
      }
    }

    return false;
  }

  bool _wouldPutKingInCheck(Position from, Position to) {
    // Make temporary move
    final piece = _board[from.row][from.col];
    final capturedPiece = _board[to.row][to.col];
    _board[to.row][to.col] = piece?.copyWith(position: to, hasMoved: true);
    _board[from.row][from.col] = null;

    // Check if king is in check
    final isInCheck = _isInCheck(piece!.color);

    // Undo move
    _board[from.row][from.col] = piece;
    _board[to.row][to.col] = capturedPiece;

    return isInCheck;
  }

  PieceColor _getOppositeColor(PieceColor color) {
    return color == PieceColor.white ? PieceColor.black : PieceColor.white;
  }
}
