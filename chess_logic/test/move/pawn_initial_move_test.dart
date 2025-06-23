import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:test/test.dart';

void main() {
  group('PawnInitialMove', () {
    const whitePawn = Pawn.white;
    const from = Position.e2;
    const to = Position.e4;
    test('stores all fields correctly', () {
      final move = PawnInitialMove(from: from, to: to, moving: whitePawn);

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whitePawn));
    });

    test('throws assertion error for invalid move', () {
      expect(
        () => PawnInitialMove(from: from, to: Position.e5, moving: whitePawn),
        throwsA(isA<AssertionError>()),
      );
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = PawnInitialMove(from: from, to: to, moving: whitePawn);

        expect(move.toAlgebraic(), equals('e4'));
      });
      test('returns correct notation with check', () {
        final move = PawnInitialMove(
          from: from,
          to: to,
          moving: whitePawn,
          check: Check.check,
        );

        expect(move.toAlgebraic(), equals('e4+'));
      });

      test('returns correct notation with checkmate', () {
        final move = PawnInitialMove(
          from: from,
          to: to,
          moving: whitePawn,
          check: Check.checkmate,
        );

        expect(move.toAlgebraic(), equals('e4#'));
      });
    });
  });
}
