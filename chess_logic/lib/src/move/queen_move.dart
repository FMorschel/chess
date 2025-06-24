part of 'move.dart';

final class QueenMove extends Move<Queen> {
  QueenMove({
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    super.ambiguous,
  }) : assert(
         from.rank.distanceTo(to.rank) == 0 ||
             from.file.distanceTo(to.file) == 0 ||
             from.rank.distanceTo(to.rank) == from.file.distanceTo(to.file),
         'Queen move must be horizontal, vertical, or diagonal '
         '(${from.toAlgebraic()} -> ${to.toAlgebraic()})',
       ),
       super.base();
  static QueenCaptureMove<P> capture<P extends Piece>({
    required Queen moving,
    required Position from,
    required Position to,
    required P captured,
    Check check = Check.none,
    AmbiguousMovementType ambiguous = AmbiguousMovementType.none,
  }) {
    return QueenCaptureMove<P>(
      moving: moving,
      from: from,
      to: to,
      captured: captured,
      check: check,
      ambiguous: ambiguous,
    );
  }

  @override
  QueenMove copyWith({Check? check, AmbiguousMovementType? ambiguous}) =>
      QueenMove(
        from: from,
        to: to,
        moving: moving,
        check: check ?? this.check,
        ambiguous: ambiguous ?? this.ambiguous,
      );
}

final class QueenCaptureMove<P extends Piece> extends CaptureMove<Queen, P>
    implements QueenMove {
  QueenCaptureMove({
    required super.captured,
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    super.ambiguous,
  }) : assert(
         from.rank.distanceTo(to.rank) == 0 ||
             from.file.distanceTo(to.file) == 0 ||
             from.rank.distanceTo(to.rank) == from.file.distanceTo(to.file),
         'Queen move must be horizontal, vertical, or diagonal '
         '(${from.toAlgebraic()} -> ${to.toAlgebraic()} = '
         '${from.rank.distanceTo(to.rank)}${from.file.distanceTo(to.file)})',
       ),
       super.base();

  @override
  QueenCaptureMove<P> copyWith({
    Check? check,
    AmbiguousMovementType? ambiguous,
  }) {
    return QueenCaptureMove<P>(
      captured: captured,
      from: from,
      to: to,
      moving: moving,
      check: check ?? this.check,
      ambiguous: ambiguous ?? this.ambiguous,
    );
  }
}
