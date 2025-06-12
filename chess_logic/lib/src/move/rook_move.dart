part of 'move.dart';

final class RookMove extends Move<Rook> {
  RookMove({
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    super.ambiguous,
  }) : assert(
         from.rank.distanceTo(to.rank) == 0 ||
             from.file.distanceTo(to.file) == 0,
         'Rook move must be horizontal or vertical '
         '(${from.toAlgebraic()} -> ${to.toAlgebraic()})',
       ),
       super.base();

  static RookCaptureMove<P> capture<P extends Piece>({
    required Rook moving,
    required Position from,
    required Position to,
    required P captured,
    Check check = Check.none,
    AmbiguousMovementType? ambiguous,
  }) {
    return RookCaptureMove<P>(
      moving: moving,
      from: from,
      to: to,
      captured: captured,
      check: check,
      ambiguous: ambiguous,
    );
  }

  @override
  RookMove copyWith({Check? check, AmbiguousMovementType? ambiguous}) =>
      RookMove(
        from: from,
        to: to,
        moving: moving,
        check: check ?? this.check,
        ambiguous: ambiguous ?? this.ambiguous,
      );
}

final class RookCaptureMove<P extends Piece> extends CaptureMove<Rook, P>
    implements RookMove {
  RookCaptureMove({
    required super.captured,
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    super.ambiguous,
  }) : assert(
         from.rank.distanceTo(to.rank) == 0 ||
             from.file.distanceTo(to.file) == 0,
         'Rook move must be horizontal or vertical '
         '(${from.toAlgebraic()} -> ${to.toAlgebraic()})',
       ),
       super.base();

  @override
  RookCaptureMove<P> copyWith({
    Check? check,
    AmbiguousMovementType? ambiguous,
  }) => RookCaptureMove<P>(
    captured: captured,
    from: from,
    to: to,
    moving: moving,
    check: check ?? this.check,
    ambiguous: ambiguous ?? this.ambiguous,
  );
}
