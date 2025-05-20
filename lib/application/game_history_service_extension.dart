import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/game_history.dart';
import '../domain/value_objects/piece_color.dart';
import '../domain/value_objects/piece_type.dart';
import '../presentation/blocs/game/game_state.dart' as bloc;
import '../presentation/blocs/settings/settings_state.dart';
import 'game_history_service.dart';

/// Extension methods for GameHistoryService to work with BLoC states
extension GameHistoryServiceExtension on GameHistoryService {
  /// Save a game using BLoC states
  Future<void> saveGameFromBloc(
    bloc.GameState gameState,
    DateTime startTime,
    SettingsState settingsState,
  ) async {
    if (!settingsState.saveGameHistory) return;

    // Calculate duration
    final endTime = DateTime.now();
    final durationInSeconds = endTime.difference(startTime).inSeconds;

    // Create a new game history object
    final gameHistory = GameHistory(
      id: const Uuid().v4(),
      date: endTime,
      moves: gameState.moveHistory,
      winner: gameState.winner,
      isDraw: gameState.isGameOver && gameState.winner == null,
      whiteScore: _calculateScoreFromBloc(gameState, PieceColor.white),
      blackScore: _calculateScoreFromBloc(gameState, PieceColor.black),
      gameMode: 'Standard',
      difficulty: settingsState.difficulty,
      durationInSeconds: durationInSeconds,
    );

    // Use the public method to save the game history
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('game_history') ?? [];

    // Add the new game to the history
    historyJson.add(jsonEncode(gameHistory.toJson()));

    // Limit the number of saved games
    if (historyJson.length > settingsState.maxSavedGames) {
      // Sort by date, newest first
      final games =
          historyJson
              .map((json) => GameHistory.fromJson(jsonDecode(json)))
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

      // Keep only the newest games
      final newGames = games.take(settingsState.maxSavedGames).toList();

      // Convert back to JSON
      historyJson.clear();
      for (final game in newGames) {
        historyJson.add(jsonEncode(game.toJson()));
      }
    }

    // Save the updated history
    await prefs.setStringList('game_history', historyJson);
  }

  /// Calculate the score for a player from BLoC state
  int _calculateScoreFromBloc(bloc.GameState gameState, PieceColor color) {
    final capturedPieces =
        color == PieceColor.white
            ? gameState.whiteCapturedPieces
            : gameState.blackCapturedPieces;

    int score = 0;
    for (final piece in capturedPieces) {
      switch (piece.type) {
        case PieceType.pawn:
          score += 1;
          break;
        case PieceType.knight:
        case PieceType.bishop:
          score += 3;
          break;
        case PieceType.rook:
          score += 5;
          break;
        case PieceType.queen:
          score += 9;
          break;
        case PieceType.king:
          // King shouldn't be captured, but just in case
          score += 0;
          break;
      }
    }

    // Add bonus for winning
    if (gameState.isGameOver && gameState.winner == color) {
      score += 10;
    }

    return score;
  }
}
