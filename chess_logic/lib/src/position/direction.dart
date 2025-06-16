enum Direction {
  up(ignoreFile: true),
  down(ignoreFile: true),
  left(ignoreRank: true),
  right(ignoreRank: true),
  upLeft,
  upRight,
  downLeft,
  downRight,
  upUpLeft,
  upLeftLeft,
  upUpRight,
  upRightRight,
  downDownLeft,
  downLeftLeft,
  downDownRight,
  downRightRight;

  const Direction({this.ignoreFile = false, this.ignoreRank = false});

  static const all = values;
  static const cross = [
    Direction.up,
    Direction.down,
    Direction.left,
    Direction.right,
  ];
  static const diagonal = [
    Direction.upLeft,
    Direction.upRight,
    Direction.downLeft,
    Direction.downRight,
  ];
  /// Both [cross] and [diagonal] directions, excluding [knight] moves.
  static const orthogonal = [
    ...cross,
    ...diagonal,
  ];
  static const knight = [
    Direction.upUpLeft,
    Direction.upLeftLeft,
    Direction.upUpRight,
    Direction.upRightRight,
    Direction.downDownLeft,
    Direction.downLeftLeft,
    Direction.downDownRight,
    Direction.downRightRight,
  ];

  /// Returns the opposite direction.
  Direction get opposite {
    return switch (this) {
      Direction.up => Direction.down,
      Direction.down => Direction.up,
      Direction.left => Direction.right,
      Direction.right => Direction.left,
      Direction.upLeft => Direction.downRight,
      Direction.upRight => Direction.downLeft,
      Direction.downLeft => Direction.upRight,
      Direction.downRight => Direction.upLeft,
      Direction.upUpLeft => Direction.downDownRight,
      Direction.upLeftLeft => Direction.downRightRight,
      Direction.upUpRight => Direction.downDownLeft,
      Direction.upRightRight => Direction.downLeftLeft,
      Direction.downDownLeft => Direction.upUpRight,
      Direction.downLeftLeft => Direction.upRightRight,
      Direction.downDownRight => Direction.upUpLeft,
      Direction.downRightRight => Direction.upLeftLeft,
    };
  }

  final bool ignoreFile;
  final bool ignoreRank;
}
