import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// State class for the ThemeBloc
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final String themeStyle;
  final bool useDynamicColors;
  final bool useRedesignedPieces;

  const ThemeState({
    required this.themeMode,
    required this.themeStyle,
    required this.useDynamicColors,
    required this.useRedesignedPieces,
  });

  /// Initial state with default values
  factory ThemeState.initial() => const ThemeState(
        themeMode: ThemeMode.light,
        themeStyle: 'classic',
        useDynamicColors: true,
        useRedesignedPieces: false,
      );

  /// Create a copy of this state with optional new values
  ThemeState copyWith({
    ThemeMode? themeMode,
    String? themeStyle,
    bool? useDynamicColors,
    bool? useRedesignedPieces,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      themeStyle: themeStyle ?? this.themeStyle,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
      useRedesignedPieces: useRedesignedPieces ?? this.useRedesignedPieces,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        themeStyle,
        useDynamicColors,
        useRedesignedPieces,
      ];
}
