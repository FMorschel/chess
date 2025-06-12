import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('KingMove', () {
    final whiteKing = King(Team.white);
    final from = Position.fromAlgebraic('e1');
    final to = Position.fromAlgebraic('e2');
    test('stores all fields correctly', () {
      final move = KingMove(from: from, to: to, moving: whiteKing);

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whiteKing));
    });

    test('throws assertion error for invalid move', () {
      expect(
        () => KingMove(
          from: from,
          to: Position.fromAlgebraic('e3'),
          moving: whiteKing,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = KingMove(from: from, to: to, moving: whiteKing);

        expect(move.toAlgebraic(), equals('Ke2'));
      });

      test('returns correct notation with check', () {
        final move = KingMove(
          from: from,
          to: to,
          moving: whiteKing,
          check: Check.check,
        );

        expect(move.toAlgebraic(), equals('Ke2+'));
      });

      test('returns correct notation with checkmate', () {
        final move = KingMove(
          from: from,
          to: to,
          moving: whiteKing,
          check: Check.checkmate,
        );

        expect(move.toAlgebraic(), equals('Ke2#'));
      });
    });
  });
  group('KingCaptureMove', () {
    final whiteKing = King(Team.white);
    final from = Position.fromAlgebraic('e1');
    final to = Position.fromAlgebraic('e2');
    final captured = Pawn(Team.black);

    test('stores all fields correctly', () {
      final move = KingCaptureMove(
        from: from,
        to: to,
        moving: whiteKing,
        captured: captured,
      );

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whiteKing));
      expect(move.captured, equals(captured));
    });
    test('throws assertion error for invalid move', () {
      expect(
        () => KingCaptureMove(
          from: from,
          to: Position.fromAlgebraic('e3'),
          moving: whiteKing,
          captured: captured,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = KingCaptureMove(
          from: from,
          to: to,
          moving: whiteKing,
          captured: captured,
        );

        expect(move.toAlgebraic(), equals('Kxe2'));
      });

      test('returns correct notation with check', () {
        final move = KingCaptureMove(
          from: from,
          to: to,
          moving: whiteKing,
          captured: captured,
          check: Check.check,
        );

        expect(move.toAlgebraic(), equals('Kxe2+'));
      });

      test('returns correct notation with checkmate', () {
        final move = KingCaptureMove(
          from: from,
          to: to,
          moving: whiteKing,
          captured: captured,
          check: Check.checkmate,
        );

        expect(move.toAlgebraic(), equals('Kxe2#'));
      });
    });
  });
}
