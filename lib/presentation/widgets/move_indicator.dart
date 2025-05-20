import 'package:flutter/material.dart';

/// A widget that displays an animated indicator for valid chess moves.
/// 
/// This widget handles its own animation state and provides a pulsing effect
/// for move indicators on the chess board.
class MoveIndicator extends StatefulWidget {
  /// Whether this indicator represents a capture move
  final bool isCapture;

  const MoveIndicator({
    super.key,
    required this.isCapture,
  });

  @override
  State<MoveIndicator> createState() => _MoveIndicatorState();
}

class _MoveIndicatorState extends State<MoveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create an animation controller that loops continuously
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // Automatically repeat in reverse for pulsing effect
    
    // Create a scale animation that goes from 0.8 to 1.0
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.isCapture ? 40 : 20,
            height: widget.isCapture ? 40 : 20,
            decoration: BoxDecoration(
              color: widget.isCapture
                  ? colorScheme.errorContainer.withAlpha(150)
                  : colorScheme.tertiaryContainer.withAlpha(150),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isCapture ? colorScheme.error : colorScheme.tertiary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.isCapture ? colorScheme.error : colorScheme.tertiary)
                      .withAlpha(77),
                  blurRadius: 8 * _scaleAnimation.value,
                  spreadRadius: 2 * _scaleAnimation.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
