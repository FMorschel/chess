part of 'move.dart';

final class PawnMove extends Move<Pawn> {
  PawnMove({
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    super.ambiguous,
  }) : assert(
         from.next(moving.forward) == to,
         'Pawn move must move one square forward '
         '(${from.rank} -> ${to.rank})',
       ),
       assert(
         ambiguous == null || ambiguous == AmbiguousMovementType.file,
         'Promotion moves can only be ambiguous by file (${ambiguous.name})',
       ),
       super.base();

  static PawnCaptureMove<P> capture<P extends Piece>({
    required Pawn moving,
    required Position from,
    required Position to,
    required P captured,
    Check check = Check.none,
    void ambiguous,
  }) {
    return PawnCaptureMove<P>(
      moving: moving,
      from: from,
      to: to,
      captured: captured,
      check: check,
    );
  }

  factory PawnMove.initial({
    required Pawn pawn,
    required Position from,
    required Position to,
    Check check = Check.none,
    void ambiguous,
  }) {
    return PawnInitialMove(moving: pawn, from: from, to: to, check: check);
  }

  static PromotionMove promotion<P extends Piece>({
    required Pawn pawn,
    required Position from,
    required Position to,
    required PieceSymbol promotion,
    P? captured,
    Check check = Check.none,
    AmbiguousMovementType? ambiguous,
  }) => switch (captured) {
    null => PromotionMove(
      moving: pawn,
      from: from,
      to: to,
      promotion: promotion,
      check: check,
      ambiguous: ambiguous,
    ),
    _ => PromotionCaptureMove<P>(
      moving: pawn,
      from: from,
      to: to,
      captured: captured,
      promotion: promotion,
      check: check,
    ),
  };

  factory PawnMove.enPassant({
    required Pawn pawn,
    required Position from,
    required Position to,
    required Pawn captured,
    Check check = Check.none,
  }) {
    return EnPassantMove(
      moving: pawn,
      from: from,
      to: to,
      captured: captured,
      check: check,
    );
  }

  @override
  PawnMove copyWith({Check? check, AmbiguousMovementType? ambiguous}) =>
      PawnMove(
        from: from,
        to: to,
        moving: moving,
        check: check ?? this.check,
        ambiguous: ambiguous ?? this.ambiguous,
      );
}

final class PawnInitialMove extends Move<Pawn> implements PawnMove {
  PawnInitialMove({
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    void ambiguous,
  }) : assert(
         from.next(moving.forward)?.next(moving.forward) == to,
         'Initial pawn move must move two squares forward '
         '(${from.rank} -> ${to.rank})',
       ),
       assert(
         from.rank == moving.initialRank,
         'Initial pawn move must start on the initial rank '
         '(${from.rank} != ${moving.initialRank})',
       ),
       super.base();

  @override
  PawnInitialMove copyWith({Check? check, void ambiguous}) {
    return PawnInitialMove(
      from: from,
      to: to,
      moving: moving,
      check: check ?? this.check,
    );
  }
}

final class PawnCaptureMove<P extends Piece> extends CaptureMove<Pawn, P>
    implements PawnMove {
  PawnCaptureMove({
    required super.captured,
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    void ambiguous,
  }) : assert(
         moving.captureDirections.map((dir) => from.next(dir)).contains(to),
         'Pawn move must move one square diagonally '
         '(${from.toAlgebraic()} -> ${to.toAlgebraic()})',
       ),
       super.base(ambiguous: AmbiguousMovementType.file);

  static PawnCaptureMove<Pawn> enPassant({
    required Pawn pawn,
    required Position from,
    required Position to,
    required Pawn captured,
    Check check = Check.none,
  }) {
    return EnPassantMove(
      moving: pawn,
      from: from,
      to: to,
      captured: captured,
      check: check,
    );
  }

  factory PawnCaptureMove.promotion({
    required Pawn pawn,
    required Position from,
    required Position to,
    required P captured,
    required PieceSymbol promotion,
    Check check = Check.none,
    void ambiguous,
  }) {
    return PromotionCaptureMove<P>(
      moving: pawn,
      from: from,
      to: to,
      captured: captured,
      promotion: promotion,
      check: check,
    );
  }

  @override
  PawnCaptureMove<P> copyWith({Check? check, void ambiguous}) {
    return PawnCaptureMove<P>(
      moving: moving,
      from: from,
      to: to,
      captured: captured,
      check: check ?? this.check,
    );
  }
}

/// En passant capture
final class EnPassantMove extends PawnCaptureMove<Pawn> {
  EnPassantMove({
    required super.moving,
    required super.captured,
    required super.from,
    required super.to,
    super.check,
  }) : assert(
         from.file.distanceTo(to.file) == 1 &&
             from.rank.distanceTo(to.rank) == 1,
         'En passant must move one square diagonally '
         '(${from.toAlgebraic()} -> ${to.toAlgebraic()})',
       ),
       super(ambiguous: AmbiguousMovementType.file);

  @override
  // ignore: overridden_fields, better performance
  late final capturedPosition = Position._(to.file, from.rank);

  @override
  EnPassantMove copyWith({Check? check, void ambiguous}) => EnPassantMove(
    moving: moving,
    captured: captured,
    from: from,
    to: to,
    check: check ?? this.check,
  );
}

/// Pawn promotion move
final class PromotionMove extends PawnMove {
  PromotionMove({
    required this.promotion,
    required super.moving,
    required super.from,
    required super.to,
    super.check,
    super.ambiguous,
  }) : assert(
         promotion.canPromoteTo,
         'Promotion must be to a valid piece symbol ($promotion)',
       ),
       assert(
         from.file.distanceTo(to.file) < 2,
         'Promotion moves must be on the same file or adjacent files '
         '(${from.file} -> ${to.file})',
       );

  final PieceSymbol promotion;

  @override
  List<Object?> get props => [...super.props, promotion];

  @override
  PromotionMove copyWith({Check? check, AmbiguousMovementType? ambiguous}) =>
      PromotionMove(
        moving: moving,
        from: from,
        to: to,
        promotion: promotion,
        check: check ?? this.check,
        ambiguous: ambiguous ?? this.ambiguous,
      );
}

/// Pawn promotion with capture
final class PromotionCaptureMove<P extends Piece> extends PawnCaptureMove<P>
    implements PromotionMove {
  PromotionCaptureMove({
    required super.captured,
    required super.from,
    required super.to,
    required super.moving,
    required this.promotion,
    super.check,
    void ambiguous,
  }) : assert(
         promotion.canPromoteTo,
         'Promotion must be to a valid piece symbol ($promotion)',
       );

  @override
  final PieceSymbol promotion;

  @override
  List<Object?> get props => [...super.props, promotion];

  @override
  PromotionCaptureMove<P> copyWith({Check? check, void ambiguous}) =>
      PromotionCaptureMove<P>(
        moving: moving,
        from: from,
        to: to,
        captured: captured,
        promotion: promotion,
        check: check ?? this.check,
      );
}
