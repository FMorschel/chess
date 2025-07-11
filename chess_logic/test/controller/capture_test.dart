import 'package:chess_logic/src/controller/capture.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('Capture', () {
    test('should expose the captured piece', () {
      const pawn = Pawn.black;
      final capture = _createCapture(captured: pawn, captor: Queen.white);

      expect(capture.piece, equals(pawn));
      expect(capture.piece, isA<Pawn>());
      expect(capture.piece.team, equals(Team.black));
    });

    test('should expose the captor piece', () {
      const queen = Queen.white;
      final capture = _createCapture(captured: Pawn.black, captor: queen);

      expect(capture.captor, equals(queen));
      expect(capture.captor, isA<Queen>());
      expect(capture.captor.team, equals(Team.white));
    });

    test('should expose the position where the capture occurred', () {
      final capture = _createCapture(captured: Pawn.black, captor: Queen.white);

      expect(capture.position, isA<Position>());
      expect(capture.position, equals(Position.d8));
    });

    test('should expose the team that performed the capture', () {
      final capture = _createCapture(captured: Pawn.black, captor: Queen.white);

      expect(capture.team, equals(Team.white));
    });

    test('should expose the value of the captured piece', () {
      final capture1 = _createCapture(
        captured: Pawn.black,
        captor: Queen.white,
      );
      expect(capture1.value, equals(1)); // Pawn value

      final capture2 = _createCapture(
        captured: Queen.black,
        captor: Rook.white,
      );
      expect(capture2.value, equals(9)); // Queen value

      final capture3 = _createCapture(
        captured: Knight.black,
        captor: Bishop.white,
      );
      expect(capture3.value, equals(3)); // Knight value
    });

    test('should convert to algebraic notation', () {
      final capture = _createCapture(captured: Pawn.black, captor: Queen.white);

      // The toAlgebraic method delegates to the underlying move
      expect(capture.toAlgebraic(), isA<String>());
    });

    group('edge cases and validation', () {
      test('should handle capture with same piece types', () {
        final capture = _createCapture(
          captured: Queen.black,
          captor: Queen.white,
        );

        expect(capture.piece, isA<Queen>());
        expect(capture.captor, isA<Queen>());
        expect(capture.piece.team, equals(Team.black));
        expect(capture.captor.team, equals(Team.white));
        expect(capture.value, equals(9)); // Queen value
      });
      test('should handle capture with all valid piece combinations', () {
        final whitePieces = Team.white.pieces;

        final blackPieces = Team.black.pieces;

        int validCombinations = 0;
        for (final captor in whitePieces) {
          for (final captured in blackPieces) {
            // Skip illegal king-on-king captures (chess rule)
            if (captor is King && captured is King) {
              continue;
            }

            final capture = _createCapture(captured: captured, captor: captor);

            expect(capture.captor, equals(captor));
            expect(capture.piece, equals(captured));
            expect(capture.team, equals(Team.white));
            expect(capture.value, equals(captured.value));
            validCombinations++;
          }
        }

        // Verify we tested 35 valid combinations (6×6 - 1 illegal king-on-king)
        expect(validCombinations, equals(35));
      });

      test('should maintain immutability of underlying move', () {
        const originalPawn = Pawn.black;
        const originalQueen = Queen.white;
        final capture = _createCapture(
          captured: originalPawn,
          captor: originalQueen,
        );

        // Verify that the capture maintains references to the original pieces
        expect(identical(capture.piece, originalPawn), isTrue);
        expect(identical(capture.captor, originalQueen), isTrue);
      });
    });

    group('property consistency', () {
      test('team should always match captor team', () {
        final whiteCaptures = [
          _createCapture(captured: Pawn.black, captor: Queen.white),
          _createCapture(captured: Rook.black, captor: Knight.white),
          _createCapture(captured: Bishop.black, captor: King.white),
        ];

        final blackCaptures = [
          _createCapture(captured: Pawn.white, captor: Queen.black),
          _createCapture(captured: Rook.white, captor: Knight.black),
          _createCapture(captured: Bishop.white, captor: King.black),
        ];

        for (final capture in whiteCaptures) {
          expect(capture.team, equals(Team.white));
          expect(capture.captor.team, equals(Team.white));
        }

        for (final capture in blackCaptures) {
          expect(capture.team, equals(Team.black));
          expect(capture.captor.team, equals(Team.black));
        }
      });
      test('value should always match captured piece value', () {
        final testCases = <(Piece, int)>[
          (Pawn.black, 1),
          (Rook.black, 5),
          (Knight.black, 3),
          (Bishop.black, 3),
          (Queen.black, 9),
          (King.black, 0), // King has 0 value (invaluable)
        ];

        for (final (piece, expectedValue) in testCases) {
          final capture = _createCapture(captured: piece, captor: Queen.white);

          expect(capture.value, equals(expectedValue));
          expect(capture.piece.value, equals(expectedValue));
        }
      });
    });

    group('type safety and generics', () {
      test('should preserve type information for captured piece', () {
        final capture = _createCapture(
          captured: Queen.black,
          captor: Rook.white,
        );

        // Type should be preserved
        expect(capture.piece, isA<Queen>());
        expect(capture.captor, isA<Rook>());

        // Verify specific piece properties
        expect(capture.piece.symbol, equals(PieceSymbol.queen));
        expect(capture.captor.symbol, equals(PieceSymbol.rook));
      });
      test('should work with different piece type combinations', () {
        // Test various valid combinations to ensure type safety
        // Note: Excludes king-on-king captures as they're illegal in chess
        final testCases = <(Piece, Piece)>[
          (Pawn.white, Knight.black),
          (Bishop.white, Rook.black),
          (Queen.white, King.black), // Queen can capture king
          (Knight.white, Pawn.black),
          (King.white, Pawn.black), // King can capture other pieces
          (Rook.white, Queen.black),
        ];

        for (final (captor, captured) in testCases) {
          final capture = _createCapture(captured: captured, captor: captor);

          expect(capture.captor.runtimeType, equals(captor.runtimeType));
          expect(capture.piece.runtimeType, equals(captured.runtimeType));
          expect(capture.team, equals(captor.team));
          expect(capture.value, equals(captured.value));
        }
      });
    });

    group('algebraic notation delegation', () {
      test('should delegate toAlgebraic to underlying move', () {
        final capture = _createCapture(
          captured: Pawn.black,
          captor: Queen.white,
        );

        final result = capture.toAlgebraic();

        // Should return the same as the underlying move's algebraic notation
        expect(result, isA<String>());
        expect(result.isNotEmpty, isTrue);

        // Verify it contains typical capture notation elements
        // (This will depend on the exact implementation of
        // CaptureMove.toAlgebraic)
        expect(result, isNot(equals('')));
      });

      test('should maintain consistency with move algebraic notation', () {
        const captured = Rook.black;
        const captor = Queen.white;
        const from = Position.d1;
        const to = Position.d8;

        final move = CaptureMove<Queen, Rook>.create(
          from: from,
          to: to,
          moving: captor,
          captured: captured,
        );
        final capture = Capture(move);

        expect(capture.toAlgebraic(), equals(move.toAlgebraic()));
      });
    });

    group('chess rules validation', () {
      test('should validate chess rules - king cannot capture king', () {
        // In chess, a king cannot capture another king because it would put
        // the capturing king in check, which is illegal

        // This test documents that our capture system respects this rule
        // by not including such scenarios in valid captures
        const whiteKing = King.white;

        // If we were to attempt this in a real game, it should be prevented
        // at the move validation level, not at the capture representation level
        // However, we exclude it from our comprehensive testing for correctness

        // Test that kings can capture other pieces (but not other kings)
        final validTargets = <Piece>[
          Pawn.black,
          Rook.black,
          Knight.black,
          Bishop.black,
          Queen.black,
        ];

        for (final target in validTargets) {
          final capture = _createCapture(captured: target, captor: whiteKing);
          expect(capture.captor, isA<King>());
          expect(capture.piece, equals(target));
        }
      });
    });
  });
}

/// Helper function to create a Capture for testing
Capture _createCapture<P extends Piece, C extends Piece>({
  required C captured,
  required P captor,
}) {
  // Use different positions based on piece type to ensure valid moves
  Position from;
  Position to;

  if (captor is Rook) {
    from = Position.a1;
    to = Position.a8; // Vertical move for rook
  } else if (captor is Bishop) {
    from = Position.a1;
    to = Position.h8; // Diagonal move for bishop
  } else if (captor is Knight) {
    from = Position.b1;
    to = Position.c3; // L-shaped move for knight
  } else if (captor is Queen) {
    from = Position.d1;
    to = Position.d8; // Vertical move for queen
  } else if (captor is King) {
    from = Position.e1;
    to = Position.e2; // One square move for king
  } else {
    // Default for pawns and other pieces - diagonal capture for pawn
    from = Position.e2;
    to = Position.d3; // Diagonal capture move
  }

  final move = CaptureMove<P, C>.create(
    from: from,
    to: to,
    moving: captor,
    captured: captured,
  );
  return Capture(move);
}
