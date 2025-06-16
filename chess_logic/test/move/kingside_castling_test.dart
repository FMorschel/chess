import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('KingsideCastling', () {
    final whiteKing = King(Team.white);
    final kingFrom = Position.fromAlgebraic('e1');
    final kingTo = Position.fromAlgebraic('g1');
    final rookMove = RookMove(
      moving: Rook(Team.white),
      from: Position.fromAlgebraic('h1'),
      to: Position.fromAlgebraic('f1'),
    );

    test('stores all fields correctly', () {
      final move = KingsideCastling(
        from: kingFrom,
        to: kingTo,
        moving: whiteKing,
        rook: rookMove,
      );

      expect(move.from, equals(kingFrom));
      expect(move.to, equals(kingTo));
      expect(move.moving, equals(whiteKing));
      expect(move.rook, equals(rookMove));
    });

    group('invalid rook', () {
      test('position', () {
        final rookMove = RookMove(
          moving: Rook(Team.white),
          from: Position.fromAlgebraic('a1'),
          to: Position.fromAlgebraic('c1'),
        );
        expect(
          () => KingsideCastling(
            from: kingFrom,
            to: kingTo,
            moving: whiteKing,
            rook: rookMove,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
      test('team', () {
        final rookMove = RookMove(
          moving: Rook(Team.black),
          from: Position.fromAlgebraic('h1'),
          to: Position.fromAlgebraic('f1'),
        );
        expect(
          () => KingsideCastling(
            from: kingFrom,
            to: kingTo,
            moving: whiteKing,
            rook: rookMove,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = KingsideCastling(
          from: kingFrom,
          to: kingTo,
          moving: whiteKing,
          rook: rookMove,
        );

        expect(move.toAlgebraic(), equals('O-O'));
      });
      test('returns correct notation with check', () {
        final move = KingsideCastling(
          from: kingFrom,
          to: kingTo,
          moving: whiteKing,
          rook: rookMove.copyWith(check: Check.check),
          check: Check.check,
        );

        expect(move.toAlgebraic(), equals('O-O+'));
      });

      test('returns correct notation with checkmate', () {
        final move = KingsideCastling(
          from: kingFrom,
          to: kingTo,
          moving: whiteKing,
          rook: rookMove.copyWith(check: Check.checkmate),
          check: Check.checkmate,
        );

        expect(move.toAlgebraic(), equals('O-O#'));
      });
    });
  });
}
