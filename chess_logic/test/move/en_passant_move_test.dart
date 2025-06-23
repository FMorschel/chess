import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('EnPassantMove', () {
    final whitePawn = Pawn.white;
    final blackPawn = Pawn.black;
    final from = Position.e5;
    final to = Position.d6;
    final captured = Pawn.black;

    test('stores all fields correctly', () {
      final move = EnPassantMove(
        from: from,
        to: to,
        moving: whitePawn,
        captured: captured,
      );

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whitePawn));
      expect(move.captured, equals(captured));
      expect(move.team, equals(Team.white));
      expect(move.ambiguous, equals(AmbiguousMovementType.file));
    });

    group('invalid from to', () {
      test('throws assertion error if from and to are the same', () {
        expect(
          () => EnPassantMove(
            from: from,
            to: from,
            moving: whitePawn,
            captured: captured,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws assertion error if from is not a pawn move', () {
        expect(
          () => EnPassantMove(
            from: Position.e4,
            to: to,
            moving: whitePawn,
            captured: captured,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('toAlgebraic()', () {
      test('returns correct notation', () {
        final move = EnPassantMove(
          from: from,
          to: to,
          moving: whitePawn,
          captured: blackPawn,
        );

        expect(move.toAlgebraic(), equals('exd6'));
      });
      test('returns correct notation with check', () {
        final move = EnPassantMove(
          from: from,
          to: to,
          moving: whitePawn,
          captured: blackPawn,
          check: Check.check,
        );

        expect(move.toAlgebraic(), equals('exd6+'));
      });

      test('returns correct notation with checkmate', () {
        final move = EnPassantMove(
          from: from,
          to: to,
          moving: whitePawn,
          captured: blackPawn,
          check: Check.checkmate,
        );

        expect(move.toAlgebraic(), equals('exd6#'));
      });
    });
  });
}
