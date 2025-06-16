import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('BishopMove', () {
    final whiteBishop = Bishop(Team.white);
    final from = Position.c1;
    final to = Position.f4;

    test('stores all fields correctly', () {
      final move = BishopMove(from: from, to: to, moving: whiteBishop);

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whiteBishop));
    });

    test('throws assertion error for invalid move', () {
      expect(
        () => BishopMove(
          from: from,
          to: Position.f3,
          moving: whiteBishop,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = BishopMove(from: from, to: to, moving: whiteBishop);

        expect(move.toAlgebraic(), equals('Bf4'));
      });

      test('returns correct notation with check', () {
        final move = BishopMove(
          from: from,
          to: to,
          moving: whiteBishop,
          check: Check.check,
        );

        expect(move.toAlgebraic(), equals('Bf4+'));
      });

      test('returns correct notation with checkmate', () {
        final move = BishopMove(
          from: from,
          to: to,
          moving: whiteBishop,
          check: Check.checkmate,
        );

        expect(move.toAlgebraic(), equals('Bf4#'));
      });

      test('returns correct notation for ambiguous movement by file', () {
        final move = BishopMove(
          from: from,
          to: to,
          moving: whiteBishop,
          ambiguous: AmbiguousMovementType.file,
        );

        expect(move.toAlgebraic(), equals('Bcf4'));
      });

      test('returns correct notation for ambiguous movement by rank', () {
        final move = BishopMove(
          from: from,
          to: to,
          moving: whiteBishop,
          ambiguous: AmbiguousMovementType.rank,
        );

        expect(move.toAlgebraic(), equals('B1f4'));
      });

      test('returns correct notation for ambiguous movement by both', () {
        final move = BishopMove(
          from: from,
          to: to,
          moving: whiteBishop,
          ambiguous: AmbiguousMovementType.both,
        );

        expect(move.toAlgebraic(), equals('Bc1f4'));
      });
    });
  });

  group('BishopCaptureMove', () {
    final whiteBishop = Bishop(Team.white);
    final from = Position.c1;
    final to = Position.f4;
    final captured = Pawn(Team.black);

    test('stores all fields correctly', () {
      final move = BishopCaptureMove(
        from: from,
        to: to,
        moving: whiteBishop,
        captured: captured,
      );

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whiteBishop));
      expect(move.captured, equals(captured));
    });

    test('throws assertion error for invalid move', () {
      expect(
        () => BishopCaptureMove(
          from: from,
          to: Position.f3,
          moving: whiteBishop,
          captured: captured,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = BishopCaptureMove(
          from: from,
          to: to,
          moving: whiteBishop,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Bxf4'));
      });

      test('returns correct notation with check', () {
        final move = BishopCaptureMove(
          from: from,
          to: to,
          moving: whiteBishop,
          check: Check.check,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Bxf4+'));
      });

      test('returns correct notation with checkmate', () {
        final move = BishopCaptureMove(
          from: from,
          to: to,
          moving: whiteBishop,
          check: Check.checkmate,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Bxf4#'));
      });

      test('returns correct notation for ambiguous movement by file', () {
        final move = BishopCaptureMove(
          from: from,
          to: to,
          moving: whiteBishop,
          ambiguous: AmbiguousMovementType.file,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Bcxf4'));
      });

      test('returns correct notation for ambiguous movement by rank', () {
        final move = BishopCaptureMove(
          from: from,
          to: to,
          moving: whiteBishop,
          ambiguous: AmbiguousMovementType.rank,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('B1xf4'));
      });

      test('returns correct notation for ambiguous movement by both', () {
        final move = BishopCaptureMove(
          from: from,
          to: to,
          moving: whiteBishop,
          ambiguous: AmbiguousMovementType.both,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Bc1xf4'));
      });
    });
  });
}
