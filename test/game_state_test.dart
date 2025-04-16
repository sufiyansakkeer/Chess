import 'package:flutter_test/flutter_test.dart';
import 'package:chess/domain/value_objects/piece_color.dart';
import 'package:chess/domain/value_objects/position.dart';
import 'package:chess/application/game_state_impl.dart';
import 'package:chess/domain/value_objects/piece_type.dart'; // Import PieceType
import 'package:chess/domain/entities/pieces/pawn.dart'; // Import Pawn
import 'package:chess/domain/entities/pieces/queen.dart'; // Import Queen
import 'package:chess/domain/entities/pieces/king.dart'; // Import King
import 'package:chess/domain/entities/pieces/rook.dart'; // Import Rook

void main() {
  late GameStateImpl gameState;

  setUp(() {
    gameState = GameStateImpl();
  });

  group('GameState Initial Setup', () {
    test('should initialize with white turn', () {
      expect(gameState.currentTurn, equals(PieceColor.white));
    });

    test('should initialize with correct board size', () {
      expect(gameState.board.length, equals(8));
      expect(gameState.board[0].length, equals(8));
    });

    test('should initialize with correct piece positions', () {
      // Check white pawns
      for (int col = 0; col < 8; col++) {
        final piece = gameState.board[6][col];
        expect(piece?.color, equals(PieceColor.white));
      }

      // Check black pawns
      for (int col = 0; col < 8; col++) {
        final piece = gameState.board[1][col];
        expect(piece?.color, equals(PieceColor.black));
      }
    });
  });

  group('Move Validation', () {
    test('should allow valid pawn move', () {
      final from = Position(6, 0); // White pawn initial position
      final to = Position(5, 0); // One step forward

      expect(gameState.movePiece(from, to), isTrue);
      expect(gameState.board[5][0], isNotNull);
      expect(gameState.board[6][0], isNull);
    });

    test('should not allow invalid pawn move', () {
      final from = Position(6, 0);
      final to = Position(4, 1); // Invalid diagonal without capture

      expect(gameState.movePiece(from, to), isFalse);
      expect(gameState.board[6][0], isNotNull);
    });

    test('should not allow move when wrong turn', () {
      final from = Position(1, 0); // Black pawn
      final to = Position(2, 0);

      // It's white's turn initially
      expect(gameState.movePiece(from, to), isFalse);
    });
  });

  group('Game State Changes', () {
    test('should switch turns after valid move', () {
      final from = Position(6, 0);
      final to = Position(5, 0);

      gameState.movePiece(from, to);
      expect(gameState.currentTurn, equals(PieceColor.black));
    });

    test('should track piece movement history', () {
      final from = Position(6, 0);
      final to = Position(5, 0);

      gameState.movePiece(from, to);
      final piece = gameState.board[5][0];
      expect(piece?.hasMoved, isTrue);
    });
  });

  group('Special Moves', () {
    test('kingside castling should work when conditions are met', () {
      final gameState = GameStateImpl();
      // Clear pieces between king and rook
      gameState.board[7][5] = null;
      gameState.board[7][6] = null;

      final from = Position(7, 4); // White king
      final to = Position(7, 6); // Castling destination

      expect(gameState.movePiece(from, to), isTrue);
      // Verify king moved
      expect(gameState.board[7][6]?.type, equals(PieceType.king));
      // Verify rook moved
      expect(gameState.board[7][5]?.type, equals(PieceType.rook));
      expect(gameState.board[7][7], isNull);
    });

    test('queenside castling should work when conditions are met', () {
      final gameState = GameStateImpl();
      // Clear pieces between king and rook
      gameState.board[7][1] = null;
      gameState.board[7][2] = null;
      gameState.board[7][3] = null;

      final from = Position(7, 4); // White king
      final to = Position(7, 2); // Castling destination

      expect(gameState.movePiece(from, to), isTrue);
      // Verify king moved
      expect(gameState.board[7][2]?.type, equals(PieceType.king));
      // Verify rook moved
      expect(gameState.board[7][3]?.type, equals(PieceType.rook));
      expect(gameState.board[7][0], isNull);
    });

    test('castling should not be allowed through check', () {
      final gameState = GameStateImpl();
      // Clear pieces between king and rook
      gameState.board[7][5] = null;
      gameState.board[7][6] = null;
      // Place enemy queen to attack castling square
      gameState.board[6][5] = Queen(
        color: PieceColor.black,
        position: Position(6, 5),
      );

      final from = Position(7, 4); // White king
      final to = Position(7, 6); // Castling destination

      expect(gameState.movePiece(from, to), isFalse);
      // Verify pieces didn't move
      expect(gameState.board[7][4]?.type, equals(PieceType.king));
      expect(gameState.board[7][7]?.type, equals(PieceType.rook));
    });

    test('pawn promotion should work when reaching the opposite end', () {
      final gameState = GameStateImpl();
      // Place a white pawn one step away from promotion
      gameState.board[1][0] = Pawn(
        color: PieceColor.white,
        position: Position(1, 0),
        hasMoved: true,
      );

      final from = Position(1, 0);
      final to = Position(0, 0);

      // Use the updated movePiece method with promotionType
      expect(gameState.movePiece(from, to, PieceType.queen), isTrue);
      expect(gameState.board[0][0]?.type, equals(PieceType.queen));
      expect(gameState.board[0][0]?.color, equals(PieceColor.white));
    });

    test(
      'en passant capture should work immediately after double pawn move',
      () {
        final gameState = GameStateImpl();
        // Set up position: white pawn at e5, black pawn at f7
        gameState.board[3][4] = Pawn(
          color: PieceColor.white,
          position: Position(3, 4),
          hasMoved: true,
        );
        gameState.board[1][5] = Pawn(
          color: PieceColor.black,
          position: Position(1, 5),
        );

        // Move black pawn two squares forward
        expect(gameState.movePiece(Position(1, 5), Position(3, 5)), isTrue);
        // White captures en passant
        expect(gameState.movePiece(Position(3, 4), Position(2, 5)), isTrue);

        // Verify capture
        expect(gameState.board[2][5]?.type, equals(PieceType.pawn));
        expect(gameState.board[2][5]?.color, equals(PieceColor.white));
        expect(
          gameState.board[3][5],
          isNull,
        ); // Captured pawn should be removed
      },
    );

    test(
      'en passant should only be possible immediately after double pawn move',
      () {
        final gameState = GameStateImpl();
        // Set up position: white pawn at e5, black pawn at f7
        gameState.board[3][4] = Pawn(
          color: PieceColor.white,
          position: Position(3, 4),
          hasMoved: true,
        );
        gameState.board[1][5] = Pawn(
          color: PieceColor.black,
          position: Position(1, 5),
        );

        // Move black pawn two squares forward
        expect(gameState.movePiece(Position(1, 5), Position(3, 5)), isTrue);
        // Make a different move
        expect(gameState.movePiece(Position(6, 0), Position(5, 0)), isTrue);
        // Try en passant capture - should fail
        expect(gameState.movePiece(Position(3, 4), Position(2, 5)), isFalse);
      },
    );
  });

  test('castling should not be allowed if king has moved', () {
    gameState.board[7][5] = null;
    gameState.board[7][6] = null;
    // Move king forward and back
    expect(
      gameState.movePiece(Position(7, 4), Position(6, 4)),
      isTrue,
    ); // W Ke2
    expect(
      gameState.movePiece(Position(0, 0), Position(0, 0)),
      isTrue,
    ); // B dummy move
    expect(
      gameState.movePiece(Position(6, 4), Position(7, 4)),
      isTrue,
    ); // W Ke1

    // Try to castle kingside (should fail)
    expect(gameState.movePiece(Position(7, 4), Position(7, 6)), isFalse);
  });

  test('castling should not be allowed if rook has moved', () {
    gameState.board[7][5] = null;
    gameState.board[7][6] = null;
    // Move rook forward and back
    expect(
      gameState.movePiece(Position(7, 7), Position(6, 7)),
      isTrue,
    ); // W Rh2
    expect(
      gameState.movePiece(Position(0, 0), Position(0, 0)),
      isTrue,
    ); // B dummy move
    expect(
      gameState.movePiece(Position(6, 7), Position(7, 7)),
      isTrue,
    ); // W Rh1

    // Try to castle kingside (should fail)
    expect(gameState.movePiece(Position(7, 4), Position(7, 6)), isFalse);
  });

  test('castling should not be allowed if king is in check', () {
    gameState.board[7][5] = null;
    gameState.board[7][6] = null;
    // Place enemy queen to put king in check
    gameState.board[6][4] = Queen(
      color: PieceColor.black,
      position: Position(6, 4),
    );

    // Try to castle kingside (should fail)
    expect(gameState.movePiece(Position(7, 4), Position(7, 6)), isFalse);
  });

  test('black kingside castling should work', () {
    // Need white to move first
    expect(gameState.movePiece(Position(6, 0), Position(5, 0)), isTrue);
    // Clear black pieces
    gameState.board[0][5] = null;
    gameState.board[0][6] = null;

    final from = Position(0, 4); // Black king
    final to = Position(0, 6); // Castling destination

    expect(gameState.movePiece(from, to), isTrue);
    expect(gameState.board[0][6]?.type, equals(PieceType.king));
    expect(gameState.board[0][5]?.type, equals(PieceType.rook));
    expect(gameState.board[0][7], isNull);
  });

  test('black queenside castling should work', () {
    // Need white to move first
    expect(gameState.movePiece(Position(6, 0), Position(5, 0)), isTrue);
    // Clear black pieces
    gameState.board[0][1] = null;
    gameState.board[0][2] = null;
    gameState.board[0][3] = null;

    final from = Position(0, 4); // Black king
    final to = Position(0, 2); // Castling destination

    expect(gameState.movePiece(from, to), isTrue);
    expect(gameState.board[0][2]?.type, equals(PieceType.king));
    expect(gameState.board[0][3]?.type, equals(PieceType.rook));
    expect(gameState.board[0][0], isNull);
  });

  test('black pawn promotion to knight', () {
    // Need white to move first
    expect(gameState.movePiece(Position(6, 0), Position(5, 0)), isTrue);
    // Place black pawn near promotion
    gameState.board[6][7] = Pawn(
      color: PieceColor.black,
      position: Position(6, 7),
      hasMoved: true,
    );
    gameState.board[7][7] = null; // Clear white rook

    final from = Position(6, 7);
    final to = Position(7, 7);

    expect(gameState.movePiece(from, to, PieceType.knight), isTrue);
    expect(gameState.board[7][7]?.type, equals(PieceType.knight));
    expect(gameState.board[7][7]?.color, equals(PieceColor.black));
  });

  test('pawn promotion by capture', () {
    gameState.board[1][0] = Pawn(
      color: PieceColor.white,
      position: Position(1, 0),
      hasMoved: true,
    );
    gameState.board[0][1] = Rook(
      color: PieceColor.black,
      position: Position(0, 1),
    ); // Enemy piece

    final from = Position(1, 0);
    final to = Position(0, 1); // Capture and promote

    expect(gameState.movePiece(from, to, PieceType.queen), isTrue);
    expect(gameState.board[0][1]?.type, equals(PieceType.queen));
    expect(gameState.board[0][1]?.color, equals(PieceColor.white));
  });

  test('black en passant capture', () {
    // Setup: Black pawn at d4, White pawn at e2
    gameState.board[4][3] = Pawn(
      color: PieceColor.black,
      position: Position(4, 3),
      hasMoved: true,
    );
    gameState.board[6][4] = Pawn(
      color: PieceColor.white,
      position: Position(6, 4),
    );

    // White pawn moves two squares
    expect(gameState.movePiece(Position(6, 4), Position(4, 4)), isTrue);
    // Black captures en passant
    expect(gameState.movePiece(Position(4, 3), Position(5, 4)), isTrue);

    // Verify capture
    expect(gameState.board[5][4]?.type, equals(PieceType.pawn));
    expect(gameState.board[5][4]?.color, equals(PieceColor.black));
    expect(gameState.board[4][4], isNull); // Captured white pawn removed
  });

  group('Additional Edge Cases', () {
    test('castling should not be allowed if path is under attack', () {
      final gameState = GameStateImpl();
      // Clear pieces between king and rook
      gameState.board[7][5] = null;
      gameState.board[7][6] = null;
      // Place enemy queen to attack castling path
      gameState.board[6][5] = Queen(
        color: PieceColor.black,
        position: Position(6, 5),
      );

      final from = Position(7, 4); // White king
      final to = Position(7, 6); // Castling destination

      expect(gameState.movePiece(from, to), isFalse);
      // Verify pieces didn't move
      expect(gameState.board[7][4]?.type, equals(PieceType.king));
      expect(gameState.board[7][7]?.type, equals(PieceType.rook));
    });

    test('pawn promotion should default to queen if no type is provided', () {
      final gameState = GameStateImpl();
      // Place a white pawn one step away from promotion
      gameState.board[1][0] = Pawn(
        color: PieceColor.white,
        position: Position(1, 0),
        hasMoved: true,
      );

      final from = Position(1, 0);
      final to = Position(0, 0);

      // Move without specifying promotion type
      expect(gameState.movePiece(from, to), isTrue);
      expect(gameState.board[0][0]?.type, equals(PieceType.queen));
      expect(gameState.board[0][0]?.color, equals(PieceColor.white));
    });

    test('en passant should not be allowed after an intermediate move', () {
      final gameState = GameStateImpl();
      // Set up position: white pawn at e5, black pawn at f7
      gameState.board[3][4] = Pawn(
        color: PieceColor.white,
        position: Position(3, 4),
        hasMoved: true,
      );
      gameState.board[1][5] = Pawn(
        color: PieceColor.black,
        position: Position(1, 5),
      );

      // Move black pawn two squares forward
      expect(gameState.movePiece(Position(1, 5), Position(3, 5)), isTrue);
      // Make an intermediate move
      expect(gameState.movePiece(Position(6, 0), Position(5, 0)), isTrue);
      // Try en passant capture - should fail
      expect(gameState.movePiece(Position(3, 4), Position(2, 5)), isFalse);
    });
  });
}
