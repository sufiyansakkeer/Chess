import 'package:flutter/material.dart';
import '../../application/game_history_service.dart';
import '../../domain/entities/game_history.dart';
import '../../domain/value_objects/piece_color.dart';

class GameHistoryPage extends StatefulWidget {
  const GameHistoryPage({super.key});

  @override
  State<GameHistoryPage> createState() => _GameHistoryPageState();
}

class _GameHistoryPageState extends State<GameHistoryPage> {
  List<GameHistory> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
    });

    final games = await GameHistoryService().getAllGames();

    setState(() {
      _games = games;
      _isLoading = false;
    });
  }

  Future<void> _deleteGame(String id) async {
    await GameHistoryService().deleteGame(id);
    await _loadGames();
  }

  Future<void> _deleteAllGames() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete All Games'),
            content: const Text(
              'Are you sure you want to delete all saved games? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await GameHistoryService().deleteAllGames();
      await _loadGames();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          if (_games.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete All Games',
              onPressed: _deleteAllGames,
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _games.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved games',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant.withAlpha(179),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completed games will appear here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _games.length,
                itemBuilder: (context, index) {
                  final game = _games[index];
                  return _buildGameHistoryCard(context, game);
                },
              ),
    );
  }

  Widget _buildGameHistoryCard(BuildContext context, GameHistory game) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine the result color
    Color resultColor;
    if (game.isDraw) {
      resultColor = colorScheme.tertiary;
    } else if (game.winner == PieceColor.white) {
      resultColor = colorScheme.primary;
    } else if (game.winner == PieceColor.black) {
      resultColor = colorScheme.error;
    } else {
      resultColor = colorScheme.onSurfaceVariant;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showGameDetails(context, game),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    game.formattedDate,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete Game',
                    onPressed: () => _deleteGame(game.id),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Result:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        game.result,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: resultColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Score:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${game.whiteScore} - ${game.blackScore}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Moves: ${game.moveCount}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Duration: ${game.formattedDuration}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameDetails(BuildContext context, GameHistory game) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Game Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Game info
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerHighest.withAlpha(
                          77,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Game Information',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                context,
                                'Date',
                                game.formattedDate,
                              ),
                              _buildInfoRow(context, 'Result', game.result),
                              _buildInfoRow(
                                context,
                                'Score',
                                '${game.whiteScore} - ${game.blackScore}',
                              ),
                              _buildInfoRow(
                                context,
                                'Moves',
                                game.moveCount.toString(),
                              ),
                              _buildInfoRow(
                                context,
                                'Duration',
                                game.formattedDuration,
                              ),
                              _buildInfoRow(
                                context,
                                'Game Mode',
                                game.gameMode,
                              ),
                              _buildInfoRow(
                                context,
                                'Difficulty',
                                _getDifficultyText(game.difficulty),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Move history
                      Text(
                        'Move History',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerHighest.withAlpha(
                          77,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child:
                              game.moves.isEmpty
                                  ? Text(
                                    'No moves recorded',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant
                                          .withAlpha(179),
                                    ),
                                  )
                                  : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (
                                        int i = 0;
                                        i < game.moves.length;
                                        i += 2
                                      )
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 30,
                                                child: Text(
                                                  '${(i ~/ 2) + 1}.',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  game.moves[i],
                                                  style:
                                                      Theme.of(
                                                        context,
                                                      ).textTheme.bodyMedium,
                                                ),
                                              ),
                                              if (i + 1 < game.moves.length)
                                                Expanded(
                                                  child: Text(
                                                    game.moves[i + 1],
                                                    style:
                                                        Theme.of(
                                                          context,
                                                        ).textTheme.bodyMedium,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
