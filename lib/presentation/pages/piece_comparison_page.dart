import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PieceComparisonPage extends StatelessWidget {
  const PieceComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chess Piece Redesign'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chess Piece Redesign Comparison',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'The redesigned pieces feature subtle gradients, refined silhouettes, and 3D effects while maintaining the Material 3 Expressive design principles.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // White Queen Comparison
            _buildComparisonSection(
              context,
              'White Queen',
              'assets/white_queen.svg',
              'assets/white_queen_redesigned.svg',
            ),

            const Divider(height: 48),

            // White Pawn Comparison
            _buildComparisonSection(
              context,
              'White Pawn',
              'assets/white_pawn.svg',
              'assets/white_pawn_redesigned.svg',
            ),

            const Divider(height: 48),

            // Black Knight Comparison
            _buildComparisonSection(
              context,
              'Black Knight',
              'assets/black_knight.svg',
              'assets/black_knight_redesigned.svg',
            ),

            const Divider(height: 48),

            // Black Bishop Comparison
            _buildComparisonSection(
              context,
              'Black Bishop',
              'assets/black_bishop.svg',
              'assets/black_bishop_redesigned.svg',
            ),

            const SizedBox(height: 32),

            // Complete set preview
            Text(
              'Complete Set Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original Set',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildPieceSet(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection(
    BuildContext context,
    String title,
    String originalAsset,
    String redesignedAsset,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPieceCard(context, 'Original', originalAsset),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPieceCard(context, 'Redesigned', redesignedAsset),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieceCard(BuildContext context, String label, String assetPath) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Center(
                child: SvgPicture.asset(assetPath, width: 80, height: 80),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieceSet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = ['white', 'black'];
    final pieceTypes = ['pawn', 'knight', 'bishop', 'rook', 'queen', 'king'];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (final color in colors) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final type in pieceTypes)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      'assets/${color}_$type.svg',
                      width: 40,
                      height: 40,
                    ),
                  ),
              ],
            ),
            if (color == 'white') const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
