/// Point values for different chess piece types.
///
/// Used for calculating material advantage and evaluating positions.
/// King has a value of 0 since it is invaluable.
enum PieceValue {
  king(0),
  queen(9),
  rook(5),
  bishop(3),
  knight(3),
  pawn(1);

  const PieceValue(this.points);

  /// {@template piece_value}
  /// The value of the piece in points.
  ///
  /// King is invaluable, so it has a value of 0.
  /// {@endtemplate}
  final int points;
}
