import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/feedback_service.dart';
import '../blocs/theme/theme.dart';
import '../blocs/settings/settings.dart';
import 'game_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final feedbackService = FeedbackService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme settings section
            _buildSectionHeader(context, 'Theme Settings'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme mode
                    BlocBuilder<ThemeBloc, ThemeState>(
                      buildWhen:
                          (previous, current) =>
                              previous.themeMode != current.themeMode,
                      builder: (context, themeState) {
                        return ListTile(
                          title: const Text('Theme Mode'),
                          subtitle: Text(
                            themeState.themeMode == ThemeMode.light
                                ? 'Light'
                                : 'Dark',
                          ),
                          leading: Icon(
                            themeState.themeMode == ThemeMode.light
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            color: colorScheme.primary,
                          ),
                          trailing: Switch(
                            value: themeState.themeMode == ThemeMode.dark,
                            onChanged: (value) {
                              context.read<ThemeBloc>().add(
                                const ThemeToggled(),
                              );
                              feedbackService.selectionClick();
                            },
                          ),
                        );
                      },
                    ),

                    // Theme style
                    BlocBuilder<ThemeBloc, ThemeState>(
                      buildWhen:
                          (previous, current) =>
                              previous.themeStyle != current.themeStyle,
                      builder: (context, themeState) {
                        return ListTile(
                          title: const Text('Theme Style'),
                          subtitle: Text(
                            themeState.themeStyle
                                    .substring(0, 1)
                                    .toUpperCase() +
                                themeState.themeStyle.substring(1),
                          ),
                          leading: Icon(
                            Icons.palette,
                            color: colorScheme.primary,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            _showThemeStylePicker(context);
                            feedbackService.selectionClick();
                          },
                        );
                      },
                    ),

                    // Dynamic colors
                    BlocBuilder<ThemeBloc, ThemeState>(
                      buildWhen:
                          (previous, current) =>
                              previous.useDynamicColors !=
                              current.useDynamicColors,
                      builder: (context, themeState) {
                        return ListTile(
                          title: const Text('Dynamic Colors'),
                          subtitle: const Text(
                            'Use system colors when available',
                          ),
                          leading: Icon(
                            Icons.color_lens,
                            color: colorScheme.primary,
                          ),
                          trailing: Switch(
                            value: themeState.useDynamicColors,
                            onChanged: (value) {
                              context.read<ThemeBloc>().add(
                                const DynamicColorsToggled(),
                              );
                              feedbackService.selectionClick();
                            },
                          ),
                        );
                      },
                    ),

                    const Divider(),

                    // Redesigned chess pieces
                    BlocBuilder<ThemeBloc, ThemeState>(
                      buildWhen:
                          (previous, current) =>
                              previous.useRedesignedPieces !=
                              current.useRedesignedPieces,
                      builder: (context, themeState) {
                        return ListTile(
                          title: const Text('Redesigned Chess Pieces'),
                          subtitle: const Text(
                            'Use modern piece designs with 3D effects',
                          ),
                          leading: Icon(
                            Icons.style,
                            color: colorScheme.primary,
                          ),
                          trailing: Switch(
                            value: themeState.useRedesignedPieces,
                            onChanged: (value) {
                              context.read<ThemeBloc>().add(
                                const RedesignedPiecesToggled(),
                              );
                              feedbackService.selectionClick();
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GamePage(),
                              ),
                            );
                            feedbackService.selectionClick();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Game settings section
            _buildSectionHeader(context, 'Game Settings'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Difficulty
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen:
                          (previous, current) =>
                              previous.difficulty != current.difficulty,
                      builder: (context, settingsState) {
                        return ListTile(
                          title: const Text('Difficulty'),
                          subtitle: Text(
                            _getDifficultyText(settingsState.difficulty),
                          ),
                          leading: Icon(
                            Icons.psychology,
                            color: colorScheme.primary,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            _showDifficultyPicker(context);
                            feedbackService.selectionClick();
                          },
                        );
                      },
                    ),

                    // Time control
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen:
                          (previous, current) =>
                              previous.timeControlEnabled !=
                                  current.timeControlEnabled ||
                              previous.timeControlMinutes !=
                                  current.timeControlMinutes,
                      builder: (context, settingsState) {
                        return ListTile(
                          title: const Text('Time Control'),
                          subtitle: Text(
                            settingsState.timeControlEnabled
                                ? '${settingsState.timeControlMinutes} minutes per player'
                                : 'Disabled',
                          ),
                          leading: Icon(
                            Icons.timer,
                            color: colorScheme.primary,
                          ),
                          trailing: Switch(
                            value: settingsState.timeControlEnabled,
                            onChanged: (value) {
                              context.read<SettingsBloc>().add(
                                const TimeControlToggled(),
                              );
                              feedbackService.selectionClick();
                            },
                          ),
                          onTap: () {
                            if (settingsState.timeControlEnabled) {
                              _showTimeControlPicker(context);
                              feedbackService.selectionClick();
                            }
                          },
                        );
                      },
                    ),

                    // Auto-promote to queen
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen:
                          (previous, current) =>
                              previous.autoPromoteToQueen !=
                              current.autoPromoteToQueen,
                      builder: (context, settingsState) {
                        return ListTile(
                          title: const Text('Auto-Promote to Queen'),
                          subtitle: const Text(
                            'Automatically promote pawns to queens',
                          ),
                          leading: Icon(
                            Icons.auto_awesome,
                            color: colorScheme.primary,
                          ),
                          trailing: Switch(
                            value: settingsState.autoPromoteToQueen,
                            onChanged: (value) {
                              context.read<SettingsBloc>().add(
                                const AutoPromoteToQueenToggled(),
                              );
                              feedbackService.selectionClick();
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Feedback settings section
            _buildSectionHeader(context, 'Feedback Settings'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Haptic feedback
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen:
                          (previous, current) =>
                              previous.hapticFeedbackEnabled !=
                              current.hapticFeedbackEnabled,
                      builder: (context, settingsState) {
                        return ListTile(
                          title: const Text('Haptic Feedback'),
                          subtitle: const Text('Vibration when moving pieces'),
                          leading: Icon(
                            Icons.vibration,
                            color: colorScheme.primary,
                          ),
                          trailing: Switch(
                            value: settingsState.hapticFeedbackEnabled,
                            onChanged: (value) {
                              context.read<SettingsBloc>().add(
                                const HapticFeedbackToggled(),
                              );
                              // Still provide feedback for this toggle
                              if (value) {
                                feedbackService.selectionClick();
                              }
                            },
                          ),
                        );
                      },
                    ),

                    // Sound effects
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen:
                          (previous, current) =>
                              previous.soundEffectsEnabled !=
                              current.soundEffectsEnabled,
                      builder: (context, settingsState) {
                        return ListTile(
                          title: const Text('Sound Effects'),
                          subtitle: const Text('Play sounds during the game'),
                          leading: Icon(
                            Icons.volume_up,
                            color: colorScheme.primary,
                          ),
                          trailing: Switch(
                            value: settingsState.soundEffectsEnabled,
                            onChanged: (value) {
                              context.read<SettingsBloc>().add(
                                const SoundEffectsToggled(),
                              );
                              feedbackService.selectionClick();
                            },
                          ),
                        );
                      },
                    ),

                    // Sound volume
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen:
                          (previous, current) =>
                              previous.soundVolume != current.soundVolume ||
                              previous.soundEffectsEnabled !=
                                  current.soundEffectsEnabled,
                      builder: (context, settingsState) {
                        return ListTile(
                          title: const Text('Sound Volume'),
                          subtitle: Slider(
                            value: settingsState.soundVolume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            label:
                                '${(settingsState.soundVolume * 100).round()}%',
                            onChanged:
                                settingsState.soundEffectsEnabled
                                    ? (value) {
                                      context.read<SettingsBloc>().add(
                                        SoundVolumeChanged(value),
                                      );
                                    }
                                    : null,
                          ),
                          leading: Icon(
                            Icons.volume_down,
                            color: colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Game history settings section
            _buildSectionHeader(context, 'Game History Settings'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Save game history
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen:
                          (previous, current) =>
                              previous.saveGameHistory !=
                              current.saveGameHistory,
                      builder: (context, settingsState) {
                        return ListTile(
                          title: const Text('Save Game History'),
                          subtitle: const Text('Keep a record of your games'),
                          leading: Icon(
                            Icons.history,
                            color: colorScheme.primary,
                          ),
                          trailing: Switch(
                            value: settingsState.saveGameHistory,
                            onChanged: (value) {
                              context.read<SettingsBloc>().add(
                                const SaveGameHistoryToggled(),
                              );
                              feedbackService.selectionClick();
                            },
                          ),
                        );
                      },
                    ),

                    // Max saved games
                    BlocBuilder<SettingsBloc, SettingsState>(
                      buildWhen:
                          (previous, current) =>
                              previous.maxSavedGames != current.maxSavedGames ||
                              previous.saveGameHistory !=
                                  current.saveGameHistory,
                      builder: (context, settingsState) {
                        return ListTile(
                          title: const Text('Maximum Saved Games'),
                          subtitle: Text(
                            '${settingsState.maxSavedGames} games',
                          ),
                          leading: Icon(
                            Icons.storage,
                            color: colorScheme.primary,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          enabled: settingsState.saveGameHistory,
                          onTap:
                              settingsState.saveGameHistory
                                  ? () {
                                    _showMaxSavedGamesPicker(context);
                                    feedbackService.selectionClick();
                                  }
                                  : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Reset settings button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text('Reset All Settings'),
                onPressed: () {
                  _showResetConfirmation(context);
                  feedbackService.selectionClick();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showThemeStylePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Choose Theme Style',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    _buildThemeStyleTile(context, 'Classic', Colors.indigo),
                    _buildThemeStyleTile(context, 'Modern', Colors.teal),
                    _buildThemeStyleTile(context, 'Forest', Colors.green),
                    _buildThemeStyleTile(context, 'Ocean', Colors.blue),
                    _buildThemeStyleTile(context, 'Sunset', Colors.orange),
                    _buildThemeStyleTile(context, 'Minimalist', Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeStyleTile(
    BuildContext context,
    String styleName,
    Color color,
  ) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isSelected = themeState.themeStyle == styleName.toLowerCase();

        return ListTile(
          title: Text(styleName),
          leading: CircleAvatar(backgroundColor: color, radius: 16),
          trailing: isSelected ? const Icon(Icons.check) : null,
          onTap: () {
            context.read<ThemeBloc>().add(
              ThemeStyleChanged(styleName.toLowerCase()),
            );
            FeedbackService().selectionClick();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showDifficultyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Choose Difficulty',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, settingsState) {
                  return Column(
                    children: [
                      _buildDifficultyTile(
                        context,
                        0,
                        'Beginner',
                        'For new players',
                        settingsState.difficulty == 0,
                      ),
                      _buildDifficultyTile(
                        context,
                        1,
                        'Intermediate',
                        'For casual players',
                        settingsState.difficulty == 1,
                      ),
                      _buildDifficultyTile(
                        context,
                        2,
                        'Advanced',
                        'For experienced players',
                        settingsState.difficulty == 2,
                      ),
                      _buildDifficultyTile(
                        context,
                        3,
                        'Expert',
                        'For skilled players',
                        settingsState.difficulty == 3,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDifficultyTile(
    BuildContext context,
    int difficulty,
    String title,
    String subtitle,
    bool isSelected,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        context.read<SettingsBloc>().add(DifficultyChanged(difficulty));
        FeedbackService().selectionClick();
        Navigator.pop(context);
      },
    );
  }

  void _showTimeControlPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Choose Time Control',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, settingsState) {
                  return Column(
                    children: [
                      _buildTimeControlTile(
                        context,
                        5,
                        '5 Minutes',
                        'Blitz game',
                        settingsState.timeControlMinutes == 5,
                      ),
                      _buildTimeControlTile(
                        context,
                        10,
                        '10 Minutes',
                        'Rapid game',
                        settingsState.timeControlMinutes == 10,
                      ),
                      _buildTimeControlTile(
                        context,
                        15,
                        '15 Minutes',
                        'Standard game',
                        settingsState.timeControlMinutes == 15,
                      ),
                      _buildTimeControlTile(
                        context,
                        30,
                        '30 Minutes',
                        'Long game',
                        settingsState.timeControlMinutes == 30,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeControlTile(
    BuildContext context,
    int minutes,
    String title,
    String subtitle,
    bool isSelected,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        context.read<SettingsBloc>().add(TimeControlMinutesChanged(minutes));
        FeedbackService().selectionClick();
        Navigator.pop(context);
      },
    );
  }

  void _showMaxSavedGamesPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Maximum Saved Games',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, settingsState) {
                  return Column(
                    children: [
                      _buildMaxSavedGamesTile(
                        context,
                        5,
                        '5 Games',
                        settingsState.maxSavedGames == 5,
                      ),
                      _buildMaxSavedGamesTile(
                        context,
                        10,
                        '10 Games',
                        settingsState.maxSavedGames == 10,
                      ),
                      _buildMaxSavedGamesTile(
                        context,
                        20,
                        '20 Games',
                        settingsState.maxSavedGames == 20,
                      ),
                      _buildMaxSavedGamesTile(
                        context,
                        50,
                        '50 Games',
                        settingsState.maxSavedGames == 50,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaxSavedGamesTile(
    BuildContext context,
    int maxGames,
    String title,
    bool isSelected,
  ) {
    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        context.read<SettingsBloc>().add(MaxSavedGamesChanged(maxGames));
        FeedbackService().selectionClick();
        Navigator.pop(context);
      },
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text(
            'Are you sure you want to reset all settings to their default values?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Reset settings bloc
                context.read<SettingsBloc>().add(const SettingsReset());

                // Reset theme bloc to default values
                final themeState = context.read<ThemeBloc>().state;

                // Reset theme style to classic
                if (themeState.themeStyle != 'classic') {
                  context.read<ThemeBloc>().add(
                    const ThemeStyleChanged('classic'),
                  );
                }

                // Enable dynamic colors if disabled
                if (!themeState.useDynamicColors) {
                  context.read<ThemeBloc>().add(const DynamicColorsToggled());
                }

                // Disable redesigned pieces if enabled
                if (themeState.useRedesignedPieces) {
                  context.read<ThemeBloc>().add(
                    const RedesignedPiecesToggled(),
                  );
                }

                // Set light theme if currently dark
                if (themeState.themeMode == ThemeMode.dark) {
                  context.read<ThemeBloc>().add(const ThemeToggled());
                }
                FeedbackService().selectionClick();
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 0:
        return 'Beginner';
      case 1:
        return 'Intermediate';
      case 2:
        return 'Advanced';
      case 3:
        return 'Expert';
      default:
        return 'Intermediate';
    }
  }
}
