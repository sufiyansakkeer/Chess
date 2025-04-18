import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _themeStyle = 'classic';

  ThemeMode get themeMode => _themeMode;
  String get themeStyle => _themeStyle;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeStyle(String style) {
    _themeStyle = style;
    notifyListeners();
  }

  ThemeData getThemeData() {
    switch (_themeStyle) {
      case 'modern':
        return ThemeData(
          primarySwatch: Colors.teal,
          brightness:
              _themeMode == ThemeMode.light
                  ? Brightness.light
                  : Brightness.dark,
          scaffoldBackgroundColor:
              _themeMode == ThemeMode.light ? Colors.white : Colors.grey[900],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 16),
            bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.teal,
            brightness:
                _themeMode == ThemeMode.light
                    ? Brightness.light
                    : Brightness.dark,
          ).copyWith(secondary: Colors.amber),
        );
      case 'forest':
        return ThemeData(
          primarySwatch: Colors.green,
          brightness:
              _themeMode == ThemeMode.light
                  ? Brightness.light
                  : Brightness.dark,
          scaffoldBackgroundColor:
              _themeMode == ThemeMode.light
                  ? Colors.lightGreen[50]
                  : Colors.grey[850],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Verdana', fontSize: 16),
            bodyMedium: TextStyle(fontFamily: 'Verdana', fontSize: 14),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green,
            brightness:
                _themeMode == ThemeMode.light
                    ? Brightness.light
                    : Brightness.dark,
          ).copyWith(secondary: Colors.brown),
        );
      case 'ocean':
        return ThemeData(
          primarySwatch: Colors.cyan,
          brightness:
              _themeMode == ThemeMode.light
                  ? Brightness.light
                  : Brightness.dark,
          scaffoldBackgroundColor:
              _themeMode == ThemeMode.light
                  ? Colors.lightBlue[50]
                  : Colors.blueGrey[900],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Arial', fontSize: 16),
            bodyMedium: TextStyle(fontFamily: 'Arial', fontSize: 14),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.cyan,
            brightness:
                _themeMode == ThemeMode.light
                    ? Brightness.light
                    : Brightness.dark,
          ).copyWith(secondary: Colors.indigo),
        );
      case 'sunset':
        return ThemeData(
          primarySwatch: Colors.orange,
          brightness:
              _themeMode == ThemeMode.light
                  ? Brightness.light
                  : Brightness.dark,
          scaffoldBackgroundColor:
              _themeMode == ThemeMode.light
                  ? Colors.yellow[50]
                  : Colors.deepOrange[900],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Georgia', fontSize: 16),
            bodyMedium: TextStyle(fontFamily: 'Georgia', fontSize: 14),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.orange,
            brightness:
                _themeMode == ThemeMode.light
                    ? Brightness.light
                    : Brightness.dark,
          ).copyWith(secondary: Colors.red),
        );
      case 'minimalist':
        return ThemeData(
          primarySwatch: Colors.grey,
          brightness:
              _themeMode == ThemeMode.light
                  ? Brightness.light
                  : Brightness.dark,
          scaffoldBackgroundColor:
              _themeMode == ThemeMode.light ? Colors.white : Colors.black,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Helvetica', fontSize: 16),
            bodyMedium: TextStyle(fontFamily: 'Helvetica', fontSize: 14),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey,
            brightness:
                _themeMode == ThemeMode.light
                    ? Brightness.light
                    : Brightness.dark,
          ).copyWith(secondary: Colors.blueGrey),
        );
      case 'classic':
      default:
        return ThemeData(
          primarySwatch: Colors.blue,
          brightness:
              _themeMode == ThemeMode.light
                  ? Brightness.light
                  : Brightness.dark,
          scaffoldBackgroundColor:
              _themeMode == ThemeMode.light
                  ? Colors.grey[200]
                  : Colors.grey[800],
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Times New Roman', fontSize: 16),
            bodyMedium: TextStyle(fontFamily: 'Times New Roman', fontSize: 14),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            brightness:
                _themeMode == ThemeMode.light
                    ? Brightness.light
                    : Brightness.dark,
          ).copyWith(secondary: Colors.redAccent),
        );
    }
  }
}
