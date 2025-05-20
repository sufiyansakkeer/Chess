import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/game_history.dart';
import '../domain/entities/game_state.dart';
import '../domain/value_objects/piece_color.dart';
import '../domain/value_objects/piece_type.dart';
import '../presentation/blocs/settings/settings_state.dart';

class GameHistoryService {
  static final GameHistoryService _instance = GameHistoryService._internal();

  factory GameHistoryService() => _instance;

  GameHistoryService._internal();

  final String _historyKey = 'game_history';
  final Uuid _uuid = const Uuid();

  // Get all saved games
  Future<List<GameHistory>> getAllGames() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];

    return historyJson
        .map((json) => GameHistory.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
  }

  // Save a game
  Future<void> saveGame(
    GameState gameState,
    DateTime startTime,
    SettingsState settingsState,
  ) async {
    if (!settingsState.saveGameHistory) return;

    // Calculate duration
    final endTime = DateTime.now();
    final durationInSeconds = endTime.difference(startTime).inSeconds;

    // Create a new game history object
    final gameHistory = GameHistory(
      id: _uuid.v4(),
      date: endTime,
      moves: gameState.getMoveHistory(),
      winner: gameState.winner,
      isDraw: gameState.isGameOver && gameState.winner == null,
      whiteScore: _calculateScore(gameState, PieceColor.white),
      blackScore: _calculateScore(gameState, PieceColor.black),
      gameMode: 'Standard',
      difficulty: settingsState.difficulty,
      durationInSeconds: durationInSeconds,
    );

    // Use the internal method to save the game history
    await _saveGameHistory(gameHistory, settingsState.maxSavedGames);
  }

  // Internal method to save a game history object
  Future<void> _saveGameHistory(
    GameHistory gameHistory,
    int maxSavedGames,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];

    // Add the new game to the history
    historyJson.add(jsonEncode(gameHistory.toJson()));

    // Limit the number of saved games
    if (historyJson.length > maxSavedGames) {
      // Sort by date, newest first
      final games =
          historyJson
              .map((json) => GameHistory.fromJson(jsonDecode(json)))
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

      // Keep only the newest games
      final newGames = games.take(maxSavedGames).toList();

      // Convert back to JSON
      historyJson.clear();
      for (final game in newGames) {
        historyJson.add(jsonEncode(game.toJson()));
      }
    }

    // Save the updated history
    await prefs.setStringList(_historyKey, historyJson);
  }

  // Delete a game
  Future<void> deleteGame(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];

    // Filter out the game with the given ID
    final games =
        historyJson
            .map((json) => GameHistory.fromJson(jsonDecode(json)))
            .where((game) => game.id != id)
            .toList();

    // Convert back to JSON
    historyJson.clear();
    for (final game in games) {
      historyJson.add(jsonEncode(game.toJson()));
    }

    // Save the updated history
    await prefs.setStringList(_historyKey, historyJson);
  }

  // Delete all games
  Future<void> deleteAllGames() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // Calculate the score for a player
  int _calculateScore(GameState gameState, PieceColor color) {
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
