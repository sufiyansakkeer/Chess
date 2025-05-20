import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animations/animations.dart';
import '../blocs/blocs.dart';
import '../widgets/chess_board.dart';
import '../widgets/move_history_and_captured_pieces.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GamePageContent();
  }
}

class GamePageContent extends StatelessWidget {
  const GamePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
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
              context.read<GamePresenterBloc>().add(const ResetGame());
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
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
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
                    BlocBuilder<GamePresenterBloc, GamePresenterState>(
                      builder: (context, state) {
                        Widget statusWidget;
                        
                        if (state.isGameOver) {
                          statusWidget = Card(
                            key: const ValueKey('game-over'),
                            color: colorScheme.tertiaryContainer,
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                state.winner != null
                                    ? '${state.winner.toString().split('.').last.toUpperCase()} wins!'
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
                    BlocBuilder<GamePresenterBloc, GamePresenterState>(
                      builder: (context, state) {
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
                                  'Current Turn: ${state.currentTurn.toString().split('.').last.toUpperCase()}',
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
                        child: ChessBoard(),
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
      ),
    );
  }
}
