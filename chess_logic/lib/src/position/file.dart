import '../square/piece_symbol.dart';
import 'direction.dart';

enum File implements Comparable<File> {
  a('a'),
  b('b'),
  c('c'),
  d('d'),
  e('e'),
  f('f'),
  g('g'),
  h('h');

  const File(this.letter);

  factory File.fromLetter(String letter) {
    return File.values.firstWhere(
      (f) => f.letter.toUpperCase() == letter.toUpperCase(),
      orElse: () => throw ArgumentError.value(
        letter,
        'letter',
        'Invalid file letter: $letter',
      ),
    );
  }

  final String letter;

  static File max(File a, File b) => a > b ? a : b;

  static File min(File a, File b) => a < b ? a : b;

  File? next(Direction direction) => switch (direction) {
    Direction.up || Direction.down => null,
    Direction.left ||
    Direction.upLeft ||
    Direction.upUpLeft ||
    Direction.downLeft ||
    Direction.downDownLeft => index > 0 ? File.values[index - 1] : null,
    Direction.right ||
    Direction.upRight ||
    Direction.upUpRight ||
    Direction.downRight ||
    Direction.downDownRight =>
      index < File.values.length - 1 ? File.values[index + 1] : null,
    Direction.upLeftLeft ||
    Direction.downLeftLeft => index > 1 ? File.values[index - 2] : null,
    Direction.upRightRight || Direction.downRightRight =>
      index < File.values.length - 2 ? File.values[index + 2] : null,
  };

  int distanceTo(File other) {
    if (this == other) return 0;
    return (index - other.index).abs();
  }

  @override
  int compareTo(File other) => index.compareTo(other.index);

  bool operator <(File other) => index < other.index;

  bool operator >(File other) => index > other.index;

  /// Default piece symbol for this file in the starting position.
  PieceSymbol get defaultSymbol {
    switch (this) {
      case File.a:
      case File.h:
        return PieceSymbol.rook;
      case File.b:
      case File.g:
        return PieceSymbol.knight;
      case File.c:
      case File.f:
        return PieceSymbol.bishop;
      case File.d:
        return PieceSymbol.queen;
      case File.e:
        return PieceSymbol.king;
    }
  }
}
