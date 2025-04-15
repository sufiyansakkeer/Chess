class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  bool isValid() {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '($row, $col)';
}
