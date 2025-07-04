import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:test/test.dart';

void main() {
  group('KingsideCastling', () {
    const whiteKing = King.white;
    const kingFrom = Position.e1;
    const kingTo = Position.g1;
    final rookMove = RookMove(
      moving: Rook.white,
      from: Position.h1,
      to: Position.f1,
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
          moving: Rook.white,
          from: Position.a1,
          to: Position.c1,
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
          moving: Rook.black,
          from: Position.h1,
          to: Position.f1,
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
