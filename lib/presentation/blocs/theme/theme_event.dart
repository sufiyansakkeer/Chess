import 'package:equatable/equatable.dart';

/// Base class for all theme-related events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to toggle between light and dark theme
class ThemeToggled extends ThemeEvent {
  const ThemeToggled();
}

/// Event to set a specific theme style
class ThemeStyleChanged extends ThemeEvent {
  final String style;

  const ThemeStyleChanged(this.style);

  @override
  List<Object?> get props => [style];
}

/// Event to toggle dynamic colors
class DynamicColorsToggled extends ThemeEvent {
  const DynamicColorsToggled();
}

/// Event to toggle redesigned pieces
class RedesignedPiecesToggled extends ThemeEvent {
  const RedesignedPiecesToggled();
}

/// Event to load theme settings from storage
class ThemeLoaded extends ThemeEvent {
  const ThemeLoaded();
}
