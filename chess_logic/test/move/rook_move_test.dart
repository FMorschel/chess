import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('RookMove', () {
    final whiteRook = Rook(Team.white);
    final from = Position.a1;
    final to = Position.a4;

    test('stores all fields correctly', () {
      final move = RookMove(from: from, to: to, moving: whiteRook);

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whiteRook));
    });

    test('throws assertion error for invalid move', () {
      expect(
        () => RookMove(
          from: from,
          to: Position.b2,
          moving: whiteRook,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = RookMove(from: from, to: to, moving: whiteRook);

        expect(move.toAlgebraic(), equals('Ra4'));
      });

      test('returns correct notation with check', () {
        final move = RookMove(
          from: from,
          to: to,
          moving: whiteRook,
          check: Check.check,
        );

        expect(move.toAlgebraic(), equals('Ra4+'));
      });

      test('returns correct notation with checkmate', () {
        final move = RookMove(
          from: from,
          to: to,
          moving: whiteRook,
          check: Check.checkmate,
        );

        expect(move.toAlgebraic(), equals('Ra4#'));
      });

      test('returns correct notation for ambiguous movement by file', () {
        final move = RookMove(
          from: from,
          to: to,
          moving: whiteRook,
          ambiguous: AmbiguousMovementType.file,
        );

        expect(move.toAlgebraic(), equals('Raa4'));
      });

      test('returns correct notation for ambiguous movement by rank', () {
        final move = RookMove(
          from: from,
          to: to,
          moving: whiteRook,
          ambiguous: AmbiguousMovementType.rank,
        );

        expect(move.toAlgebraic(), equals('R1a4'));
      });

      test('returns correct notation for ambiguous movement by both', () {
        final move = RookMove(
          from: from,
          to: to,
          moving: whiteRook,
          ambiguous: AmbiguousMovementType.both,
        );

        expect(move.toAlgebraic(), equals('Ra1a4'));
      });
    });
  });

  group('RookCaptureMove', () {
    final whiteRook = Rook(Team.white);
    final from = Position.a1;
    final to = Position.a4;
    final captured = Pawn(Team.black);

    test('stores all fields correctly', () {
      final move = RookCaptureMove(
        from: from,
        to: to,
        moving: whiteRook,
        captured: captured,
      );

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whiteRook));
      expect(move.captured, equals(captured));
    });

    test('throws assertion error for invalid move', () {
      expect(
        () => RookCaptureMove(
          from: from,
          to: Position.b2,
          moving: whiteRook,
          captured: captured,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = RookCaptureMove(
          from: from,
          to: to,
          moving: whiteRook,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Rxa4'));
      });

      test('returns correct notation with check', () {
        final move = RookCaptureMove(
          from: from,
          to: to,
          moving: whiteRook,
          check: Check.check,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Rxa4+'));
      });

      test('returns correct notation with checkmate', () {
        final move = RookCaptureMove(
          from: from,
          to: to,
          moving: whiteRook,
          check: Check.checkmate,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Rxa4#'));
      });

      test('returns correct notation for ambiguous movement by file', () {
        final move = RookCaptureMove(
          from: from,
          to: to,
          moving: whiteRook,
          ambiguous: AmbiguousMovementType.file,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Raxa4'));
      });

      test('returns correct notation for ambiguous movement by rank', () {
        final move = RookCaptureMove(
          from: from,
          to: to,
          moving: whiteRook,
          ambiguous: AmbiguousMovementType.rank,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('R1xa4'));
      });

      test('returns correct notation for ambiguous movement by both', () {
        final move = RookCaptureMove(
          from: from,
          to: to,
          moving: whiteRook,
          ambiguous: AmbiguousMovementType.both,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Ra1xa4'));
      });
    });
  });
}
