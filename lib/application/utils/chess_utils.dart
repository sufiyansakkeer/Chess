import '../../domain/value_objects/piece_color.dart';
import '../../domain/value_objects/piece_type.dart';
import '../../domain/entities/piece_entity.dart';
import '../../domain/value_objects/position.dart';

/// Utility class containing helper functions for chess operations
class ChessUtils {
  /// Get the opposite color
  static PieceColor getOppositeColor(PieceColor color) {
    return color == PieceColor.white ? PieceColor.black : PieceColor.white;
  }

  /// Convert a move to algebraic notation
  static String convertToAlgebraicNotation(
    Position from,
    Position to,
    PieceEntity? piece,
    PieceType? promotionType,
    PieceEntity? capturedPiece,
  ) {
    String notation = '';

    if (piece != null) {
      if (piece.type == PieceType.pawn) {
        // Pawns don't have a piece identifier unless capturing
        if (capturedPiece != null) {
          notation += String.fromCharCode(from.col + 97); // File of origin
        }
      } else {
        notation += piece.type.toString().split('.').last[0].toUpperCase();
        if (piece.type == PieceType.knight) notation = 'N';
      }
    }

    // Indicate capture
    if (capturedPiece != null) {
      notation += 'x';
    }

    // Destination square
    notation += String.fromCharCode(to.col + 97); // File
    notation += (8 - to.row).toString(); // Rank

    // Indicate promotion
    if (promotionType != null) {
      notation +=
          '=${promotionType.toString().split('.').last[0].toUpperCase()}';
      if (promotionType == PieceType.knight) notation = 'N';
    }

    return notation;
  }

  /// Convert the board state to a string representation (for debugging)
  static String boardToString(
    List<List<PieceEntity?>> board,
    PieceColor currentTurn,
    Position? enPassantTargetSquare,
  ) {
    StringBuffer sb = StringBuffer();
    for (int r = 0; r < 8; r++) {
      sb.write('${8 - r} |');
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
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
    sb.write('Turn: $currentTurn\n');
    sb.write('En Passant Target: $enPassantTargetSquare\n');
    return sb.toString();
  }
}
