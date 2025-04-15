import 'position.dart';

enum PieceType { pawn, rook, knight, bishop, queen, king }

enum PieceColor { white, black }

abstract class Piece {
  final PieceType type;
  final PieceColor color;
  final Position position;
  bool hasMoved = false;

  Piece(this.type, this.color, this.position);

  List<Position> getPossibleMoves(List<List<Piece?>> board);

  bool isValidMove(Position target, List<List<Piece?>> board) {
    return getPossibleMoves(board).any((pos) => pos == target);
  }

  Piece copyWith({Position? position, bool? hasMoved});
}

class Pawn extends Piece {
  Position? enPassantTarget;

  Pawn(PieceColor color, Position position, {this.enPassantTarget})
    : super(PieceType.pawn, color, position);

  @override
  List<Position> getPossibleMoves(List<List<Piece?>> board) {
    List<Position> moves = [];
    int direction = color == PieceColor.white ? -1 : 1;

    // Forward move
    Position forward = Position(position.row + direction, position.col);
    if (forward.isValid() && board[forward.row][forward.col] == null) {
      moves.add(forward);

      // Initial two-square move
      if (!hasMoved) {
        Position doubleForward = Position(
          position.row + 2 * direction,
          position.col,
        );
        if (doubleForward.isValid() &&
            board[doubleForward.row][doubleForward.col] == null) {
          moves.add(doubleForward);
        }
      }
    }

    // Regular captures
    for (int colOffset in [-1, 1]) {
      Position capture = Position(
        position.row + direction,
        position.col + colOffset,
      );
      if (capture.isValid()) {
        Piece? targetPiece = board[capture.row][capture.col];
        if (targetPiece != null && targetPiece.color != color) {
          moves.add(capture);
        }
      }
    }

    // En passant capture
    if (enPassantTarget != null &&
        ((color == PieceColor.white && position.row == 3) ||
            (color == PieceColor.black && position.row == 4))) {
      int colDiff = enPassantTarget!.col - position.col;
      if (colDiff.abs() == 1 &&
          enPassantTarget!.row == position.row + direction) {
        moves.add(enPassantTarget!);
      }
    }

    return moves;
  }

  @override
  Piece copyWith({Position? position, bool? hasMoved}) {
    Pawn newPawn = Pawn(
      color,
      position ?? this.position,
      enPassantTarget: enPassantTarget,
    );
    newPawn.hasMoved = hasMoved ?? this.hasMoved;
    return newPawn;
  }
}

class Rook extends Piece {
  Rook(PieceColor color, Position position)
    : super(PieceType.rook, color, position);

  @override
  List<Position> getPossibleMoves(List<List<Piece?>> board) {
    List<Position> moves = [];
    final directions = [
      [-1, 0], // up
      [1, 0], // down
      [0, -1], // left
      [0, 1], // right
    ];

    for (var direction in directions) {
      var currentRow = position.row;
      var currentCol = position.col;

      while (true) {
        currentRow += direction[0];
        currentCol += direction[1];

        Position newPos = Position(currentRow, currentCol);
        if (!newPos.isValid()) break;

        Piece? targetPiece = board[currentRow][currentCol];
        if (targetPiece == null) {
          moves.add(newPos);
        } else {
          if (targetPiece.color != color) {
            moves.add(newPos);
          }
          break;
        }
      }
    }

    return moves;
  }

  @override
  Piece copyWith({Position? position, bool? hasMoved}) {
    Rook newRook = Rook(color, position ?? this.position);
    newRook.hasMoved = hasMoved ?? this.hasMoved;
    return newRook;
  }
}

class Knight extends Piece {
  Knight(PieceColor color, Position position)
    : super(PieceType.knight, color, position);

  @override
  List<Position> getPossibleMoves(List<List<Piece?>> board) {
    List<Position> moves = [];
    final offsets = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1],
    ];

    for (var offset in offsets) {
      Position newPos = Position(
        position.row + offset[0],
        position.col + offset[1],
      );
      if (newPos.isValid()) {
        Piece? targetPiece = board[newPos.row][newPos.col];
        if (targetPiece == null || targetPiece.color != color) {
          moves.add(newPos);
        }
      }
    }

    return moves;
  }

  @override
  Piece copyWith({Position? position, bool? hasMoved}) {
    Knight newKnight = Knight(color, position ?? this.position);
    newKnight.hasMoved = hasMoved ?? this.hasMoved;
    return newKnight;
  }
}

