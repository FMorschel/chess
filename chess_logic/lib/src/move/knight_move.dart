part of 'move.dart';

final class KnightMove extends Move<Knight> {
  KnightMove({
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    super.ambiguous,
  }) : assert(
         from.rank.distanceTo(to.rank) == 2 &&
                 from.file.distanceTo(to.file) == 1 ||
             from.rank.distanceTo(to.rank) == 1 &&
                 from.file.distanceTo(to.file) == 2,
         'Knight move must form an "L" shape '
         '(${from.toAlgebraic()} -> ${to.toAlgebraic()})',
       ),
       super.base();

  static KnightCaptureMove<P> capture<P extends Piece>({
    required Knight moving,
    required Position from,
    required Position to,
    required P captured,
    Check check = Check.none,
    AmbiguousMovementType? ambiguous,
  }) {
    return KnightCaptureMove<P>(
      moving: moving,
      from: from,
      to: to,
      captured: captured,
      check: check,
      ambiguous: ambiguous,
    );
  }

  @override
  Move<Knight> copyWith({Check? check, AmbiguousMovementType? ambiguous}) =>
      KnightMove(
        from: from,
        to: to,
        moving: moving,
        check: check ?? this.check,
        ambiguous: ambiguous ?? this.ambiguous,
      );
}

final class KnightCaptureMove<P extends Piece> extends CaptureMove<Knight, P>
    implements KnightMove {
  KnightCaptureMove({
    required super.captured,
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    super.ambiguous,
  }) : assert(
         from.rank.distanceTo(to.rank) == 2 &&
                 from.file.distanceTo(to.file) == 1 ||
             from.rank.distanceTo(to.rank) == 1 &&
                 from.file.distanceTo(to.file) == 2,
         'Knight move must form an "L" shape '
         '(${from.toAlgebraic()} -> ${to.toAlgebraic()})',
       ),
       super.base();

  @override
  CaptureMove<Knight, P> copyWith({
    Check? check,
    AmbiguousMovementType? ambiguous,
  }) => KnightCaptureMove<P>(
    captured: captured,
    from: from,
    to: to,
    moving: moving,
    check: check ?? this.check,
    ambiguous: ambiguous ?? this.ambiguous,
  );
}
