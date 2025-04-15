class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  Position copyWith({int? row, int? col}) {
    return Position(row ?? this.row, col ?? this.col);
  }

  bool isValid() {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  String toChessNotation() {
    return '${String.fromCharCode(97 + col)}${8 - row}';
  }
}
