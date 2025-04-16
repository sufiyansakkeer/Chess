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
  PieceEntity? _lastMovedPiece;
  Position? _lastMoveFrom;
  Position? _lastMoveTo;
  // Store the position *behind* the pawn that just moved two squares,
  // representing the square a capturing pawn would move *to*.
  Position? _enPassantTargetSquare;

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

    // Get moves from piece logic (including potential en passant captures based on _enPassantTargetSquare)
    List<Position> possibleMoves =
        (piece is Pawn)
            ? piece.getPossibleMoves(_board, _enPassantTargetSquare)
            : piece.getPossibleMoves(
              _board,
            ); // Other pieces don't need enPassantTarget

    // Add potential castling moves (checks piece positions, move history, but NOT path attacks yet)
    if (piece is King) {
      possibleMoves.addAll(_getPotentialCastlingMoves(piece, _board));
    }

    // Filter moves:
    // 1. Remove moves that leave the king in check.
    // 2. Specifically validate castling moves for passing through check.
    return possibleMoves.where((to) {
      // Special validation for castling: check if king passes through attacked squares
      if (piece is King && (to.col - position.col).abs() == 2) {
        if (!_isCastlingPathClear(piece, to, _board)) {
          // print("Castling path not clear for ${piece.color} to $to");
          return false; // Invalid castling move due to path attack
        }
      }
      // General validation: does the move leave the king in check?
      bool leavesKingInCheck = _wouldPutKingInCheck(position, to);
      // if (leavesKingInCheck) {
      //   print("Move ${position} -> $to for ${piece.color} would leave king in check.");
      // }
      return !leavesKingInCheck;
    }).toList();
  }

  // Gets potential castling moves based ONLY on piece positions and move history
  // Does NOT check for passing through check - that's done in getValidMovesForPiece filter
  List<Position> _getPotentialCastlingMoves(
    King king,
    List<List<PieceEntity?>> board,
  ) {
    List<Position> moves = [];
    // Cannot castle if king moved or is currently in check
    if (king.hasMoved || _isInCheck(king.color)) return moves;

    final row = king.position.row;

    // Kingside (O-O) Target square: (row, 6)
    final kingsideRook = board[row][7];
    if (kingsideRook != null &&
        kingsideRook.type == PieceType.rook &&
        !kingsideRook.hasMoved) {
      // Check squares between king (col 4) and rook (col 7) are empty: (row, 5), (row, 6)
      if (board[row][5] == null && board[row][6] == null) {
        moves.add(Position(row, 6)); // Target square for kingside castle
      }
    }

    // Queenside (O-O-O) Target square: (row, 2)
    final queensideRook = board[row][0];
    if (queensideRook != null &&
        queensideRook.type == PieceType.rook &&
        !queensideRook.hasMoved) {
      // Check squares between king (col 4) and rook (col 0) are empty: (row, 1), (row, 2), (row, 3)
      if (board[row][1] == null &&
          board[row][2] == null &&
          board[row][3] == null) {
        moves.add(Position(row, 2)); // Target square for queenside castle
      }
    }
    return moves;
  }

  // Checks if the squares the king moves *through* or *to* during castling are attacked
  bool _isCastlingPathClear(
    King king,
    Position kingTo,
    List<List<PieceEntity?>> board,
  ) {
    final row = king.position.row;
    final kingFromCol = king.position.col; // Should be 4
    final direction = kingTo.col > kingFromCol ? 1 : -1;

    // Check squares from king's current position up to AND INCLUDING the destination square
    for (int col = kingFromCol; ; col += direction) {
      if (_isSquareUnderAttack(Position(row, col), king.color, board)) {
        // print("Castling path blocked: Square ($row, $col) is under attack.");
        return false; // Path is attacked
      }
      if (col == kingTo.col)
        break; // Stop after checking the destination square
    }

    return true; // Path is clear
  }

  @override
  // Add optional promotionType parameter and remove movePieceWithPromotion
  bool movePiece(Position from, Position to, [PieceType? promotionType]) {
    final piece = _board[from.row][from.col];
    // Basic validation
    if (piece == null || piece.color != _currentTurn) {
      // print("Invalid move: No piece at $from or wrong turn ($_currentTurn).");
      return false;
    }

    final validMoves = getValidMovesForPiece(from);
    if (!validMoves.contains(to)) {
      // print("Invalid move: $to is not in the list of valid moves for ${piece.type} at $from.");
      // // For debugging: print valid moves
      // print("Valid moves: ${validMoves.map((p) => '(${p.row},${p.col})').join(', ')}");
      // print("Current board state:\n${_boardToString()}"); // Add board print for context
      return false;
    }

    // --- Pre-move state capture ---
    final PieceEntity? capturedPiece =
        _board[to.row][to
            .col]; // Could be null, relevant for non-en passant captures
    final Position? previousEnPassantTarget = _enPassantTargetSquare;
    _enPassantTargetSquare =
        null; // Reset en passant target for the next turn by default

    // --- Handle Special Moves ---
    bool isCastlingMove = false;
    Position?
    enPassantCaptureSquare; // Square of the pawn being captured en passant

    // 1. En Passant Capture Detection & Execution
    if (piece is Pawn && to == previousEnPassantTarget) {
      // The pawn being captured is behind the target square 'to'
      final capturedPawnRow =
          to.row + (piece.color == PieceColor.white ? 1 : -1);
      enPassantCaptureSquare = Position(capturedPawnRow, to.col);
      if (enPassantCaptureSquare.isValid()) {
        // print("En passant capture: Removing pawn at $enPassantCaptureSquare");
        _board[enPassantCaptureSquare.row][enPassantCaptureSquare.col] =
            null; // Remove the captured pawn
      } else {
        // This case should ideally not happen if enPassantTarget was set correctly
        // print("Warning: Invalid en passant capture square calculated: $enPassantCaptureSquare");
      }
    }

    // 2. Castling Detection & Rook Move
    if (piece.type == PieceType.king && (to.col - from.col).abs() == 2) {
      _handleCastlingRookMove(from, to); // Move the corresponding rook
      isCastlingMove = true;
      // print("Castling move executed for ${piece.color}.");
    }

    // --- Execute the main piece move ---
    bool isDoublePawnMove = piece is Pawn && (to.row - from.row).abs() == 2;
    PieceEntity movedPiece = piece.copyWith(
      position: to,
      hasMoved: true, // Mark the piece as moved
    );
    _board[to.row][to.col] =
        movedPiece; // Place the piece (king or pawn) at the destination
    _board[from.row][from.col] = null; // Clear the origin square

    // Set new en passant target square if it was a double pawn move
    if (isDoublePawnMove) {
      // The target square is the square the pawn skipped over
      _enPassantTargetSquare = Position(
        from.row + (piece.color == PieceColor.white ? -1 : 1),
        from.col,
      );
      // print("En passant target set to: $_enPassantTargetSquare");
    }

    // 3. Pawn Promotion
    if (piece is Pawn && piece.canPromote(to)) {
      // Check promotion based on target square 'to'
      if (promotionType == null ||
          promotionType == PieceType.king ||
          promotionType == PieceType.pawn) {
        // Default to Queen if no valid type provided
        promotionType = PieceType.queen;
        // print("Pawn promotion: No valid type provided, defaulting to Queen.");
      }
      movedPiece = _createPromotedPiece(piece.color, to, promotionType);
      _board[to.row][to.col] =
          movedPiece; // Replace the pawn with the promoted piece
      // print("Pawn promoted to $promotionType at $to");
    }

    // --- Post-move updates ---
    _lastMovedPiece = movedPiece; // Use the potentially promoted piece
    _lastMoveFrom = from;
    _lastMoveTo = to;

    // Check game over conditions for the opponent
    final opponentColor = _getOppositeColor(_currentTurn);
    if (_isCheckmate(opponentColor)) {
      _isGameOver = true;
      _winner = _currentTurn;
      // print("Checkmate! Winner: $_winner");
    } else if (_isStalemate(opponentColor)) {
      _isGameOver = true;
      _winner = null;
      // print("Stalemate!");
    } else if (_isInCheck(opponentColor)) {
      // print("${opponentColor.toString().split('.').last} is in check.");
    }

    _currentTurn = opponentColor; // Switch turn
    notifyListeners();
    // print("Move successful: ${piece.type} from $from to $to. Turn: $_currentTurn");
    return true;
  }

  // Remove the separate promotion method
  /*
  @override
  bool movePieceWithPromotion(
    Position from,
    Position to,
    PieceType promotionType,
  ) {
    // ... (old implementation removed) ...
  }
  */

  PieceEntity _createPromotedPiece(
    PieceColor color,
    Position position,
    PieceType type,
  ) {
    switch (type) {
      case PieceType.queen:
        return Queen(color: color, position: position, hasMoved: true);
      case PieceType.rook:
        return Rook(color: color, position: position, hasMoved: true);
      case PieceType.bishop:
        return Bishop(color: color, position: position, hasMoved: true);
      case PieceType.knight:
        return Knight(color: color, position: position, hasMoved: true);
      default: // Should be validated before calling, but throw error just in case
        // print("Error: Attempted to promote to invalid type $type");
        throw ArgumentError('Invalid promotion type: $type');
    }
  }

  @override
  void reset() {
    _board = List.generate(8, (_) => List.filled(8, null));
    _currentTurn = PieceColor.white;
    _isGameOver = false;
    _winner = null;
    _lastMovedPiece = null; // Reset last move info
    _lastMoveFrom = null;
    _lastMoveTo = null;
    _enPassantTargetSquare = null; // Reset en passant target
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

  // Handles moving the rook during castling
  void _handleCastlingRookMove(Position kingFrom, Position kingTo) {
    final row = kingFrom.row;
    final bool isKingside =
        kingTo.col >
        kingFrom.col; // King moves to col 6 (kingside) or 2 (queenside)
    final rookFromCol = isKingside ? 7 : 0;
    final rookToCol =
        isKingside ? 5 : 3; // Rook destination column (f file or d file)

    final rook = _board[row][rookFromCol];
    if (rook != null && rook.type == PieceType.rook) {
      // Check type for safety
      _board[row][rookToCol] = rook.copyWith(
        position: Position(row, rookToCol),
        hasMoved: true, // Mark rook as moved
      );
      _board[row][rookFromCol] = null; // Remove rook from original square
    } else {
      // This should not happen if getValidMovesForPiece worked correctly
      // print("Error: Rook not found or invalid for castling at ($row, $rookFromCol) when king moved $kingFrom -> $kingTo");
    }
  }

  bool _isCheckmate(PieceColor color) {
    // Checkmate if currently in check AND has no valid moves
    if (!_isInCheck(color)) return false;
    return !_hasAnyValidMoves(color);
  }

  bool _isStalemate(PieceColor color) {
    // Stalemate if NOT in check AND has no valid moves
    if (_isInCheck(color)) return false;
    return !_hasAnyValidMoves(color);
  }

  // Checks if the given color has ANY valid moves on the board
  bool _hasAnyValidMoves(PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _board[row][col];
        if (piece != null && piece.color == color) {
          // Must check moves within the context of the correct player's turn
          final originalTurn = _currentTurn;
          bool hasMoves = false;
          try {
            _currentTurn = color; // Set context for getValidMovesForPiece
            if (getValidMovesForPiece(Position(row, col)).isNotEmpty) {
              hasMoves = true;
            }
          } finally {
            _currentTurn = originalTurn; // Restore original turn context
          }
          if (hasMoves)
            return true; // Found a valid move for at least one piece
        }
      }
    }
    // print("No valid moves found for $color");
    return false; // No valid moves found for any piece of this color
  }

  // Is the king of the specified color currently under attack?
  bool _isInCheck(PieceColor color) {
    Position? kingPosition = _findKing(color);
    if (kingPosition == null) {
      // print("Error: King of color $color not found! Cannot determine check status.");
      return false; // Cannot be in check if king doesn't exist (indicates error state)
    }
    return _isSquareUnderAttack(kingPosition, color, _board);
  }

  // Checks if a square (targetPos) is attacked by the opponent of the targetColor
  // Uses the provided board state
  bool _isSquareUnderAttack(
    Position targetPos,
    PieceColor targetColor,
    List<List<PieceEntity?>> board,
  ) {
    final attackerColor = _getOppositeColor(targetColor);
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece != null && piece.color == attackerColor) {
          // Use raw possible moves from the piece logic.
          // Pass enPassantTarget only if the piece is a Pawn.
          final attackMoves =
              (piece is Pawn)
                  ? piece.getPossibleMoves(
                    board,
                    null,
                  ) // Pass null for en passant target in attack check
                  : piece.getPossibleMoves(
                    board,
                  ); // Other pieces don't need enPassantTarget
          if (attackMoves.contains(targetPos)) {
            // print("Square ($targetPos.row, $targetPos.col) is under attack by ${piece.type} at ($r, $c)");
            return true;
          }
        }
      }
    }
    return false;
  }

  Position? _findKing(PieceColor color) {
    return _findKingOnBoard(color, _board); // Use helper on current board
  }

  // Simulates a move and checks if it leaves the king of the moving piece's color in check
  // Operates on a temporary copy of the board state.
  bool _wouldPutKingInCheck(Position from, Position to) {
    final piece = _board[from.row][from.col];
    if (piece == null)
      return true; // Should not happen if called correctly, but safety check

    final kingColor = piece.color;

    // Create a temporary board copy to simulate the move safely
    List<List<PieceEntity?>> tempBoard = List.generate(
      8,
      (r) => List.from(_board[r]),
    );

    // --- Simulate the move on the temporary board ---

    // 1. Simulate En Passant Capture (if applicable)
    if (piece is Pawn && to == _enPassantTargetSquare) {
      final capturedPawnRow =
          to.row + (piece.color == PieceColor.white ? 1 : -1);
      final capturedPawnCol = to.col;
      if (Position(capturedPawnRow, capturedPawnCol).isValid()) {
        tempBoard[capturedPawnRow][capturedPawnCol] = null;
      }
    }

    // 2. Simulate Castling Rook Move (if applicable)
    if (piece.type == PieceType.king && (to.col - from.col).abs() == 2) {
      final row = from.row;
      final isKingside = to.col > from.col;
      final rookFromCol = isKingside ? 7 : 0;
      final rookToCol = isKingside ? 5 : 3;
      final rook =
          tempBoard[row][rookFromCol]; // Get rook from temp board's original position
      if (rook != null && rook.type == PieceType.rook) {
        tempBoard[row][rookToCol] = rook.copyWith(
          position: Position(row, rookToCol),
        );
        tempBoard[row][rookFromCol] = null;
      }
    }

    // 3. Simulate the main piece move
    // Note: We don't need to worry about hasMoved or promotion for check detection
    tempBoard[to.row][to.col] = piece.copyWith(position: to);
    tempBoard[from.row][from.col] = null;

    // --- Check for check on the temporary board ---
    // Find the king's position *on the temporary board*
    Position? kingPos = _findKingOnBoard(kingColor, tempBoard);

    // If king position is somehow null after move (shouldn't happen), assume check for safety
    if (kingPos == null) {
      // print("Error: King not found on temp board after simulating move $from -> $to");
      return true;
    }

    // Is the king's square under attack on the temporary board?
    final bool leavesKingInCheck = _isSquareUnderAttack(
      kingPos,
      kingColor,
      tempBoard,
    );

    // No need to undo the move as we operated on a temporary board copy

    return leavesKingInCheck;
  }

  // Helper to find king on a specific board state (used by _wouldPutKingInCheck)
  Position? _findKingOnBoard(PieceColor color, List<List<PieceEntity?>> board) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == color) {
          return Position(row, col);
        }
      }
    }
    // print("Warning: King of color $color not found on the provided board state.");
    return null; // King not found
  }

  PieceColor _getOppositeColor(PieceColor color) {
    return color == PieceColor.white ? PieceColor.black : PieceColor.white;
  }

  // Helper for debugging
  String _boardToString() {
    StringBuffer sb = StringBuffer();
    for (int r = 0; r < 8; r++) {
      sb.write('${8 - r} |');
      for (int c = 0; c < 8; c++) {
        final piece = _board[r][c];
        if (piece == null) {
          sb.write(' . ');
        } else {
          String pChar = piece.type.toString().split('.').last[0].toUpperCase();
          if (piece.type == PieceType.knight) pChar = 'N';
          sb.write(
            ' ${piece.color == PieceColor.white ? pChar : pChar.toLowerCase()} ',
          );
        }
      }
      sb.write('\n');
    }
    sb.write('   ------------------------\n');
    sb.write('    a  b  c  d  e  f  g  h \n');
    sb.write('Turn: $_currentTurn\n');
    sb.write('En Passant Target: $_enPassantTargetSquare\n');
    return sb.toString();
  }
}
