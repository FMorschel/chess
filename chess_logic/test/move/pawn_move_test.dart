import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:test/test.dart';

void main() {
  group('PawnMove', () {
    const whitePawn = Pawn.white;
    const from = Position.e1;
    const to = Position.e2;
    test('stores all fields correctly', () {
      final move = PawnMove(from: from, to: to, moving: whitePawn);

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whitePawn));
    });

    group('invalid', () {
      test('promotion to invalid', () {
        expect(
          () => PawnMove(from: from, to: Position.e3, moving: whitePawn),
          throwsA(isA<AssertionError>()),
        );
      });

      test('ambiguous movement rank', () {
        expect(
          () => PawnMove(
            from: from,
            to: to,
            moving: whitePawn,
            ambiguous: AmbiguousMovementType.rank,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = PawnMove(from: from, to: to, moving: whitePawn);

        expect(move.toAlgebraic(), equals('e2'));
      });
      test('returns correct notation with check', () {
        final move = PawnMove(
          from: from,
          to: to,
          moving: whitePawn,
          check: Check.check,
        );

        expect(move.toAlgebraic(), equals('e2+'));
      });

      test('returns correct notation with checkmate', () {
        final move = PawnMove(
          from: from,
          to: to,
          moving: whitePawn,
          check: Check.checkmate,
        );

        expect(move.toAlgebraic(), equals('e2#'));
      });

      test('returns correct notation for ambiguous movement', () {
        final move = PawnMove(
          from: from,
          to: to,
          moving: whitePawn,
          ambiguous: AmbiguousMovementType.file,
        );

        expect(move.toAlgebraic(), equals('ee2'));
      });
    });
  });
  group('PawnCaptureMove', () {
    const whitePawn = Pawn.white;
    const from = Position.e1;
    const to = Position.f2;
    const captured = Pawn.black;

    test('stores all fields correctly', () {
      final move = PawnCaptureMove(
        from: from,
        to: to,
        moving: whitePawn,
        captured: captured,
      );

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whitePawn));
      expect(move.captured, equals(captured));
    });

    group('invalid', () {
      test('promotion to invalid', () {
        expect(
          () => PawnCaptureMove(
            from: from,
            to: Position.e3,
            moving: whitePawn,
            captured: captured,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = PawnCaptureMove(
          from: from,
          to: to,
          moving: whitePawn,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('exf2'));
      });
      test('returns correct notation with check', () {
        final move = PawnCaptureMove(
          from: from,
          to: to,
          moving: whitePawn,
          check: Check.check,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('exf2+'));
      });

      test('returns correct notation with checkmate', () {
        final move = PawnCaptureMove(
          from: from,
          to: to,
          moving: whitePawn,
          check: Check.checkmate,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('exf2#'));
      });

      test('returns correct notation for ambiguous movement', () {
        final move = PawnCaptureMove(
          from: from,
          to: to,
          moving: whitePawn,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('exf2'));
      });
    });
  });
}
