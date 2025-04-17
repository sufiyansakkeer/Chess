import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/value_objects/position.dart';
import '../presenters/game_presenter.dart';
import 'chess_piece.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Consumer<GamePresenter>(
          builder:
              (context, presenter, _) => GridView.count(
                crossAxisCount: 8,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(64, (index) {
                  final row = index ~/ 8;
                  final col = index % 8;
                  final position = Position(row, col);
                  final piece = presenter.board[row][col];
                  final isSelected = position == presenter.selectedPosition;
                  final isValidMove = presenter.validMoves.contains(position);

                  return GestureDetector(
                    key: ValueKey('square_${row}_$col'),
                    onTap: () => presenter.selectPosition(context, position),
                    child: Stack(
                      children: [
                        Container(
                          color: _getSquareColor(
                            row,
                            col,
                            isSelected,
                            isValidMove,
                          ),
                        ),
                        if (piece != null)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Center(child: ChessPiece(piece: piece)),
                          ),
                        if (isValidMove) _buildMoveIndicator(piece != null),
                      ],
                    ),
                  );
                }),
              ),
        ),
      ),
    );
  }

  Color _getSquareColor(int row, int col, bool isSelected, bool isValidMove) {
    if (isSelected) {
      return Colors.blue.withAlpha(128);
    }
    if (isValidMove) {
      return Colors.green.withAlpha(77);
    }
    return ((row + col) % 2 == 0) ? Colors.white : Colors.grey.shade400;
  }

  Widget _buildMoveIndicator(bool isCapture) {
    return Center(
      child: Container(
        width: isCapture ? 40 : 20,
        height: isCapture ? 40 : 20,
        decoration: BoxDecoration(
          color:
              isCapture ? Colors.red.withAlpha(77) : Colors.green.withAlpha(77),
          shape: BoxShape.circle,
          border: Border.all(
            color: isCapture ? Colors.red : Colors.green,
            width: 2,
          ),
        ),
      ),
    );
  }
}
