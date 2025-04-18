import 'package:logging/logging.dart';
import '../domain/entities/pieces/pawn.dart';
import '../domain/entities/pieces/king.dart';
import '../domain/entities/pieces/queen.dart';
import '../domain/entities/pieces/rook.dart';
import '../domain/entities/pieces/bishop.dart';
import '../domain/entities/pieces/knight.dart';
import '../domain/entities/piece_entity.dart';
import '../domain/value_objects/piece_color.dart';
import '../domain/value_objects/piece_type.dart';
import '../domain/value_objects/position.dart';
import 'utils/chess_utils.dart';

/// Class responsible for executing chess moves
class MoveExecutor {
  static final _log = Logger('MoveExecutor');

  /// Create a piece that results from pawn promotion
  static PieceEntity createPromotedPiece(
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
        _log.severe("Error: Attempted to promote to invalid type $type");
        throw ArgumentError('Invalid promotion type: $type');
    }
  }

  /// Handle moving the rook during castling
  static void handleCastlingRookMove(
    Position kingFrom,
    Position kingTo,
    List<List<PieceEntity?>> board,
  ) {
    final row = kingFrom.row;
    final bool isKingside =
        kingTo.col >
        kingFrom.col; // King moves to col 6 (kingside) or 2 (queenSide)
    final rookFromCol = isKingside ? 7 : 0;
    final rookToCol =
        isKingside ? 5 : 3; // Rook destination column (f file or d file)

    final rook = board[row][rookFromCol];
    if (rook != null &&
        rook.type == PieceType.rook &&
        board[row][rookFromCol] == rook) {
      // Check type for safety and that the rook is actually at the expected position
      board[row][rookToCol] = rook.copyWith(
        position: Position(row, rookToCol),
        hasMoved: true, // Mark rook as moved
      );
      board[row][rookFromCol] = null; // Remove rook from original square
    } else {
      // This should not happen if getValidMovesForPiece worked correctly
      _log.severe(
        "Rook not found or invalid for castling at ($row, $rookFromCol) when king moved $kingFrom -> $kingTo",
      );
    }
  }

  /// Execute a move
  /// Returns a tuple containing:
  /// - PieceColor? - The winner if the game is over, null if draw or game continues
  /// - bool - Whether the game is over
  /// - String - The algebraic notation of the move
  /// - Position? - The en passant target square for the next move
  static ({
    PieceColor? winner,
    bool isGameOver,
    String moveNotation,
    Position? enPassantTargetSquare,
    PieceEntity? capturedPiece,
  })
  executeMove(
    Position from,
    Position to,
    PieceType? promotionType,
    List<List<PieceEntity?>> board,
    PieceColor currentTurn,
    Position? enPassantTargetSquare,
  ) {
    final piece = board[from.row][from.col];

    if (piece == null) {
      _log.warning("Attempted to move a non-existent piece from $from");
      return (
        winner: null,
        isGameOver: false,
        moveNotation: "",
        enPassantTargetSquare: null,
        capturedPiece: null,
      );
    }

    // --- Pre-move state capture ---
    final PieceEntity? capturedPiece =
        board[to.row][to.col]; // Target square capture
    final Position? previousEnPassantTarget = enPassantTargetSquare;
    Position? newEnPassantTargetSquare; // Reset en passant target by default
    PieceEntity? actualCapturedPiece =
        capturedPiece; // This might change for en passant

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
        // Capture the pawn
        actualCapturedPiece =
            board[enPassantCaptureSquare.row][enPassantCaptureSquare.col];
        if (actualCapturedPiece is Pawn) {
          _log.fine(
            "En passant capture: Removing pawn at $enPassantCaptureSquare",
          );
          board[enPassantCaptureSquare.row][enPassantCaptureSquare.col] = null;
        } else {
          _log.warning(
            "No pawn found at calculated en passant capture square: $enPassantCaptureSquare",
          );
        }
      } else {
        _log.warning(
          "Invalid en passant capture square calculated: $enPassantCaptureSquare",
        );
      }
    }

    // 2. Castling Detection & Rook Move
    if (piece.type == PieceType.king && (to.col - from.col).abs() == 2) {
      handleCastlingRookMove(from, to, board); // Move the corresponding rook
      isCastlingMove = true;

      // Move the king
      final movedKing = piece.copyWith(position: to, hasMoved: true);
      board[to.row][to.col] = movedKing;
      board[from.row][from.col] = null;

      _log.fine("Castling move executed for ${piece.color}.");
    }

    // --- Execute the main piece move ---
    bool isDoublePawnMove = piece is Pawn && (to.row - from.row).abs() == 2;
    PieceEntity movedPiece = piece.copyWith(
      position: to,
      hasMoved: true, // Mark the piece as moved
    );
    board[to.row][to.col] = movedPiece; // Place the piece at the destination
    board[from.row][from.col] = null; // Clear the origin square

    // Set new en passant target square if it was a double pawn move
    if (isDoublePawnMove) {
      // The target square is the square the pawn skipped over
      newEnPassantTargetSquare = Position(
        from.row + (piece.color == PieceColor.white ? -1 : 1),
        from.col,
      );
      _log.fine("En passant target set to: $newEnPassantTargetSquare");
    }

    // 3. Pawn Promotion
    if (piece is Pawn && piece.canPromote(to)) {
      // Check promotion based on target square 'to'
      if (promotionType == null ||
          promotionType == PieceType.king ||
          promotionType == PieceType.pawn) {
        // Default to Queen if no valid type provided
        promotionType = PieceType.queen;
        _log.fine(
          "Pawn promotion: No valid type provided, defaulting to Queen.",
        );
      }
      movedPiece = createPromotedPiece(piece.color, to, promotionType);
      board[to.row][to.col] =
          movedPiece; // Replace the pawn with the promoted piece
      _log.fine("Pawn promoted to $promotionType at $to");
    }

    // Create move notation
    String moveNotation = ChessUtils.convertToAlgebraicNotation(
      from,
      to,
      piece,
      promotionType,
      actualCapturedPiece,
    );

    // Return the execution results
    return (
      winner: null, // Winner will be determined by caller using MoveValidator
      isGameOver: false, // Game over state will be determined by caller
      moveNotation: moveNotation,
      enPassantTargetSquare: newEnPassantTargetSquare,
      capturedPiece: actualCapturedPiece,
    );
  }
}
