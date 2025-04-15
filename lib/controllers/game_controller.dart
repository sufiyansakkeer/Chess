import 'package:flutter/material.dart';
import '../models/piece.dart';
import '../models/position.dart';

class GameController extends ChangeNotifier {
  late List<List<Piece?>> board;
  PieceColor currentTurn = PieceColor.white;
  Position? selectedPosition;
  List<Position> possibleMoves = [];
  bool isGameOver = false;
  PieceColor? winner;
  List<String> moveHistory = [];

  GameController() {
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(8, (_) => List.filled(8, null));

    // Initialize pawns
    for (int i = 0; i < 8; i++) {
      board[1][i] = Pawn(PieceColor.black, Position(1, i));
      board[6][i] = Pawn(PieceColor.white, Position(6, i));
    }

    // Initialize other pieces
    _initializePieces(0, PieceColor.black);
    _initializePieces(7, PieceColor.white);
  }

  void _initializePieces(int row, PieceColor color) {
    board[row][0] = Rook(color, Position(row, 0));
    board[row][1] = Knight(color, Position(row, 1));
    board[row][2] = Bishop(color, Position(row, 2));
    board[row][3] = Queen(color, Position(row, 3));
    board[row][4] = King(color, Position(row, 4));
    board[row][5] = Bishop(color, Position(row, 5));
    board[row][6] = Knight(color, Position(row, 6));
    board[row][7] = Rook(color, Position(row, 7));
  }

  void selectPosition(Position position) {
    final piece = board[position.row][position.col];

    if (piece != null && piece.color == currentTurn) {
      selectedPosition = position;
      possibleMoves = piece.getPossibleMoves(board);
      // Filter out moves that would put the king in check
      possibleMoves =
          possibleMoves.where((move) => !wouldBeInCheck(piece, move)).toList();
    } else if (selectedPosition != null && possibleMoves.contains(position)) {
      _movePiece(selectedPosition!, position);
      selectedPosition = null;
      possibleMoves = [];
    } else {
      selectedPosition = null;
      possibleMoves = [];
    }

    notifyListeners();
  }

