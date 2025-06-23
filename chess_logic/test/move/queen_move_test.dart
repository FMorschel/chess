import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:test/test.dart';

void main() {
  group('QueenMove', () {
    const whiteQueen = Queen.white;
    const from = Position.d1;
    const to = Position.d4;

    test('stores all fields correctly', () {
      final move = QueenMove(from: from, to: to, moving: whiteQueen);

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whiteQueen));
    });

    test('throws assertion error for invalid move', () {
      expect(
        () => QueenMove(from: from, to: Position.e3, moving: whiteQueen),
        throwsA(isA<AssertionError>()),
      );
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = QueenMove(from: from, to: to, moving: whiteQueen);

        expect(move.toAlgebraic(), equals('Qd4'));
      });

      test('returns correct notation with check', () {
        final move = QueenMove(
          from: from,
          to: to,
          moving: whiteQueen,
          check: Check.check,
        );

        expect(move.toAlgebraic(), equals('Qd4+'));
      });

      test('returns correct notation with checkmate', () {
        final move = QueenMove(
          from: from,
          to: to,
          moving: whiteQueen,
          check: Check.checkmate,
        );

        expect(move.toAlgebraic(), equals('Qd4#'));
      });

      test('returns correct notation for ambiguous movement by file', () {
        final move = QueenMove(
          from: from,
          to: to,
          moving: whiteQueen,
          ambiguous: AmbiguousMovementType.file,
        );

        expect(move.toAlgebraic(), equals('Qdd4'));
      });

      test('returns correct notation for ambiguous movement by rank', () {
        final move = QueenMove(
          from: from,
          to: to,
          moving: whiteQueen,
          ambiguous: AmbiguousMovementType.rank,
        );

        expect(move.toAlgebraic(), equals('Q1d4'));
      });

      test('returns correct notation for ambiguous movement by both', () {
        final move = QueenMove(
          from: from,
          to: to,
          moving: whiteQueen,
          ambiguous: AmbiguousMovementType.both,
        );

        expect(move.toAlgebraic(), equals('Qd1d4'));
      });
    });
  });

  group('QueenCaptureMove', () {
    const whiteQueen = Queen.white;
    const from = Position.d1;
    const to = Position.d4;
    const captured = Pawn.black;

    test('stores all fields correctly', () {
      final move = QueenCaptureMove(
        from: from,
        to: to,
        moving: whiteQueen,
        captured: captured,
      );

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whiteQueen));
      expect(move.captured, equals(captured));
    });

    test('throws assertion error for invalid move', () {
      expect(
        () => QueenCaptureMove(
          from: from,
          to: Position.e3,
          moving: whiteQueen,
          captured: captured,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = QueenCaptureMove(
          from: from,
          to: to,
          moving: whiteQueen,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Qxd4'));
      });

      test('returns correct notation with check', () {
        final move = QueenCaptureMove(
          from: from,
          to: to,
          moving: whiteQueen,
          check: Check.check,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Qxd4+'));
      });

      test('returns correct notation with checkmate', () {
        final move = QueenCaptureMove(
          from: from,
          to: to,
          moving: whiteQueen,
          check: Check.checkmate,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Qxd4#'));
      });

      test('returns correct notation for ambiguous movement by file', () {
        final move = QueenCaptureMove(
          from: from,
          to: to,
          moving: whiteQueen,
          ambiguous: AmbiguousMovementType.file,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Qdxd4'));
      });

      test('returns correct notation for ambiguous movement by rank', () {
        final move = QueenCaptureMove(
          from: from,
          to: to,
          moving: whiteQueen,
          ambiguous: AmbiguousMovementType.rank,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Q1xd4'));
      });

      test('returns correct notation for ambiguous movement by both', () {
        final move = QueenCaptureMove(
          from: from,
          to: to,
          moving: whiteQueen,
          ambiguous: AmbiguousMovementType.both,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Qd1xd4'));
      });
    });
  });
}
