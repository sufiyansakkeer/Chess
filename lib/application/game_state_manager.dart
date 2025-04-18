import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
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
import 'move_validator.dart';
import 'move_executor.dart';
import 'utils/chess_utils.dart';

/// Main class implementing the chess game state
class GameStateManager extends ChangeNotifier implements GameState {
  // Logger instance
  static final _log = Logger('GameStateManager');

  late List<List<PieceEntity?>> _board;
  late PieceColor _currentTurn;
  bool _isGameOver = false;
  PieceColor? _winner;
  Position? _enPassantTargetSquare;
  final List<String> _moveHistory = [];
  final List<PieceEntity> _whiteCapturedPieces = [];
  final List<PieceEntity> _blackCapturedPieces = [];

  GameStateManager() {
    reset();
  }

  @override
  List<PieceEntity> get whiteCapturedPieces => List.from(_whiteCapturedPieces);

  @override
  List<PieceEntity> get blackCapturedPieces => List.from(_blackCapturedPieces);

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
  bool get isKingInCheck => MoveValidator.isInCheck(_currentTurn, _board);

  @override
  List<Position> getValidMovesForPiece(Position position) {
    return MoveValidator.getValidMovesForPiece(
      position,
      _board,
      _currentTurn,
      _enPassantTargetSquare,
    );
  }

  @override
  bool movePiece(Position from, Position to, [PieceType? promotionType]) {
    final piece = _board[from.row][from.col];

    // Basic validation
    if (piece == null || piece.color != _currentTurn) {
      _log.fine(
        "Invalid move: No piece at $from or wrong turn ($_currentTurn).",
      );
      return false;
    }

    final validMoves = getValidMovesForPiece(from);
    if (!validMoves.contains(to)) {
      _log.fine(
        "Invalid move: $to is not in the list of valid moves for ${piece.type} at $from.",
      );
      return false;
    }

    // Execute the move
    final moveResult = MoveExecutor.executeMove(
      from,
      to,
      promotionType,
      _board,
      _currentTurn,
      _enPassantTargetSquare,
    );

    // Update en passant target
    _enPassantTargetSquare = moveResult.enPassantTargetSquare;

    // Add move to history
    _moveHistory.add(moveResult.moveNotation);

    // Add captured piece to captured pieces list if there was a capture
    if (moveResult.capturedPiece != null) {
      if (moveResult.capturedPiece!.color == PieceColor.white) {
        _whiteCapturedPieces.add(moveResult.capturedPiece!);
      } else {
        _blackCapturedPieces.add(moveResult.capturedPiece!);
      }
    }

    // Switch turn
    _currentTurn = ChessUtils.getOppositeColor(_currentTurn);

    // Check game over conditions for the opponent
    final opponentColor = ChessUtils.getOppositeColor(piece.color);
    if (MoveValidator.isCheckmate(
      opponentColor,
      _board,
      _enPassantTargetSquare,
    )) {
      _isGameOver = true;
      _winner = piece.color;
      _log.fine("Checkmate! Winner: $_winner");
    } else if (MoveValidator.isStalemate(
      opponentColor,
      _board,
      _enPassantTargetSquare,
    )) {
      _isGameOver = true;
      _winner = null;
      _log.fine("Stalemate!");
    } else if (MoveValidator.isInCheck(opponentColor, _board)) {
      _log.fine("${opponentColor.toString().split('.').last} is in check.");
    }

    notifyListeners();
    _log.fine(
      "Move successful: ${piece.type} from $from to $to. Turn: $_currentTurn",
    );
    return true;
  }

  @override
  void reset() {
    _board = List.generate(8, (_) => List.filled(8, null));
    _currentTurn = PieceColor.white;
    _isGameOver = false;
    _winner = null;
    _enPassantTargetSquare = null;
    _moveHistory.clear();
    _whiteCapturedPieces.clear();
    _blackCapturedPieces.clear();
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
    _board[row][4] = King(
      color: color,
      position: Position(row, 4),
    ); // King on e file
    _board[row][5] = Bishop(color: color, position: Position(row, 5));
    _board[row][6] = Knight(color: color, position: Position(row, 6));
    _board[row][7] = Rook(color: color, position: Position(row, 7));
  }

  @override
  List<String> getMoveHistory() {
    return List.from(_moveHistory);
  }

  /// Public method to check if a specified color is in checkmate
  bool isCheckmate(PieceColor color) {
    return MoveValidator.isCheckmate(color, _board, _enPassantTargetSquare);
  }

  /// Public method to check if a specified color is in stalemate
  bool isStalemate(PieceColor color) {
    return MoveValidator.isStalemate(color, _board, _enPassantTargetSquare);
  }

  /// Debugging helper to get a string representation of the current board state
  String getBoardString() {
    return ChessUtils.boardToString(
      _board,
      _currentTurn,
      _enPassantTargetSquare,
    );
  }
}
