part of 'move.dart';

final class BishopMove extends Move<Bishop> {
  BishopMove({
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    super.ambiguous,
  }) : assert(
         from.rank.distanceTo(to.rank) == from.file.distanceTo(to.file),
         'Bishop move must be diagonal '
         '(${from.toAlgebraic()} -> ${to.toAlgebraic()})',
       ),
       super.base();
  static BishopCaptureMove<P> capture<P extends Piece>({
    required Bishop moving,
    required Position from,
    required Position to,
    required P captured,
    Check check = Check.none,
    AmbiguousMovementType ambiguous = AmbiguousMovementType.none,
  }) {
    return BishopCaptureMove<P>(
      moving: moving,
      from: from,
      to: to,
      captured: captured,
      check: check,
      ambiguous: ambiguous,
    );
  }

  @override
  BishopMove copyWith({Check? check, AmbiguousMovementType? ambiguous}) =>
      BishopMove(
        from: from,
        to: to,
        moving: moving,
        check: check ?? this.check,
        ambiguous: ambiguous ?? this.ambiguous,
      );
}

final class BishopCaptureMove<P extends Piece> extends CaptureMove<Bishop, P>
    implements BishopMove {
  BishopCaptureMove({
    required super.captured,
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    super.ambiguous,
  }) : assert(
         from.rank.distanceTo(to.rank) == from.file.distanceTo(to.file),
         'Bishop move must be diagonal '
         '(${from.toAlgebraic()} -> ${to.toAlgebraic()})',
       ),
       super.base();

  @override
  BishopCaptureMove<P> copyWith({
    Check? check,
    AmbiguousMovementType? ambiguous,
  }) => BishopCaptureMove<P>(
    captured: captured,
    from: from,
    to: to,
    moving: moving,
    check: check ?? this.check,
    ambiguous: ambiguous ?? this.ambiguous,
  );
}
