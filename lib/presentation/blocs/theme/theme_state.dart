import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// State class for the ThemeBloc
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final String themeStyle;
  final bool useDynamicColors;

  const ThemeState({
    required this.themeMode,
    required this.themeStyle,
    required this.useDynamicColors,
  });

  /// Initial state with default values
  factory ThemeState.initial() => const ThemeState(
    themeMode: ThemeMode.light,
    themeStyle: 'classic',
    useDynamicColors: true,
  );

  /// Create a copy of this state with optional new values
  ThemeState copyWith({
    ThemeMode? themeMode,
    String? themeStyle,
    bool? useDynamicColors,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      themeStyle: themeStyle ?? this.themeStyle,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
    );
  }

  @override
  List<Object?> get props => [themeMode, themeStyle, useDynamicColors];
}
