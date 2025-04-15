import '../../value_objects/piece_type.dart';
import '../../value_objects/position.dart';
import '../piece_entity.dart';

class King extends PieceEntity {
  King({required super.color, required super.position, super.hasMoved})
    : super(type: PieceType.king);

  @override
  List<Position> getPossibleMoves(List<List<PieceEntity?>> board) {
    List<Position> moves = [];
    final directions = [
      [-1, -1], [-1, 0], [-1, 1], // top-left, top, top-right
      [0, -1], [0, 1], // left, right
      [1, -1], [1, 0], [1, 1], // bottom-left, bottom, bottom-right
    ];

    // Normal moves
    for (var direction in directions) {
      final newRow = position.row + direction[0];
      final newCol = position.col + direction[1];

      Position newPos = Position(newRow, newCol);
      if (!newPos.isValid()) continue;

      final pieceAtPosition = board[newRow][newCol];
      if (pieceAtPosition == null || pieceAtPosition.color != color) {
        moves.add(newPos);
      }
    }

    // Castling moves
    if (!hasMoved && !_isInCheck(board)) {
      // Kingside castling
      if (_canCastleKingside(board)) {
        moves.add(Position(position.row, position.col + 2));
      }
      // Queenside castling
      if (_canCastleQueenside(board)) {
        moves.add(Position(position.row, position.col - 2));
      }
    }

    return moves;
  }

  bool _canCastleKingside(List<List<PieceEntity?>> board) {
    if (board[position.row][7] == null) return false;

    final rook = board[position.row][7];
    if (rook?.type != PieceType.rook || rook?.hasMoved == true) return false;

    // Check if squares between king and rook are empty
    for (int col = position.col + 1; col < 7; col++) {
      if (board[position.row][col] != null) return false;
    }

    // Check if squares king moves through are not under attack
    for (int col = position.col; col <= position.col + 2; col++) {
      if (_isSquareUnderAttack(Position(position.row, col), board)) {
        return false;
      }
    }

    return true;
  }

  bool _canCastleQueenside(List<List<PieceEntity?>> board) {
    if (board[position.row][0] == null) return false;

    final rook = board[position.row][0];
    if (rook?.type != PieceType.rook || rook?.hasMoved == true) return false;

    // Check if squares between king and rook are empty
    for (int col = position.col - 1; col > 0; col--) {
      if (board[position.row][col] != null) return false;
    }

    // Check if squares king moves through are not under attack
    for (int col = position.col; col >= position.col - 2; col--) {
      if (_isSquareUnderAttack(Position(position.row, col), board)) {
        return false;
      }
    }

    return true;
  }

  bool _isInCheck(List<List<PieceEntity?>> board) {
    return _isSquareUnderAttack(position, board);
  }

  bool _isSquareUnderAttack(Position pos, List<List<PieceEntity?>> board) {
    // Check all opponent pieces to see if they can attack the given square
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color != color) {
          final moves = piece.getPossibleMoves(board);
          if (moves.contains(pos)) return true;
        }
      }
    }
    return false;
  }

  @override
  PieceEntity copyWith({Position? position, bool? hasMoved}) {
    return King(
      color: color,
      position: position ?? this.position,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }
}
