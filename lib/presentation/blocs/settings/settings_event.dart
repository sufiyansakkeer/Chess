import 'package:equatable/equatable.dart';

/// Base class for all settings-related events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to set the difficulty level
class DifficultyChanged extends SettingsEvent {
  final int difficulty;

  const DifficultyChanged(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}

/// Event to toggle time control
class TimeControlToggled extends SettingsEvent {
  const TimeControlToggled();
}

/// Event to set time control minutes
class TimeControlMinutesChanged extends SettingsEvent {
  final int minutes;

  const TimeControlMinutesChanged(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

/// Event to toggle auto-promote to queen
class AutoPromoteToQueenToggled extends SettingsEvent {
  const AutoPromoteToQueenToggled();
}

/// Event to toggle haptic feedback
class HapticFeedbackToggled extends SettingsEvent {
  const HapticFeedbackToggled();
}

/// Event to toggle sound effects
class SoundEffectsToggled extends SettingsEvent {
  const SoundEffectsToggled();
}

/// Event to set sound volume
class SoundVolumeChanged extends SettingsEvent {
  final double volume;

  const SoundVolumeChanged(this.volume);

  @override
  List<Object?> get props => [volume];
}

/// Event to toggle saving game history
class SaveGameHistoryToggled extends SettingsEvent {
  const SaveGameHistoryToggled();
}

/// Event to set maximum number of saved games
class MaxSavedGamesChanged extends SettingsEvent {
  final int maxGames;

  const MaxSavedGamesChanged(this.maxGames);

  @override
  List<Object?> get props => [maxGames];
}

/// Event to reset all settings to defaults
class SettingsReset extends SettingsEvent {
  const SettingsReset();
}

/// Event to load settings from storage
class SettingsLoaded extends SettingsEvent {
  const SettingsLoaded();
}