class Bishop extends Piece {
  Bishop(PieceColor color, Position position)
    : super(PieceType.bishop, color, position);

  @override
  List<Position> getPossibleMoves(List<List<Piece?>> board) {
    List<Position> moves = [];
    final directions = [
      [-1, -1], [-1, 1], [1, -1], [1, 1], // diagonals
    ];

    for (var direction in directions) {
      var currentRow = position.row;
      var currentCol = position.col;

      while (true) {
        currentRow += direction[0];
        currentCol += direction[1];

        Position newPos = Position(currentRow, currentCol);
        if (!newPos.isValid()) break;

        Piece? targetPiece = board[currentRow][currentCol];
        if (targetPiece == null) {
          moves.add(newPos);
        } else {
          if (targetPiece.color != color) {
            moves.add(newPos);
          }
          break;
        }
      }
    }

    return moves;
  }

  @override
  Piece copyWith({Position? position, bool? hasMoved}) {
    Bishop newBishop = Bishop(color, position ?? this.position);
    newBishop.hasMoved = hasMoved ?? this.hasMoved;
    return newBishop;
  }
}

class Queen extends Piece {
  Queen(PieceColor color, Position position)
    : super(PieceType.queen, color, position);

  @override
  List<Position> getPossibleMoves(List<List<Piece?>> board) {
    List<Position> moves = [];
    final directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1],
    ];

    for (var direction in directions) {
      var currentRow = position.row;
      var currentCol = position.col;

      while (true) {
        currentRow += direction[0];
        currentCol += direction[1];

        Position newPos = Position(currentRow, currentCol);
        if (!newPos.isValid()) break;

        Piece? targetPiece = board[currentRow][currentCol];
        if (targetPiece == null) {
          moves.add(newPos);
        } else {
          if (targetPiece.color != color) {
            moves.add(newPos);
          }
          break;
        }
      }
    }

    return moves;
  }

  @override
  Piece copyWith({Position? position, bool? hasMoved}) {
    Queen newQueen = Queen(color, position ?? this.position);
    newQueen.hasMoved = hasMoved ?? this.hasMoved;
    return newQueen;
  }
}

class King extends Piece {
  King(PieceColor color, Position position)
    : super(PieceType.king, color, position);

  @override
  List<Position> getPossibleMoves(List<List<Piece?>> board) {
    List<Position> moves = [];
    final directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1],
    ];

    for (var direction in directions) {
      Position newPos = Position(
        position.row + direction[0],
        position.col + direction[1],
      );

      if (newPos.isValid()) {
        Piece? targetPiece = board[newPos.row][newPos.col];
        if (targetPiece == null || targetPiece.color != color) {
          moves.add(newPos);
        }
      }
    }

    // Castling logic
    if (!hasMoved && !isInCheck(board)) {
      // Kingside castling
      if (canCastle(board, true)) {
        moves.add(Position(position.row, position.col + 2));
      }
      // Queenside castling
      if (canCastle(board, false)) {
        moves.add(Position(position.row, position.col - 2));
      }
    }

    return moves;
  }

  bool canCastle(List<List<Piece?>> board, bool kingSide) {
    int row = position.row;
    int col = position.col;
    int direction = kingSide ? 1 : -1;
    int endCol = kingSide ? 7 : 0;

    // Check if rook has moved
    Piece? rook = board[row][endCol];
    if (rook == null || rook.type != PieceType.rook || rook.hasMoved) {
      return false;
    }

    // Check if path is clear
    int steps = kingSide ? 2 : 3;
    for (int i = 1; i <= steps; i++) {
      if (board[row][col + (direction * i)] != null) {
        return false;
      }
    }

    return true;
  }

  bool isInCheck(List<List<Piece?>> board) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        Piece? piece = board[row][col];
        if (piece != null && piece.color != color) {
          if (piece.getPossibleMoves(board).contains(position)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  @override
  Piece copyWith({Position? position, bool? hasMoved}) {
    King newKing = King(color, position ?? this.position);
    newKing.hasMoved = hasMoved ?? this.hasMoved;
    return newKing;
  }
}
