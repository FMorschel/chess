import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:test/test.dart';

void main() {
  group('KnightMove', () {
    final whiteKnight = Knight.white;
    final from = Position.b1;
    final to = Position.c3;

    test('stores all fields correctly', () {
      final move = KnightMove(from: from, to: to, moving: whiteKnight);

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whiteKnight));
    });

    test('throws assertion error for invalid move', () {
      expect(
        () => KnightMove(from: from, to: Position.c2, moving: whiteKnight),
        throwsA(isA<AssertionError>()),
      );
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = KnightMove(from: from, to: to, moving: whiteKnight);

        expect(move.toAlgebraic(), equals('Nc3'));
      });

      test('returns correct notation with check', () {
        final move = KnightMove(
          from: from,
          to: to,
          moving: whiteKnight,
          check: Check.check,
        );

        expect(move.toAlgebraic(), equals('Nc3+'));
      });

      test('returns correct notation with checkmate', () {
        final move = KnightMove(
          from: from,
          to: to,
          moving: whiteKnight,
          check: Check.checkmate,
        );

        expect(move.toAlgebraic(), equals('Nc3#'));
      });

      test('returns correct notation for ambiguous movement by file', () {
        final move = KnightMove(
          from: from,
          to: to,
          moving: whiteKnight,
          ambiguous: AmbiguousMovementType.file,
        );

        expect(move.toAlgebraic(), equals('Nbc3'));
      });

      test('returns correct notation for ambiguous movement by rank', () {
        final move = KnightMove(
          from: from,
          to: to,
          moving: whiteKnight,
          ambiguous: AmbiguousMovementType.rank,
        );

        expect(move.toAlgebraic(), equals('N1c3'));
      });

      test('returns correct notation for ambiguous movement by both', () {
        final move = KnightMove(
          from: from,
          to: to,
          moving: whiteKnight,
          ambiguous: AmbiguousMovementType.both,
        );

        expect(move.toAlgebraic(), equals('Nb1c3'));
      });
    });
  });

  group('KnightCaptureMove', () {
    final whiteKnight = Knight.white;
    final from = Position.b1;
    final to = Position.c3;
    final captured = Pawn.black;

    test('stores all fields correctly', () {
      final move = KnightCaptureMove(
        from: from,
        to: to,
        moving: whiteKnight,
        captured: captured,
      );

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whiteKnight));
      expect(move.captured, equals(captured));
    });

    test('throws assertion error for invalid move', () {
      expect(
        () => KnightCaptureMove(
          from: from,
          to: Position.c2,
          moving: whiteKnight,
          captured: captured,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = KnightCaptureMove(
          from: from,
          to: to,
          moving: whiteKnight,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Nxc3'));
      });

      test('returns correct notation with check', () {
        final move = KnightCaptureMove(
          from: from,
          to: to,
          moving: whiteKnight,
          check: Check.check,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Nxc3+'));
      });

      test('returns correct notation with checkmate', () {
        final move = KnightCaptureMove(
          from: from,
          to: to,
          moving: whiteKnight,
          check: Check.checkmate,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Nxc3#'));
      });

      test('returns correct notation for ambiguous movement by file', () {
        final move = KnightCaptureMove(
          from: from,
          to: to,
          moving: whiteKnight,
          ambiguous: AmbiguousMovementType.file,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Nbxc3'));
      });

      test('returns correct notation for ambiguous movement by rank', () {
        final move = KnightCaptureMove(
          from: from,
          to: to,
          moving: whiteKnight,
          ambiguous: AmbiguousMovementType.rank,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('N1xc3'));
      });

      test('returns correct notation for ambiguous movement by both', () {
        final move = KnightCaptureMove(
          from: from,
          to: to,
          moving: whiteKnight,
          ambiguous: AmbiguousMovementType.both,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Nb1xc3'));
      });
    });
  });
}
