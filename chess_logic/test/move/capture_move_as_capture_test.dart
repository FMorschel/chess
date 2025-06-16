import 'package:chess_logic/src/controller/capture.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('CaptureMove.asCapture()', () {
    group('Basic capture moves', () {
      test('should return a Capture for PawnCaptureMove', () {
        final move = PawnCaptureMove<Rook>(
          from: Position.e5,
          to: Position.d6,
          moving: Pawn(Team.white),
          captured: Rook(Team.black),
        );

        final capture = move.asCapture();

        expect(capture, isA<Capture<Pawn, Rook>>());
        expect(capture.captor, equals(move.moving));
        expect(capture.piece, equals(move.captured));
        expect(capture.position, equals(move.to));
        expect(capture.team, equals(Team.white));
        expect(capture.value, equals(5)); // Rook value
        expect(capture.toAlgebraic(), equals(move.toAlgebraic()));
      });

      test('should return a Capture for QueenCaptureMove', () {
        final move = QueenCaptureMove<Bishop>(
          from: Position.d1,
          to: Position.h5,
          moving: Queen(Team.white),
          captured: Bishop(Team.black),
        );

        final capture = move.asCapture();

        expect(capture, isA<Capture<Queen, Bishop>>());
        expect(capture.captor, equals(move.moving));
        expect(capture.piece, equals(move.captured));
        expect(capture.position, equals(move.to));
        expect(capture.team, equals(Team.white));
        expect(capture.value, equals(3)); // Bishop value
        expect(capture.toAlgebraic(), equals(move.toAlgebraic()));
      });

      test('should return a Capture for RookCaptureMove', () {
        final move = RookCaptureMove<Knight>(
          from: Position.a1,
          to: Position.a8,
          moving: Rook(Team.black),
          captured: Knight(Team.white),
        );

        final capture = move.asCapture();

        expect(capture, isA<Capture<Rook, Knight>>());
        expect(capture.captor, equals(move.moving));
        expect(capture.piece, equals(move.captured));
        expect(capture.position, equals(move.to));
        expect(capture.team, equals(Team.black));
        expect(capture.value, equals(3)); // Knight value
        expect(capture.toAlgebraic(), equals(move.toAlgebraic()));
      });

      test('should return a Capture for BishopCaptureMove', () {
        final move = BishopCaptureMove<Queen>(
          from: Position.c1,
          to: Position.f4,
          moving: Bishop(Team.white),
          captured: Queen(Team.black),
        );

        final capture = move.asCapture();

        expect(capture, isA<Capture<Bishop, Queen>>());
        expect(capture.captor, equals(move.moving));
        expect(capture.piece, equals(move.captured));
        expect(capture.position, equals(move.to));
        expect(capture.team, equals(Team.white));
        expect(capture.value, equals(9)); // Queen value
        expect(capture.toAlgebraic(), equals(move.toAlgebraic()));
      });

      test('should return a Capture for KnightCaptureMove', () {
        final move = KnightCaptureMove<Pawn>(
          from: Position.b1,
          to: Position.c3,
          moving: Knight(Team.black),
          captured: Pawn(Team.white),
        );

        final capture = move.asCapture();

        expect(capture, isA<Capture<Knight, Pawn>>());
        expect(capture.captor, equals(move.moving));
        expect(capture.piece, equals(move.captured));
        expect(capture.position, equals(move.to));
        expect(capture.team, equals(Team.black));
        expect(capture.value, equals(1)); // Pawn value
        expect(capture.toAlgebraic(), equals(move.toAlgebraic()));
      });

      test('should return a Capture for KingCaptureMove', () {
        final move = KingCaptureMove<Pawn>(
          from: Position.e1,
          to: Position.e2,
          moving: King(Team.white),
          captured: Pawn(Team.black),
        );

        final capture = move.asCapture();

        expect(capture, isA<Capture<King, Pawn>>());
        expect(capture.captor, equals(move.moving));
        expect(capture.piece, equals(move.captured));
        expect(capture.position, equals(move.to));
        expect(capture.team, equals(Team.white));
        expect(capture.value, equals(1)); // Pawn value
        expect(capture.toAlgebraic(), equals(move.toAlgebraic()));
      });
    });

    group('Special capture moves', () {
      test('should return a Capture for EnPassantMove', () {
        final move = EnPassantMove(
          from: Position.e5,
          to: Position.d6,
          moving: Pawn(Team.white),
          captured: Pawn(Team.black),
        );

        final capture = move.asCapture();

        expect(capture, isA<Capture<Pawn, Pawn>>());
        expect(capture.captor, equals(move.moving));
        expect(capture.piece, equals(move.captured));
        expect(capture.position, equals(move.to));
        expect(capture.team, equals(Team.white));
        expect(capture.value, equals(1)); // Pawn value
        expect(capture.toAlgebraic(), equals(move.toAlgebraic()));
      });

      test('should return a Capture for PromotionCaptureMove', () {
        final move = PromotionCaptureMove<Rook>(
          from: Position.e7,
          to: Position.d8,
          moving: Pawn(Team.white),
          captured: Rook(Team.black),
          promotion: PieceSymbol.queen,
        );

        final capture = move.asCapture();

        expect(capture, isA<Capture<Pawn, Rook>>());
        expect(capture.captor, equals(move.moving));
        expect(capture.piece, equals(move.captured));
        expect(capture.position, equals(move.to));
        expect(capture.team, equals(Team.white));
        expect(capture.value, equals(5)); // Rook value
        expect(capture.toAlgebraic(), equals(move.toAlgebraic()));
      });
    });

    group('Captures with different piece values', () {
      test('should return correct value for King capture (value 0)', () {
        final move = QueenCaptureMove<King>(
          from: Position.d1,
          to: Position.e2,
          moving: Queen(Team.white),
          captured: King(Team.black),
        );

        final capture = move.asCapture();

        expect(capture.value, equals(0)); // King has value 0
      });

      test('should return correct value for all piece types', () {
        final captures = [
          // Pawn (1)
          PawnCaptureMove<Pawn>(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn(Team.white),
            captured: Pawn(Team.black),
          ).asCapture(),
          // Knight (3)
          QueenCaptureMove<Knight>(
            from: Position.d1,
            to: Position.b1,
            moving: Queen(Team.white),
            captured: Knight(Team.black),
          ).asCapture(),
          // Bishop (3)
          RookCaptureMove<Bishop>(
            from: Position.a1,
            to: Position.c1,
            moving: Rook(Team.white),
            captured: Bishop(Team.black),
          ).asCapture(),
          // Rook (5)
          BishopCaptureMove<Rook>(
            from: Position.c1,
            to: Position.a3,
            moving: Bishop(Team.white),
            captured: Rook(Team.black),
          ).asCapture(),
          // Queen (9)
          KnightCaptureMove<Queen>(
            from: Position.b1,
            to: Position.d2,
            moving: Knight(Team.white),
            captured: Queen(Team.black),
          ).asCapture(),
          // King (0)
          PawnCaptureMove<King>(
            from: Position.e7,
            to: Position.d8,
            moving: Pawn(Team.white),
            captured: King(Team.black),
          ).asCapture(),
        ];

        final expectedValues = [1, 3, 3, 5, 9, 0];
        for (int i = 0; i < captures.length; i++) {
          expect(
            captures[i].value,
            equals(expectedValues[i]),
            reason: 'Capture $i should have value ${expectedValues[i]}',
          );
        }
      });
    });

    group('Captures with check and checkmate', () {
      test('should preserve check status in capture notation', () {
        final move = QueenCaptureMove<Rook>(
          from: Position.d1,
          to: Position.d8,
          moving: Queen(Team.white),
          captured: Rook(Team.black),
          check: Check.check,
        );

        final capture = move.asCapture();

        expect(capture.toAlgebraic(), contains('+'));
        expect(capture.toAlgebraic(), equals('Qxd8+'));
      });

      test('should preserve checkmate status in capture notation', () {
        final move = RookCaptureMove<Bishop>(
          from: Position.a1,
          to: Position.a8,
          moving: Rook(Team.white),
          captured: Bishop(Team.black),
          check: Check.checkmate,
        );

        final capture = move.asCapture();

        expect(capture.toAlgebraic(), contains('#'));
        expect(capture.toAlgebraic(), equals('Rxa8#'));
      });
    });

    group('Captures with ambiguous movements', () {
      test('should preserve file ambiguity in capture notation', () {
        final move = RookCaptureMove<Pawn>(
          from: Position.a1,
          to: Position.a4,
          moving: Rook(Team.white),
          captured: Pawn(Team.black),
          ambiguous: AmbiguousMovementType.file,
        );

        final capture = move.asCapture();

        expect(capture.toAlgebraic(), equals('Raxa4'));
      });

      test('should preserve rank ambiguity in capture notation', () {
        final move = QueenCaptureMove<Knight>(
          from: Position.d1,
          to: Position.d4,
          moving: Queen(Team.white),
          captured: Knight(Team.black),
          ambiguous: AmbiguousMovementType.rank,
        );

        final capture = move.asCapture();

        expect(capture.toAlgebraic(), equals('Q1xd4'));
      });

      test(
        'should preserve both file and rank ambiguity in capture notation',
        () {
          final move = QueenCaptureMove<Bishop>(
            from: Position.a1,
            to: Position.d4,
            moving: Queen(Team.white),
            captured: Bishop(Team.black),
            ambiguous: AmbiguousMovementType.both,
          );

          final capture = move.asCapture();

          expect(capture.toAlgebraic(), equals('Qa1xd4'));
        },
      );
    });

    group('Capture object identity and caching', () {
      test('should return the same Capture object on multiple calls', () {
        final move = PawnCaptureMove<Rook>(
          from: Position.e5,
          to: Position.d6,
          moving: Pawn(Team.white),
          captured: Rook(Team.black),
        );

        final capture1 = move.asCapture();
        final capture2 = move.asCapture();

        expect(
          identical(capture1, capture2),
          isTrue,
          reason: 'asCapture() should return the same cached object',
        );
      });

      test('should create different Capture objects for different moves', () {
        final move1 = PawnCaptureMove<Rook>(
          from: Position.e5,
          to: Position.d6,
          moving: Pawn(Team.white),
          captured: Rook(Team.black),
        );

        final move2 = PawnCaptureMove<Rook>(
          from: Position.e5,
          to: Position.f6,
          moving: Pawn(Team.white),
          captured: Rook(Team.black),
        );

        final capture1 = move1.asCapture();
        final capture2 = move2.asCapture();

        expect(
          identical(capture1, capture2),
          isFalse,
          reason: 'Different moves should have different Capture objects',
        );
      });
    });

    group('Team consistency', () {
      test('should have correct team for white pieces', () {
        final moves = <CaptureMove>[
          PawnCaptureMove<Pawn>(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn(Team.white),
            captured: Pawn(Team.black),
          ),
          QueenCaptureMove<Rook>(
            from: Position.d1,
            to: Position.d8,
            moving: Queen(Team.white),
            captured: Rook(Team.black),
          ),
          KingCaptureMove<Knight>(
            from: Position.e1,
            to: Position.e2,
            moving: King(Team.white),
            captured: Knight(Team.black),
          ),
        ];

        for (final move in moves) {
          final capture = move.asCapture();
          expect(capture.team, equals(Team.white));
          expect(capture.captor.team, equals(Team.white));
        }
      });

      test('should have correct team for black pieces', () {
        final moves = <CaptureMove>[
          PawnCaptureMove<Pawn>(
            from: Position.d4,
            to: Position.e3,
            moving: Pawn(Team.black),
            captured: Pawn(Team.white),
          ),
          RookCaptureMove<Bishop>(
            from: Position.a8,
            to: Position.a1,
            moving: Rook(Team.black),
            captured: Bishop(Team.white),
          ),
          BishopCaptureMove<Queen>(
            from: Position.f8,
            to: Position.c5,
            moving: Bishop(Team.black),
            captured: Queen(Team.white),
          ),
        ];

        for (final move in moves) {
          final capture = move.asCapture();
          expect(capture.team, equals(Team.black));
          expect(capture.captor.team, equals(Team.black));
        }
      });
    });

    group('Position consistency', () {
      test('should have capture position equal to move destination', () {
        final positions = [
          Position.d6,
          Position.h5,
          Position.b8,
          Position.f4,
          Position.c3,
        ];

        for (final position in positions) {
          final move = QueenCaptureMove<Rook>(
            from: Position.e5,
            to: position,
            moving: Queen(Team.white),
            captured: Rook(Team.black),
          );

          final capture = move.asCapture();
          expect(capture.position, equals(position));
          expect(capture.position, equals(move.to));
        }
      });
    });

    group('Complex scenarios', () {
      test('should handle promotion capture with check', () {
        final move = PromotionCaptureMove<Knight>(
          from: Position.e7,
          to: Position.d8,
          moving: Pawn(Team.white),
          captured: Knight(Team.black),
          promotion: PieceSymbol.queen,
          check: Check.check,
        );

        final capture = move.asCapture();

        expect(capture.captor, isA<Pawn>());
        expect(capture.piece, isA<Knight>());
        expect(capture.value, equals(3)); // Knight value
        expect(capture.team, equals(Team.white));
        expect(capture.position, equals(Position.d8));
        expect(capture.toAlgebraic(), equals('exd8=Q+'));
      });

      test('should handle en passant with check', () {
        final move = EnPassantMove(
          from: Position.e5,
          to: Position.d6,
          moving: Pawn(Team.white),
          captured: Pawn(Team.black),
          check: Check.check,
        );

        final capture = move.asCapture();

        expect(capture.captor, isA<Pawn>());
        expect(capture.piece, isA<Pawn>());
        expect(capture.value, equals(1)); // Pawn value
        expect(capture.team, equals(Team.white));
        expect(capture.position, equals(Position.d6));
        expect(capture.toAlgebraic(), equals('exd6+'));
      });

      test('should handle ambiguous promotion capture with checkmate', () {
        final move = PromotionCaptureMove<Rook>(
          from: Position.e7,
          to: Position.d8,
          moving: Pawn(Team.white),
          captured: Rook(Team.black),
          promotion: PieceSymbol.knight,
          check: Check.checkmate,
        );

        final capture = move.asCapture();

        expect(capture.captor, isA<Pawn>());
        expect(capture.piece, isA<Rook>());
        expect(capture.value, equals(5)); // Rook value
        expect(capture.team, equals(Team.white));
        expect(capture.position, equals(Position.d8));
        expect(capture.toAlgebraic(), equals('exd8=N#'));
      });
    });
  });
}
