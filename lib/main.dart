import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'application/sound_service.dart';
import 'application/game_state_manager.dart';
import 'presentation/pages/game_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/blocs/blocs.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Configure logging
  Logger.root.level = Level.ALL; // Set the desired logging level
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
    );
  });

  // Initialize sound service
  SoundService.initializeFeedbackService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
        BlocProvider<SettingsBloc>(create: (context) => SettingsBloc()),
        BlocProvider<GameBloc>(
          create: (context) => GameBloc(GameStateManager()),
        ),
      ],
      child: const ChessApp(),
    ),
  );
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            // Get the ThemeBloc instance
            final themeBloc = context.read<ThemeBloc>();

            // Use dynamic color scheme if available and enabled, otherwise use the theme bloc's color scheme
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              title: 'Chess Game',
              theme: themeBloc.getThemeData(
                dynamicColorScheme: lightDynamic?.copyWith(
                  brightness: Brightness.light,
                ),
              ),
              darkTheme: themeBloc.getThemeData(
                dynamicColorScheme: darkDynamic?.copyWith(
                  brightness: Brightness.dark,
                ),
              ),
              themeMode: themeState.themeMode,
              home: const GamePage(),
              routes: {'/settings': (context) => const SettingsPage()},
            );
          },
        );
      },
    );
  }
}
