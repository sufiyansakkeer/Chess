import 'package:logging/logging.dart';
import '../domain/entities/pieces/pawn.dart';
import '../domain/entities/pieces/king.dart';
import '../domain/entities/piece_entity.dart';
import '../domain/value_objects/piece_color.dart';
import '../domain/value_objects/piece_type.dart';
import '../domain/value_objects/position.dart';
import 'utils/chess_utils.dart';

/// Class responsible for validating chess moves and checking game conditions
class MoveValidator {
  static final _log = Logger('MoveValidator');

  /// Check if a square is under attack by the opponent
  static bool isSquareUnderAttack(
    Position targetPos,
    PieceColor targetColor,
    List<List<PieceEntity?>> board,
  ) {
    _log.fine(
      'Checking if square $targetPos is under attack by opponent of $targetColor',
    );
    final attackerColor = ChessUtils.getOppositeColor(targetColor);
    _log.finer('Attacker color: $attackerColor');

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece != null && piece.color == attackerColor) {
          _log.finer('Found potential attacker: ${piece.type} at ($r, $c)');
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
            _log.fine(
              "Square $targetPos is under attack by ${piece.type} at ($r, $c)",
            );
            return true;
          }
        }
      }
    }
    _log.fine('Square $targetPos is not under attack');
    return false;
  }

  /// Find the king of specified color on the board
  static Position? findKingOnBoard(
    PieceColor color,
    List<List<PieceEntity?>> board,
  ) {
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
    _log.warning("King of color $color not found on the provided board state.");
    return null; // King not found
  }

  /// Check if the king of specified color is in check
  static bool isInCheck(PieceColor color, List<List<PieceEntity?>> board) {
    _log.fine('Checking check status for color: $color');
    Position? kingPosition = findKingOnBoard(color, board);

    if (kingPosition == null) {
      _log.severe(
        'King of color $color not found! Cannot determine check status.',
      );
      return false; // Cannot be in check if king doesn't exist (indicates error state)
    }

    _log.finer('King position: $kingPosition');
    final result = isSquareUnderAttack(kingPosition, color, board);
    _log.fine('King is in check: $result');
    return result;
  }

  /// Simulate a move and check if it would put the king in check
  static bool wouldPutKingInCheck(
    Position from,
    Position to,
    List<List<PieceEntity?>> board,
    Position? enPassantTargetSquare,
  ) {
    final piece = board[from.row][from.col];
    if (piece == null) {
      return true; // Should not happen if called correctly, but safety check
    }

    final kingColor = piece.color;

    // Create a temporary board copy to simulate the move safely
    List<List<PieceEntity?>> tempBoard = List.generate(
      8,
      (r) => List.from(board[r]),
    );

    // --- Simulate the move on the temporary board ---

    // 1. Simulate En Passant Capture (if applicable)
    if (piece is Pawn && to == enPassantTargetSquare) {
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
      final rook = tempBoard[row][rookFromCol];
      if (rook != null && rook.type == PieceType.rook) {
        tempBoard[row][rookToCol] = rook.copyWith(
          position: Position(row, rookToCol),
        );
        tempBoard[row][rookFromCol] = null;
      }
    }

    // 3. Simulate the main piece move
    tempBoard[to.row][to.col] = piece.copyWith(position: to);
    tempBoard[from.row][from.col] = null;

    // Find the king's position on the temporary board
    Position? kingPos = findKingOnBoard(kingColor, tempBoard);

    // If king position is somehow null after move (shouldn't happen), assume check for safety
    if (kingPos == null) {
      _log.warning(
        "King not found on temp board after simulating move $from -> $to",
      );
      return true;
    }

    // Is the king's square under attack on the temporary board?
    return isSquareUnderAttack(kingPos, kingColor, tempBoard);
  }

  /// Get potential castling moves for a king
  static List<Position> getPotentialCastlingMoves(
    King king,
    List<List<PieceEntity?>> board,
  ) {
    List<Position> moves = [];
    // Cannot castle if king moved or is currently in check
    if (king.hasMoved || isInCheck(king.color, board)) return moves;

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

    // QueenSide (O-O-O) Target square: (row, 2)
    final queenSideRook = board[row][0];
    if (queenSideRook != null &&
        queenSideRook.type == PieceType.rook &&
        !queenSideRook.hasMoved) {
      // Check squares between king (col 4) and rook (col 0) are empty: (row, 1), (row, 2), (row, 3)
      if (board[row][1] == null &&
          board[row][2] == null &&
          board[row][3] == null) {
        moves.add(Position(row, 2)); // Target square for queenSide castle
      }
    }
    return moves;
  }

  /// Check if the castling path is clear of attacks
  static bool isCastlingPathClear(
    King king,
    Position kingTo,
    List<List<PieceEntity?>> board,
  ) {
    final row = king.position.row;
    final kingFromCol = king.position.col; // Should be 4
    final direction = kingTo.col > kingFromCol ? 1 : -1;

    // Check squares from king's current position up to AND INCLUDING the destination square
    for (int col = kingFromCol; ; col += direction) {
      if (isSquareUnderAttack(Position(row, col), king.color, board)) {
        _log.fine(
          "Castling path blocked: Square ($row, $col) is under attack.",
        );
        return false; // Path is attacked
      }
      if (col == kingTo.col) {
        break; // Stop after checking the destination square
      }
    }

    return true; // Path is clear
  }

  /// Get valid moves for a piece at the specified position
  static List<Position> getValidMovesForPiece(
    Position position,
    List<List<PieceEntity?>> board,
    PieceColor currentTurn,
    Position? enPassantTargetSquare,
  ) {
    final piece = board[position.row][position.col];
    if (piece == null || piece.color != currentTurn) return [];

    // Get moves from piece logic (including potential en passant captures)
    List<Position> possibleMoves =
        (piece is Pawn)
            ? piece.getPossibleMoves(board, enPassantTargetSquare)
            : piece.getPossibleMoves(
              board,
            ); // Other pieces don't need enPassantTarget

    // Add potential castling moves (checks piece positions, move history, but NOT path attacks yet)
    if (piece is King) {
      possibleMoves.addAll(getPotentialCastlingMoves(piece, board));
    }

    // Filter moves:
    // 1. Remove moves that leave the king in check.
    // 2. Specifically validate castling moves for passing through check.
    return possibleMoves.where((to) {
      // Special validation for castling: check if king passes through attacked squares
      if (piece is King && (to.col - position.col).abs() == 2) {
        if (!isCastlingPathClear(piece, to, board)) {
          return false; // Invalid castling move due to path attack
        }
      }
      // General validation: does the move leave the king in check?
      return !wouldPutKingInCheck(position, to, board, enPassantTargetSquare);
    }).toList();
  }

  /// Check if a player has any valid moves
  static bool hasAnyValidMoves(
    PieceColor color,
    List<List<PieceEntity?>> board,
    Position? enPassantTargetSquare,
  ) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == color) {
          if (getValidMovesForPiece(
            Position(row, col),
            board,
            color,
            enPassantTargetSquare,
          ).isNotEmpty) {
            return true; // Found a valid move for at least one piece
          }
        }
      }
    }
    _log.fine("No valid moves found for $color");
    return false; // No valid moves found for any piece of this color
  }

  /// Check if the specified color is in checkmate
  static bool isCheckmate(
    PieceColor color,
    List<List<PieceEntity?>> board,
    Position? enPassantTargetSquare,
  ) {
    // Checkmate if currently in check AND has no valid moves
    if (!isInCheck(color, board)) return false;
    return !hasAnyValidMoves(color, board, enPassantTargetSquare);
  }

  /// Check if the specified color is in stalemate
  static bool isStalemate(
    PieceColor color,
    List<List<PieceEntity?>> board,
    Position? enPassantTargetSquare,
  ) {
    // Stalemate if NOT in check AND has no valid moves
    if (isInCheck(color, board)) return false;
    return !hasAnyValidMoves(color, board, enPassantTargetSquare);
  }
}
