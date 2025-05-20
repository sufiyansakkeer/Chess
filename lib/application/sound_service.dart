import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'feedback_service.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();

  factory SoundService() => _instance;

  SoundService._internal() {
    _initAudioPlayers();
  }

  final Map<SoundType, AudioPlayer> _players = {};

  Future<void> _initAudioPlayers() async {
    try {
      // Create audio players for each sound type
      for (final type in SoundType.values) {
        final player = AudioPlayer();
        _players[type] = player;

        // Load the audio file
        await player.setAsset(_getSoundAsset(type));

        // Set volume
        player.setVolume(FeedbackService().soundVolume);
      }
    } catch (e) {
      debugPrint('Error initializing audio players: $e');
    }
  }

  String _getSoundAsset(SoundType type) {
    switch (type) {
      case SoundType.move:
        return 'assets/sounds/move.mp3';
      case SoundType.capture:
        return 'assets/sounds/capture.mp3';
      case SoundType.check:
        return 'assets/sounds/check.mp3';
      case SoundType.checkmate:
        return 'assets/sounds/checkmate.mp3';
      case SoundType.draw:
        return 'assets/sounds/draw.mp3';
      case SoundType.promotion:
        return 'assets/sounds/promotion.mp3';
      case SoundType.castling:
        return 'assets/sounds/castling.mp3';
      case SoundType.error:
        return 'assets/sounds/error.mp3';
      case SoundType.select:
        return 'assets/sounds/select.mp3';
    }
  }

  Future<void> play(SoundType type) async {
    if (!FeedbackService().soundEnabled) return;

    try {
      final player = _players[type];
      if (player != null) {
        // Update volume in case it changed
        player.setVolume(FeedbackService().soundVolume);

        // Seek to beginning and play
        await player.seek(Duration.zero);
        await player.play();
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> dispose() async {
    try {
      for (final player in _players.values) {
        await player.dispose();
      }
      _players.clear();
    } catch (e) {
      debugPrint('Error disposing audio players: $e');
    }
  }

  // Update the FeedbackService to use this SoundService
  static void initializeFeedbackService() {
    final feedbackService = FeedbackService();
    feedbackService.playSoundCallback = (type) async {
      await SoundService().play(type);
    };
  }
}