  bool wouldBeInCheck(Piece piece, Position targetPosition) {
    // Create a temporary board to simulate the move
    var tempBoard = List.generate(
      8,
      (i) => List.generate(8, (j) => board[i][j]?.copyWith()),
    );

    // Simulate the move
    tempBoard[targetPosition.row][targetPosition.col] = piece.copyWith(
      position: targetPosition,
    );
    tempBoard[piece.position.row][piece.position.col] = null;

    // Find the king
    Position? kingPosition;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        final p = tempBoard[i][j];
        if (p != null && p.type == PieceType.king && p.color == currentTurn) {
          kingPosition = Position(i, j);
          break;
        }
      }
    }

    if (kingPosition == null) return false;

    // Check if any opponent piece can capture the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        final p = tempBoard[i][j];
        if (p != null && p.color != currentTurn) {
          if (p.getPossibleMoves(tempBoard).contains(kingPosition)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  Future<void> _movePiece(Position from, Position to) async {
    final piece = board[from.row][from.col];
    if (piece == null) return;

    // Record move in history
    String moveNotation = _getMoveNotation(piece, from, to);

    // Handle en passant capture
    if (piece.type == PieceType.pawn) {
      Pawn pawn = piece as Pawn;
      // Check if this is an en passant capture
      if (pawn.enPassantTarget != null && to == pawn.enPassantTarget) {
        // Remove the captured pawn
        board[from.row][to.col] = null;
        moveNotation += ' e.p.';
      }
      // Set en passant target for next move if this is a two square advance
      if ((from.row - to.row).abs() == 2) {
        int captureRow = (from.row + to.row) ~/ 2;
        Position enPassantTarget = Position(captureRow, to.col);

        // Clear previous en passant targets
        for (int i = 0; i < 8; i++) {
          for (int j = 0; j < 8; j++) {
            if (board[i][j] is Pawn) {
              (board[i][j] as Pawn).enPassantTarget = null;
            }
          }
        }

        // Set new en passant target for opponent pawns
        for (int col in [to.col - 1, to.col + 1]) {
          if (col >= 0 && col < 8) {
            if (board[to.row][col] is Pawn &&
                (board[to.row][col] as Piece).color != piece.color) {
              (board[to.row][col] as Pawn).enPassantTarget = enPassantTarget;
            }
          }
        }
      }
    }

    // Handle castling
    if (piece.type == PieceType.king && !piece.hasMoved) {
      if (to.col == from.col + 2) {
        // Kingside castling
        final rook = board[from.row][7];
        board[from.row][5] = rook?.copyWith(
          position: Position(from.row, 5),
          hasMoved: true,
        );
        board[from.row][7] = null;
        moveNotation = 'O-O';
      } else if (to.col == from.col - 2) {
        // Queenside castling
        final rook = board[from.row][0];
        board[from.row][3] = rook?.copyWith(
          position: Position(from.row, 3),
          hasMoved: true,
        );
        board[from.row][0] = null;
        moveNotation = 'O-O-O';
      }
    }

    // Move the piece
    board[to.row][to.col] = piece.copyWith(position: to, hasMoved: true);
    board[from.row][from.col] = null;

    // Handle pawn promotion
    if (piece.type == PieceType.pawn && (to.row == 0 || to.row == 7)) {
      final promotedPiece = await _showPawnPromotionDialog(piece.color, to);
      board[to.row][to.col] = promotedPiece ?? Queen(piece.color, to);
      if (promotedPiece != null) {
        moveNotation += '=${_getPieceNotation(promotedPiece)}';
      }
    }

    // Add move to history
    moveHistory.add(moveNotation);

    // Switch turns
    currentTurn =
        currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;

    // Check game state
    _checkGameOver();
    notifyListeners();
  }

  String _getMoveNotation(Piece piece, Position from, Position to) {
    String notation = '';

    // Add piece notation except for pawns
    if (piece.type != PieceType.pawn) {
      notation += _getPieceNotation(piece);
    }

    // Add capture symbol if there's a piece at the target square
    if (board[to.row][to.col] != null) {
      if (piece.type == PieceType.pawn) {
        notation += from.toChessNotation()[0];
      }
      notation += 'x';
    }

    // Add target square
    notation += to.toChessNotation();

    return notation;
  }

  String _getPieceNotation(Piece piece) {
    switch (piece.type) {
      case PieceType.king:
        return 'K';
      case PieceType.queen:
        return 'Q';
      case PieceType.rook:
        return 'R';
      case PieceType.bishop:
        return 'B';
      case PieceType.knight:
        return 'N';
      case PieceType.pawn:
        return '';
    }
  }

  Future<Piece?> _showPawnPromotionDialog(PieceColor color, Position position) {
    return showDialog<Piece>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Promote Pawn'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _promotionPieceButton(context, Queen(color, position)),
              _promotionPieceButton(context, Rook(color, position)),
              _promotionPieceButton(context, Bishop(color, position)),
              _promotionPieceButton(context, Knight(color, position)),
            ],
          ),
        );
      },
    );
  }

  Widget _promotionPieceButton(BuildContext context, Piece piece) {
    IconData icon;
    switch (piece.type) {
      case PieceType.queen:
        icon =
            piece.color == PieceColor.white
                ? Icons.diamond
                : Icons.diamond_outlined;
        break;
      case PieceType.rook:
        icon = piece.color == PieceColor.white ? Icons.castle : Icons.fort;
        break;
      case PieceType.bishop:
        icon =
            piece.color == PieceColor.white
                ? Icons.account_balance
                : Icons.account_balance_outlined;
        break;
      case PieceType.knight:
        icon =
            piece.color == PieceColor.white ? Icons.pets : Icons.pets_outlined;
        break;
      default:
        icon = Icons.error;
    }

    return IconButton(
      icon: Icon(icon, size: 32),
      color: piece.color == PieceColor.white ? Colors.white70 : Colors.black87,
      onPressed: () => Navigator.of(context).pop(piece),
    );
  }

  void _checkGameOver() {
    bool hasValidMoves = false;
    bool isInCheck = false;

    // Check if current player has any valid moves
    for (int i = 0; i < 8 && !hasValidMoves; i++) {
      for (int j = 0; j < 8 && !hasValidMoves; j++) {
        final piece = board[i][j];
        if (piece != null && piece.color == currentTurn) {
          var moves =
              piece
                  .getPossibleMoves(board)
                  .where((move) => !wouldBeInCheck(piece, move))
                  .toList();
          if (moves.isNotEmpty) {
            hasValidMoves = true;
          }
        }
      }
    }

    // Check if king is in check
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        final piece = board[i][j];
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == currentTurn) {
          King king = piece as King;
          isInCheck = king.isInCheck(board);
          break;
        }
      }
    }

    if (!hasValidMoves) {
      isGameOver = true;
      if (isInCheck) {
        winner =
            currentTurn == PieceColor.white
                ? PieceColor.black
                : PieceColor.white;
      } else {
        winner = null; // Stalemate
      }
      notifyListeners();
    }
  }

  void resetGame() {
    _initializeBoard();
    currentTurn = PieceColor.white;
    selectedPosition = null;
    possibleMoves = [];
    isGameOver = false;
    winner = null;
    moveHistory.clear();
    notifyListeners();
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
