import '../../domain/value_objects/piece_color.dart';

class GameHistory {
  final String id;
  final DateTime date;
  final List<String> moves;
  final PieceColor? winner;
  final bool isDraw;
  final int whiteScore;
  final int blackScore;
  final String gameMode;
  final int difficulty;
  final int durationInSeconds;
  
  GameHistory({
    required this.id,
    required this.date,
    required this.moves,
    this.winner,
    this.isDraw = false,
    this.whiteScore = 0,
    this.blackScore = 0,
    this.gameMode = 'Standard',
    this.difficulty = 1,
    this.durationInSeconds = 0,
  });
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moves': moves,
      'winner': winner?.toString(),
      'isDraw': isDraw,
      'whiteScore': whiteScore,
      'blackScore': blackScore,
      'gameMode': gameMode,
      'difficulty': difficulty,
      'durationInSeconds': durationInSeconds,
    };
  }
  
  // Create from JSON
  factory GameHistory.fromJson(Map<String, dynamic> json) {
    return GameHistory(
      id: json['id'],
      date: DateTime.parse(json['date']),
      moves: List<String>.from(json['moves']),
      winner: json['winner'] != null 
          ? json['winner'] == 'PieceColor.white' 
              ? PieceColor.white 
              : PieceColor.black
          : null,
      isDraw: json['isDraw'] ?? false,
      whiteScore: json['whiteScore'] ?? 0,
      blackScore: json['blackScore'] ?? 0,
      gameMode: json['gameMode'] ?? 'Standard',
      difficulty: json['difficulty'] ?? 1,
      durationInSeconds: json['durationInSeconds'] ?? 0,
    );
  }
  
  // Get a formatted date string
  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  // Get a formatted duration string
  String get formattedDuration {
    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Get the result as a string
  String get result {
    if (isDraw) {
      return 'Draw';
    } else if (winner == PieceColor.white) {
      return 'White wins';
    } else if (winner == PieceColor.black) {
      return 'Black wins';
    } else {
      return 'Unfinished';
    }
  }
  
  // Get the number of moves
  int get moveCount => moves.length;
  
  // Get a copy with updated values
  GameHistory copyWith({
    String? id,
    DateTime? date,
    List<String>? moves,
    PieceColor? winner,
    bool? isDraw,
    int? whiteScore,
    int? blackScore,
    String? gameMode,
    int? difficulty,
    int? durationInSeconds,
  }) {
    return GameHistory(
      id: id ?? this.id,
      date: date ?? this.date,
      moves: moves ?? this.moves,
      winner: winner ?? this.winner,
      isDraw: isDraw ?? this.isDraw,
      whiteScore: whiteScore ?? this.whiteScore,
      blackScore: blackScore ?? this.blackScore,
      gameMode: gameMode ?? this.gameMode,
      difficulty: difficulty ?? this.difficulty,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
    );
  }
}
