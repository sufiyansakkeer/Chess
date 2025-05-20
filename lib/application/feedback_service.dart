import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

enum SoundType {
  move,
  capture,
  check,
  checkmate,
  draw,
  promotion,
  castling,
  error,
  select,
}

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();

  factory FeedbackService() => _instance;

  FeedbackService._internal();

  bool _hapticFeedbackEnabled = true;
  bool _soundEnabled = true;
  double _soundVolume = 1.0;

  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  bool get soundEnabled => _soundEnabled;
  double get soundVolume => _soundVolume;

  set hapticFeedbackEnabled(bool value) {
    _hapticFeedbackEnabled = value;
  }

  set soundEnabled(bool value) {
    _soundEnabled = value;
  }

  set soundVolume(double value) {
    _soundVolume = value.clamp(0.0, 1.0);
  }

  // Haptic feedback methods
  Future<void> lightImpact() async {
    if (!_hapticFeedbackEnabled) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error triggering haptic feedback: $e');
    }
  }

  Future<void> mediumImpact() async {
    if (!_hapticFeedbackEnabled) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error triggering haptic feedback: $e');
    }
  }

  Future<void> heavyImpact() async {
    if (!_hapticFeedbackEnabled) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error triggering haptic feedback: $e');
    }
  }

  Future<void> selectionClick() async {
    if (!_hapticFeedbackEnabled) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error triggering haptic feedback: $e');
    }
  }

  // Sound feedback methods
  Future<void> Function(SoundType)? _playSoundCallback;

  set playSoundCallback(Future<void> Function(SoundType) callback) {
    _playSoundCallback = callback;
  }

  Future<void> playSound(SoundType type) async {
    if (!_soundEnabled) return;

    if (_playSoundCallback != null) {
      await _playSoundCallback!(type);
    }
  }

  // Combined feedback methods for chess actions
  Future<void> onPieceSelected() async {
    await selectionClick();
    await playSound(SoundType.select);
  }

  Future<void> onPieceMoved() async {
    await lightImpact();
    await playSound(SoundType.move);
  }

  Future<void> onPieceCaptured() async {
    await heavyImpact();
    await playSound(SoundType.capture);
  }

  Future<void> onCheck() async {
    await mediumImpact();
    await playSound(SoundType.check);
  }

  Future<void> onCheckmate() async {
    await heavyImpact();
    await playSound(SoundType.checkmate);
  }

  Future<void> onDraw() async {
    await mediumImpact();
    await playSound(SoundType.draw);
  }

  Future<void> onPromotion() async {
    await mediumImpact();
    await playSound(SoundType.promotion);
  }

  Future<void> onCastling() async {
    await mediumImpact();
    await playSound(SoundType.castling);
  }

  Future<void> onError() async {
    await lightImpact();
    await playSound(SoundType.error);
  }
}
