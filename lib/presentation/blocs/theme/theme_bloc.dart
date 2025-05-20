import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// BLoC for managing theme-related state
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.initial()) {
    on<ThemeToggled>(_onThemeToggled);
    on<ThemeStyleChanged>(_onThemeStyleChanged);
    on<DynamicColorsToggled>(_onDynamicColorsToggled);
    on<RedesignedPiecesToggled>(_onRedesignedPiecesToggled);
    on<ThemeLoaded>(_onThemeLoaded);

    // Load theme settings when the bloc is created
    add(const ThemeLoaded());
  }

  /// Load theme settings from shared preferences
  Future<void> _onThemeLoaded(
    ThemeLoaded event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Theme settings
    final themeMode = prefs.getString('themeMode') ?? 'light';
    final themeStyle = prefs.getString('themeStyle') ?? 'classic';
    final useDynamicColors = prefs.getBool('useDynamicColors') ?? true;
    final useRedesignedPieces = prefs.getBool('useRedesignedPieces') ?? false;

    emit(
      state.copyWith(
        themeMode: themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light,
        themeStyle: themeStyle,
        useDynamicColors: useDynamicColors,
        useRedesignedPieces: useRedesignedPieces,
      ),
    );
  }

  /// Save theme settings to shared preferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Theme settings
    await prefs.setString(
      'themeMode',
      state.themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
    await prefs.setString('themeStyle', state.themeStyle);
    await prefs.setBool('useDynamicColors', state.useDynamicColors);
    await prefs.setBool('useRedesignedPieces', state.useRedesignedPieces);
  }

  /// Handle theme toggle event
  void _onThemeToggled(ThemeToggled event, Emitter<ThemeState> emit) {
    final newThemeMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: newThemeMode));
    _saveSettings();
  }

  /// Handle theme style change event
  void _onThemeStyleChanged(ThemeStyleChanged event, Emitter<ThemeState> emit) {
    emit(state.copyWith(themeStyle: event.style));
    _saveSettings();
  }

  /// Handle dynamic colors toggle event
  void _onDynamicColorsToggled(
    DynamicColorsToggled event,
    Emitter<ThemeState> emit,
  ) {
    emit(state.copyWith(useDynamicColors: !state.useDynamicColors));
    _saveSettings();
  }

  /// Handle redesigned pieces toggle event
  void _onRedesignedPiecesToggled(
    RedesignedPiecesToggled event,
    Emitter<ThemeState> emit,
  ) {
    emit(state.copyWith(useRedesignedPieces: !state.useRedesignedPieces));
    _saveSettings();
  }

  /// Get seed color based on theme style
  Color getSeedColor() {
    switch (state.themeStyle) {
      case 'modern':
        return Colors.teal;
      case 'forest':
        return Colors.green;
      case 'ocean':
        return Colors.blue;
      case 'sunset':
        return Colors.orange;
      case 'minimalist':
        return Colors.grey;
      case 'classic':
      default:
        return Colors.indigo;
    }
  }

  /// Get secondary color based on theme style
  Color getSecondaryColor() {
    switch (state.themeStyle) {
      case 'modern':
        return Colors.amber;
      case 'forest':
        return Colors.brown;
      case 'ocean':
        return Colors.cyan;
      case 'sunset':
        return Colors.deepOrange;
      case 'minimalist':
        return Colors.blueGrey;
      case 'classic':
      default:
        return Colors.amber;
    }
  }

  /// Get tertiary color based on theme style
  Color getTertiaryColor() {
    switch (state.themeStyle) {
      case 'modern':
        return Colors.deepPurple;
      case 'forest':
        return Colors.lightGreen;
      case 'ocean':
        return Colors.lightBlue;
      case 'sunset':
        return Colors.red;
      case 'minimalist':
        return Colors.grey;
      case 'classic':
      default:
        return Colors.deepPurple;
    }
  }

  /// Get font family based on theme style
  String getFontFamily() {
    switch (state.themeStyle) {
      case 'modern':
        return 'Roboto';
      case 'forest':
        return 'Roboto Slab';
      case 'ocean':
        return 'Montserrat';
      case 'sunset':
        return 'Raleway';
      case 'minimalist':
        return 'Roboto Mono';
      case 'classic':
      default:
        return 'Roboto';
    }
  }

  /// Create a Material 3 ThemeData
  ThemeData getThemeData({ColorScheme? dynamicColorScheme}) {
    // If dynamic colors are available and enabled, use them
    if (dynamicColorScheme != null && state.useDynamicColors) {
      return _getM3ThemeData(dynamicColorScheme);
    }

    // Otherwise, create a color scheme from seed colors
    final colorScheme = ColorScheme.fromSeed(
      seedColor: getSeedColor(),
      secondary: getSecondaryColor(),
      tertiary: getTertiaryColor(),
      brightness:
          state.themeMode == ThemeMode.light
              ? Brightness.light
              : Brightness.dark,
    );

    return _getM3ThemeData(colorScheme);
  }

  /// Helper method to create a Material 3 ThemeData from a ColorScheme
  ThemeData _getM3ThemeData(ColorScheme colorScheme) {
    final fontFamily = getFontFamily();
    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
