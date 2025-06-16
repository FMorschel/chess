import 'dart:math';

import 'package:chess_logic/src/position/direction.dart';

enum Rank implements Comparable<Rank> {
  one(1),
  two(2),
  three(3),
  four(4),
  five(5),
  six(6),
  seven(7),
  eight(8);

  const Rank(this.value);
  final int value;

  factory Rank.fromValue(int value) {
    return Rank.values.firstWhere(
      (r) => r.value == value,
      orElse: () => throw ArgumentError.value(
        value,
        'value',
        'Invalid rank value: $value',
      ),
    );
  }

  Rank? next(Direction direction) => switch (direction) {
    Direction.left || Direction.right => null,
    Direction.up ||
    Direction.upLeft ||
    Direction.upRight ||
    Direction.upLeftLeft ||
    Direction.upRightRight =>
      index < Rank.values.length - 1 ? Rank.values[index + 1] : null,
    Direction.down ||
    Direction.downLeft ||
    Direction.downRight ||
    Direction.downLeftLeft ||
    Direction.downRightRight => index > 0 ? Rank.values[index - 1] : null,
    Direction.upUpLeft || Direction.upUpRight =>
      index < Rank.values.length - 2 ? Rank.values[index + 2] : null,
    Direction.downDownLeft ||
    Direction.downDownRight => index > 1 ? Rank.values[index - 2] : null,
  };

  int distanceTo(Rank other) {
    if (this == other) return 0;
    return min(index, other.index) == index
        ? other.index - index
        : index - other.index;
  }

  @override
  int compareTo(Rank other) => index.compareTo(other.index);
}
