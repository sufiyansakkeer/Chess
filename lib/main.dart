import 'package:flutter/material.dart';
import 'presentation/pages/game_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Chess Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GamePage(),
    );
  }
}
