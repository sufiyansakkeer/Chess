import 'package:equatable/equatable.dart';

/// State class for the SettingsBloc
class SettingsState extends Equatable {
  // Game settings
  final int difficulty;
  final bool timeControlEnabled;
  final int timeControlMinutes;
  final bool autoPromoteToQueen;
  
  // Feedback settings
  final bool hapticFeedbackEnabled;
  final bool soundEffectsEnabled;
  final double soundVolume;
  
  // Game history settings
  final bool saveGameHistory;
  final int maxSavedGames;
  
  // Loading state
  final bool isLoading;

  const SettingsState({
    required this.difficulty,
    required this.timeControlEnabled,
    required this.timeControlMinutes,
    required this.autoPromoteToQueen,
    required this.hapticFeedbackEnabled,
    required this.soundEffectsEnabled,
    required this.soundVolume,
    required this.saveGameHistory,
    required this.maxSavedGames,
    required this.isLoading,
  });

  /// Initial state with default values
  factory SettingsState.initial() => const SettingsState(
        difficulty: 1,
        timeControlEnabled: false,
        timeControlMinutes: 10,
        autoPromoteToQueen: false,
        hapticFeedbackEnabled: true,
        soundEffectsEnabled: true,
        soundVolume: 0.7,
        saveGameHistory: true,
        maxSavedGames: 10,
        isLoading: true,
      );

  /// Create a copy of this state with optional new values
  SettingsState copyWith({
    int? difficulty,
    bool? timeControlEnabled,
    int? timeControlMinutes,
    bool? autoPromoteToQueen,
    bool? hapticFeedbackEnabled,
    bool? soundEffectsEnabled,
    double? soundVolume,
    bool? saveGameHistory,
    int? maxSavedGames,
    bool? isLoading,
  }) {
    return SettingsState(
      difficulty: difficulty ?? this.difficulty,
      timeControlEnabled: timeControlEnabled ?? this.timeControlEnabled,
      timeControlMinutes: timeControlMinutes ?? this.timeControlMinutes,
      autoPromoteToQueen: autoPromoteToQueen ?? this.autoPromoteToQueen,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      saveGameHistory: saveGameHistory ?? this.saveGameHistory,
      maxSavedGames: maxSavedGames ?? this.maxSavedGames,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        difficulty,
        timeControlEnabled,
        timeControlMinutes,
        autoPromoteToQueen,
        hapticFeedbackEnabled,
        soundEffectsEnabled,
        soundVolume,
        saveGameHistory,
        maxSavedGames,
        isLoading,
      ];
}
