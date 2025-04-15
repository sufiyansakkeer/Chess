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
                    onTap: () => presenter.selectPosition(position),
                    child: Container(
                      color: _getSquareColor(row, col, isSelected, isValidMove),
                      child: piece != null ? ChessPiece(piece: piece) : null,
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
      return Colors.blue.withOpacity(0.5);
    }
    if (isValidMove) {
      return Colors.green.withOpacity(0.3);
    }
    return ((row + col) % 2 == 0) ? Colors.white : Colors.grey;
  }
}
