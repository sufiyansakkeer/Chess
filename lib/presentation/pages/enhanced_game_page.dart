import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animations/animations.dart';
import '../../application/feedback_service.dart';
import '../../application/game_history_service.dart';
import '../../application/game_history_service_extension.dart';
import '../widgets/enhanced_chess_board.dart';
import '../widgets/move_history_and_captured_pieces.dart';
import '../blocs/blocs.dart';
import 'game_page.dart';
import 'game_history_page.dart';
import 'piece_comparison_page.dart';

class EnhancedGamePage extends StatefulWidget {
  const EnhancedGamePage({super.key});

  @override
  State<EnhancedGamePage> createState() => _EnhancedGamePageState();
}

class _EnhancedGamePageState extends State<EnhancedGamePage> {
  final DateTime _gameStartTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Get the BLoCs from the context
    final settingsBloc = context.read<SettingsBloc>();
    final gameBloc = context.watch<GameBloc>();
    final feedbackService = FeedbackService();

    // Check if the game is over and save it to history
    if (gameBloc.state.isGameOver) {
      // Save the game to history (only once)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GameHistoryService().saveGameFromBloc(
          gameBloc.state,
          _gameStartTime,
          settingsBloc.state,
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Game'),
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Game',
            onPressed: () {
              context.read<GameBloc>().add(const GameReset());
              feedbackService.selectionClick();
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Game History',
            onPressed: () {
              feedbackService.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GameHistoryPage(),
                ),
              );
            },
          ),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return IconButton(
                icon: Icon(
                  themeState.themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                tooltip: 'Toggle Theme',
                onPressed: () {
                  context.read<ThemeBloc>().add(const ThemeToggled());
                  feedbackService.selectionClick();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              feedbackService.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GamePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.design_services),
            tooltip: 'Piece Designs',
            onPressed: () {
              feedbackService.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PieceComparisonPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'Crown Queen',
            onPressed: () {
              feedbackService.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GamePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.style),
            tooltip: 'New Pieces',
            onPressed: () {
              feedbackService.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GamePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.toggle_on),
            tooltip: 'Toggle Pieces',
            onPressed: () {
              feedbackService.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GamePage()),
              );
            },
          ),
        ],
      ),
      body: const EnhancedGameContent(),
    );
  }
}

class EnhancedGameContent extends StatelessWidget {
  const EnhancedGameContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gameBloc = context.watch<GameBloc>();
    final feedbackService = FeedbackService();

    // Trigger feedback for check and checkmate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameBloc.state.isGameOver) {
        if (gameBloc.state.winner != null) {
          feedbackService.onCheckmate();
        } else {
          feedbackService.onDraw();
        }
      } else if (gameBloc.state.isInCheck) {
        feedbackService.onCheck();
      }
    });

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Game status with animation
                  Builder(
                    builder: (context) {
                      Widget statusWidget;
                      final gameState = context.watch<GameBloc>().state;

                      if (gameState.isGameOver) {
                        statusWidget = Card(
                          key: const ValueKey('game-over'),
                          color: colorScheme.tertiaryContainer,
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              gameState.winner != null
                                  ? '${gameState.winner.toString().split('.').last.toUpperCase()} wins!'
                                  : 'Game Over - Draw!',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else if (gameState.isInCheck) {
                        statusWidget = Card(
                          key: const ValueKey('check'),
                          color: colorScheme.errorContainer,
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              '${gameState.currentTurn.toString().split('.').last.toUpperCase()} King is in CHECK!',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else {
                        statusWidget = const SizedBox(
                          key: ValueKey('no-status'),
                          height: 16,
                        );
                      }

                      return PageTransitionSwitcher(
                        transitionBuilder: (
                          child,
                          primaryAnimation,
                          secondaryAnimation,
                        ) {
                          return FadeThroughTransition(
                            animation: primaryAnimation,
                            secondaryAnimation: secondaryAnimation,
                            child: child,
                          );
                        },
                        child: statusWidget,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Current turn indicator
                  BlocBuilder<GameBloc, GameState>(
                    builder: (context, gameState) {
                      return Card(
                        color: colorScheme.primaryContainer,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_right,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Current Turn: ${gameState.currentTurn.toString().split('.').last.toUpperCase()}',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Chess board with elevation and border
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: EnhancedChessBoard(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Move history and captured pieces
                  const MoveHistoryAndCapturedPieces(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
