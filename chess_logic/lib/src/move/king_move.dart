part of 'move.dart';

final class KingMove extends Move<King> {
  KingMove({
    required super.moving,
    required super.from,
    required super.to,
    super.check,
  }) : assert(
         from.file.distanceTo(to.file) <= 1 &&
             from.rank.distanceTo(to.rank) <= 1,
         'King can only move one square in any direction (from: $from, to: '
         '$to)',
       ),
       super.base();

  factory KingMove.queensideCastling({
    required King king,
    required Position from,
    required Position to,
    required RookMove rook,
    Check check = Check.none,
  }) {
    return QueensideCastling(
      moving: king,
      from: from,
      to: to,
      rook: rook,
      check: check,
    );
  }

  factory KingMove.kingsideCastling({
    required King king,
    required Position from,
    required Position to,
    required RookMove rook,
    Check check = Check.none,
  }) {
    return KingsideCastling(
      moving: king,
      from: from,
      to: to,
      rook: rook,
      check: check,
    );
  }

  static KingCaptureMove<P> capture<P extends Piece>({
    required King moving,
    required Position from,
    required Position to,
    required P captured,
    Check check = Check.none,
    AmbiguousMovementType? ambiguous,
  }) {
    return KingCaptureMove(
      moving: moving,
      from: from,
      to: to,
      captured: captured,
      check: check,
    );
  }

  @override
  KingMove copyWith({Check? check, void ambiguous}) =>
      KingMove(moving: moving, from: from, to: to, check: check ?? this.check);
}

final class KingCaptureMove<P extends Piece> extends CaptureMove<King, P>
    implements KingMove {
  KingCaptureMove({
    required super.captured,
    required super.moving,
    required super.from,
    required super.to,
    super.check,
  }) : assert(
         from.file.distanceTo(to.file) <= 1 &&
             from.rank.distanceTo(to.rank) <= 1,
         'King can only move one square in any direction (from: $from, to: $to'
         ')',
       ),
       assert(captured is! King, 'King cannot capture another king'),
       super.base();

  @override
  KingCaptureMove<P> copyWith({Check? check, void ambiguous}) {
    return KingCaptureMove<P>(
      moving: moving,
      from: from,
      to: to,
      captured: captured,
      check: check ?? this.check,
    );
  }
}

/// Castling move (both kingside and queenside)
sealed class CastlingMove extends Move<King> implements KingMove {
  CastlingMove({
    required this.rook,
    required super.moving,
    required super.from,
    required super.to,
    super.check,
  }) : assert(
         moving.team == rook.moving.team,
         'Both king and rook must be from the same team for castling',
       ),
       assert(
         rook.ambiguous == null,
         'Rook move in castling cannot be ambiguous',
       ),
       assert(
         check == rook.check,
         'Castling move must have the same check status as the rook move',
       ),
       assert(
         rook.from.rank == from.rank && rook.to.rank == to.rank,
         'Rook must move on the same rank as the king for castling',
       ),
       super.base();

  factory CastlingMove.create({
    required Position from,
    required Position to,
    required King moving,
    required Move<Rook> rook,
    Check check = Check.none,
  }) {
    final constructor = switch (to.file) {
      File.g => KingsideCastling.new,
      File.c => QueensideCastling.new,
      _ => throw ArgumentError('Invalid castling destination: $to'),
    };
    return constructor(
      from: from,
      to: to,
      moving: moving,
      rook: rook,
      check: check,
    );
  }

  final Move<Rook> rook;

  @override
  List<Object?> get props => [...super.props, rook];
}

/// Kingside castling (O-O)
final class KingsideCastling extends CastlingMove {
  KingsideCastling({
    required super.from,
    required super.to,
    required super.moving,
    required super.rook,
    super.check,
  }) : assert(
         from.file == File.e && to.file == File.g,
         'Kingside castling must move the king from e to g',
       ),
       assert(
         rook.from.file == File.h && rook.to.file == File.f,
         'Kingside castling must move the rook from h to f',
       );

  @override
  KingsideCastling copyWith({Check? check, void ambiguous}) => KingsideCastling(
    from: from,
    to: to,
    moving: moving,
    rook: rook.copyWith(check: check),
    check: check ?? this.check,
  );
}

/// Queenside castling (O-O-O)
final class QueensideCastling extends CastlingMove {
  QueensideCastling({
    required super.from,
    required super.to,
    required super.moving,
    required super.rook,
    super.check,
  }) : assert(
         from.file == File.e && to.file == File.c,
         'Queenside castling must move the king from e to c',
       ),
       assert(
         rook.from.file == File.a && rook.to.file == File.d,
         'Queenside castling must move the rook from a to d',
       );

  @override
  QueensideCastling copyWith({Check? check, void ambiguous}) =>
      QueensideCastling(
        from: from,
        to: to,
        moving: moving,
        rook: rook.copyWith(check: check),
        check: check ?? this.check,
      );
}
