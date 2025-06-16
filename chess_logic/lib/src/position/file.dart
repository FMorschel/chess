import 'dart:math';

import 'package:chess_logic/src/position/direction.dart';

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

  final String letter;

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
    return min(index, other.index) == index
        ? other.index - index
        : index - other.index;
  }
  
  @override
  int compareTo(File other) => index.compareTo(other.index);
}
