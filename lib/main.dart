import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/game_page.dart';
import 'presentation/providers/theme_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Configure logging
  Logger.root.level = Level.ALL; // Set the desired logging level
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
    );
  });

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const ChessApp(),
    ),
  );
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          title: 'Chess Game',
          theme: themeProvider.getThemeData().copyWith(
            brightness: Brightness.light,
          ),
          darkTheme: themeProvider.getThemeData().copyWith(
            brightness: Brightness.dark,
          ),
          themeMode: themeProvider.themeMode,
          home: const GamePage(),
        );
      },
    );
  }
}
