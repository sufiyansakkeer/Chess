import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../application/feedback_service.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC for managing settings-related state
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final FeedbackService _feedbackService;

  SettingsBloc({FeedbackService? feedbackService}) 
      : _feedbackService = feedbackService ?? FeedbackService(),
        super(SettingsState.initial()) {
    on<SettingsLoaded>(_onSettingsLoaded);
    on<DifficultyChanged>(_onDifficultyChanged);
    on<TimeControlToggled>(_onTimeControlToggled);
    on<TimeControlMinutesChanged>(_onTimeControlMinutesChanged);
    on<AutoPromoteToQueenToggled>(_onAutoPromoteToQueenToggled);
    on<HapticFeedbackToggled>(_onHapticFeedbackToggled);
    on<SoundEffectsToggled>(_onSoundEffectsToggled);
    on<SoundVolumeChanged>(_onSoundVolumeChanged);
    on<SaveGameHistoryToggled>(_onSaveGameHistoryToggled);
    on<MaxSavedGamesChanged>(_onMaxSavedGamesChanged);
    on<SettingsReset>(_onSettingsReset);
    
    // Load settings when the bloc is created
    add(const SettingsLoaded());
  }

  /// Load settings from shared preferences
  Future<void> _onSettingsLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    final prefs = await SharedPreferences.getInstance();
    
    // Game settings
    final difficulty = prefs.getInt('difficulty') ?? 1;
    final timeControlEnabled = prefs.getBool('timeControlEnabled') ?? false;
    final timeControlMinutes = prefs.getInt('timeControlMinutes') ?? 10;
    final autoPromoteToQueen = prefs.getBool('autoPromoteToQueen') ?? false;
    
    // Feedback settings
    final hapticFeedbackEnabled = prefs.getBool('hapticFeedbackEnabled') ?? true;
    final soundEffectsEnabled = prefs.getBool('soundEffectsEnabled') ?? true;
    final soundVolume = prefs.getDouble('soundVolume') ?? 0.7;
    
    // Game history settings
    final saveGameHistory = prefs.getBool('saveGameHistory') ?? true;
    final maxSavedGames = prefs.getInt('maxSavedGames') ?? 10;
    
    // Update the feedback service
    _feedbackService.hapticFeedbackEnabled = hapticFeedbackEnabled;
    _feedbackService.soundEnabled = soundEffectsEnabled;
    _feedbackService.soundVolume = soundVolume;
    
    emit(state.copyWith(
      difficulty: difficulty,
      timeControlEnabled: timeControlEnabled,
      timeControlMinutes: timeControlMinutes,
      autoPromoteToQueen: autoPromoteToQueen,
      hapticFeedbackEnabled: hapticFeedbackEnabled,
      soundEffectsEnabled: soundEffectsEnabled,
      soundVolume: soundVolume,
      saveGameHistory: saveGameHistory,
      maxSavedGames: maxSavedGames,
      isLoading: false,
    ));
  }

  /// Save settings to shared preferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Game settings
    await prefs.setInt('difficulty', state.difficulty);
    await prefs.setBool('timeControlEnabled', state.timeControlEnabled);
    await prefs.setInt('timeControlMinutes', state.timeControlMinutes);
    await prefs.setBool('autoPromoteToQueen', state.autoPromoteToQueen);
    
    // Feedback settings
    await prefs.setBool('hapticFeedbackEnabled', state.hapticFeedbackEnabled);
    await prefs.setBool('soundEffectsEnabled', state.soundEffectsEnabled);
    await prefs.setDouble('soundVolume', state.soundVolume);
    
    // Game history settings
    await prefs.setBool('saveGameHistory', state.saveGameHistory);
    await prefs.setInt('maxSavedGames', state.maxSavedGames);
  }

  /// Handle difficulty change event
  void _onDifficultyChanged(
    DifficultyChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(difficulty: event.difficulty));
    _saveSettings();
  }

  /// Handle time control toggle event
  void _onTimeControlToggled(
    TimeControlToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(timeControlEnabled: !state.timeControlEnabled));
    _saveSettings();
  }

  /// Handle time control minutes change event
  void _onTimeControlMinutesChanged(
    TimeControlMinutesChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(timeControlMinutes: event.minutes));
    _saveSettings();
  }

  /// Handle auto-promote to queen toggle event
  void _onAutoPromoteToQueenToggled(
    AutoPromoteToQueenToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(autoPromoteToQueen: !state.autoPromoteToQueen));
    _saveSettings();
  }

  /// Handle haptic feedback toggle event
  void _onHapticFeedbackToggled(
    HapticFeedbackToggled event,
    Emitter<SettingsState> emit,
  ) {
    final newValue = !state.hapticFeedbackEnabled;
    emit(state.copyWith(hapticFeedbackEnabled: newValue));
    _feedbackService.hapticFeedbackEnabled = newValue;
    _saveSettings();
  }

  /// Handle sound effects toggle event
  void _onSoundEffectsToggled(
    SoundEffectsToggled event,
    Emitter<SettingsState> emit,
  ) {
    final newValue = !state.soundEffectsEnabled;
    emit(state.copyWith(soundEffectsEnabled: newValue));
    _feedbackService.soundEnabled = newValue;
    _saveSettings();
  }

  /// Handle sound volume change event
  void _onSoundVolumeChanged(
    SoundVolumeChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(soundVolume: event.volume));
    _feedbackService.soundVolume = event.volume;
    _saveSettings();
  }

  /// Handle save game history toggle event
  void _onSaveGameHistoryToggled(
    SaveGameHistoryToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(saveGameHistory: !state.saveGameHistory));
    _saveSettings();
  }

  /// Handle max saved games change event
  void _onMaxSavedGamesChanged(
    MaxSavedGamesChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(maxSavedGames: event.maxGames));
    _saveSettings();
  }

  /// Handle settings reset event
  void _onSettingsReset(
    SettingsReset event,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsState.initial().copyWith(isLoading: false));
    
    // Update the feedback service
    _feedbackService.hapticFeedbackEnabled = state.hapticFeedbackEnabled;
    _feedbackService.soundEnabled = state.soundEffectsEnabled;
    _feedbackService.soundVolume = state.soundVolume;
    
    _saveSettings();
  }
}
