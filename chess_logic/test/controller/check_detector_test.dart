import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/controller/check_detector.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('CheckDetector', () {
    late BoardState boardState;
    late CheckDetector checkDetector;

    setUp(() {
      boardState = BoardState.clear();
      checkDetector = CheckDetector(boardState);
    });

    group('detectCheckAfterMove', () {
      test('should return Check.none when no check occurs', () {
        // Setup: King and queen in safe positions
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d1'): Queen(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Move queen to a safe position
        final move = QueenMove(
          from: Position.fromAlgebraic('d1'),
          to: Position.fromAlgebraic('d4'),
          moving: Queen(Team.white),
        );

        final result = checkDetector.detectCheckAfterMove(move);

        // Assert
        expect(result, equals(Check.none));
      });

      test(
        'should return Check.check when king is in check but not checkmate',
        () {
          // Setup: Simple check scenario
          final customPieces = {
            Position.fromAlgebraic('e1'): King(Team.white),
            Position.fromAlgebraic('e8'): King(Team.black),
            Position.fromAlgebraic('d1'): Queen(Team.white),
            Position.fromAlgebraic('a8'): Rook(
              Team.black,
            ), // Black has escape moves
          };
          boardState = BoardState.custom(customPieces);
          checkDetector = CheckDetector(boardState);

          // Act: Move white queen to attack black king
          final move = QueenMove(
            from: Position.fromAlgebraic('d1'),
            to: Position.fromAlgebraic('d8'),
            moving: Queen(Team.white),
          );

          final result = checkDetector.detectCheckAfterMove(move);

          // Assert
          expect(result, equals(Check.check));
        },
      );

      test('should return Check.checkmate when king is in checkmate', () {
        // Setup: Back rank mate scenario
        final customPieces = {
          Position.fromAlgebraic('g1'): King(Team.white),
          Position.fromAlgebraic('g8'): King(Team.black),
          Position.fromAlgebraic('f7'): Pawn(Team.black),
          Position.fromAlgebraic('g7'): Pawn(Team.black),
          Position.fromAlgebraic('h7'): Pawn(Team.black),
          Position.fromAlgebraic('d1'): Queen(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Move white queen to deliver checkmate
        final move = QueenMove(
          from: Position.fromAlgebraic('d1'),
          to: Position.fromAlgebraic('d8'),
          moving: Queen(Team.white),
        );

        final result = checkDetector.detectCheckAfterMove(move);

        // Assert
        expect(result, equals(Check.checkmate));
      });

      test('should handle rook giving check', () {
        // Setup: Rook check scenario
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('a1'): Rook(Team.white),
          Position.fromAlgebraic('d8'): Queen(Team.black), // Black can escape
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Move white rook to attack black king
        final move = RookMove(
          from: Position.fromAlgebraic('a1'),
          to: Position.fromAlgebraic('a8'),
          moving: Rook(Team.white),
        );

        final result = checkDetector.detectCheckAfterMove(move);

        // Assert
        expect(result, equals(Check.check));
      });

      test('should handle bishop giving check', () {
        // Setup: Bishop check scenario
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('c1'): Bishop(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Move white bishop to attack black king on diagonal
        final move = BishopMove(
          from: Position.fromAlgebraic('c1'),
          to: Position.fromAlgebraic('a3'),
          moving: Bishop(Team.white),
        );

        final result = checkDetector.detectCheckAfterMove(move);

        // Assert: No check since bishop on a3 doesn't attack e8
        expect(result, equals(Check.none));
      });

      test('should handle knight giving check', () {
        // Setup: Knight check scenario
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('b1'): Knight(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Move white knight to attack black king
        final move = KnightMove(
          from: Position.fromAlgebraic('b1'),
          to: Position.fromAlgebraic('d7'),
          moving: Knight(Team.white),
        );

        final result = checkDetector.detectCheckAfterMove(move);

        // Assert
        expect(result, equals(Check.check));
      });

      test('should handle pawn giving check', () {
        // Setup: Pawn check scenario
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d6'): Pawn(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Move white pawn to attack black king
        final move = PawnMove(
          from: Position.fromAlgebraic('d6'),
          to: Position.fromAlgebraic('d7'),
          moving: Pawn(Team.white),
        );

        final result = checkDetector.detectCheckAfterMove(move);

        // Assert
        expect(result, equals(Check.check));
      });

      test('should handle discovered check', () {
        // Setup: Discovered check scenario
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('e4'): Bishop(Team.white), // Blocking piece
          Position.fromAlgebraic('e2'): Queen(
            Team.white,
          ), // Behind blocking piece
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Move bishop away to discover check from queen
        final move = BishopMove(
          from: Position.fromAlgebraic('e4'),
          to: Position.fromAlgebraic('d3'),
          moving: Bishop(Team.white),
        );

        final result = checkDetector.detectCheckAfterMove(move);

        // Assert
        expect(result, equals(Check.check));
      });

      test('should correctly restore board state after check detection', () {
        // Setup: Initial position
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d1'): Queen(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Store initial state
        final initialQueenPosition =
            boardState[Position.fromAlgebraic('d1')].piece;
        final initialTargetSquare =
            boardState[Position.fromAlgebraic('d4')].piece;

        // Act: Detect check for a move
        final move = QueenMove(
          from: Position.fromAlgebraic('d1'),
          to: Position.fromAlgebraic('d4'),
          moving: Queen(Team.white),
        );

        checkDetector.detectCheckAfterMove(move);

        // Assert: Board state should be restored
        expect(
          boardState[Position.fromAlgebraic('d1')].piece,
          equals(initialQueenPosition),
        );
        expect(
          boardState[Position.fromAlgebraic('d4')].piece,
          equals(initialTargetSquare),
        );
      });

      test('should handle capture moves in check detection', () {
        // Setup: Capture scenario
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d1'): Queen(Team.white),
          Position.fromAlgebraic('d8'): Queen(Team.black),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Capture black queen and give check
        final move = QueenCaptureMove(
          from: Position.fromAlgebraic('d1'),
          to: Position.fromAlgebraic('d8'),
          moving: Queen(Team.white),
          captured: Queen(Team.black),
        );

        final result = checkDetector.detectCheckAfterMove(move);

        // Assert
        expect(result, equals(Check.check));
      });

      test('should handle moves that block check', () {
        // Setup: King in check, piece can block
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d8'): Queen(Team.white), // Giving check
          Position.fromAlgebraic('f7'): Bishop(Team.black), // Can block
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Move piece to block the check
        final move = BishopMove(
          from: Position.fromAlgebraic('f7'),
          to: Position.fromAlgebraic('e6'),
          moving: Bishop(Team.black),
        );

        final result = checkDetector.detectCheckAfterMove(move);

        // Assert: This move should not result in check for white
        expect(result, equals(Check.none));
      });
    });

    group('edge cases', () {
      test('should handle empty board gracefully', () {
        // Setup: Completely empty board
        boardState = BoardState.clear();
        checkDetector = CheckDetector(boardState);

        // This shouldn't happen in a real game, but test robustness
        final move = PawnMove(
          from: Position.fromAlgebraic('e2'),
          to: Position.fromAlgebraic('e4'),
          moving: Pawn(Team.white),
        );

        expect(
          () => checkDetector.detectCheckAfterMove(move),
          throwsArgumentError,
        );
      });

      test('should handle king-only positions', () {
        // Setup: Only kings on the board
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Try to move king (no check possible)
        final move = KingMove(
          from: Position.fromAlgebraic('e1'),
          to: Position.fromAlgebraic('f1'),
          moving: King(Team.white),
        );

        final result = checkDetector.detectCheckAfterMove(move);

        // Assert
        expect(result, equals(Check.none));
      });

      test('should handle complex checkmate scenarios', () {
        // Setup: Scholar's mate final position
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d1'): Queen(Team.white),
          Position.fromAlgebraic('c4'): Bishop(Team.white),
          Position.fromAlgebraic('f7'): Pawn(Team.black),
          Position.fromAlgebraic('g7'): Pawn(Team.black),
          Position.fromAlgebraic('h7'): Pawn(Team.black),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Deliver scholar's mate
        final move = QueenMove(
          from: Position.fromAlgebraic('d1'),
          to: Position.fromAlgebraic('f7'),
          moving: Queen(Team.white),
        );

        final result = checkDetector.detectCheckAfterMove(move);

        // Assert: This should be checkmate
        expect(result, equals(Check.checkmate));
      });
    });

    group('performance and correctness', () {
      test('should handle multiple consecutive check detections', () {
        // Setup: Standard starting position with some moves
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d1'): Queen(Team.white),
          Position.fromAlgebraic('d8'): Queen(Team.black),
          Position.fromAlgebraic('a1'): Rook(Team.white),
          Position.fromAlgebraic('a8'): Rook(Team.black),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Act: Test multiple moves
        final moves = <Move>[
          QueenMove(
            from: Position.fromAlgebraic('d1'),
            to: Position.fromAlgebraic('d4'),
            moving: Queen(Team.white),
          ),
          RookMove(
            from: Position.fromAlgebraic('a1'),
            to: Position.fromAlgebraic('a4'),
            moving: Rook(Team.white),
          ),
          QueenMove(
            from: Position.fromAlgebraic('d1'),
            to: Position.fromAlgebraic('h5'),
            moving: Queen(Team.white),
          ),
        ];

        // Assert: All should complete without errors
        for (final move in moves) {
          final result = checkDetector.detectCheckAfterMove(move);
          expect(result, isA<Check>());
        }
      });

      test('should maintain board integrity across multiple detections', () {
        // Setup
        final customPieces = {
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d1'): Queen(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = CheckDetector(boardState);

        // Store original state
        final originalBoard = <Position, Piece?>{};
        for (final square in boardState.squares) {
          originalBoard[square.position] = square.piece;
        }

        // Act: Perform multiple check detections
        final move = QueenMove(
          from: Position.fromAlgebraic('d1'),
          to: Position.fromAlgebraic('d4'),
          moving: Queen(Team.white),
        );

        // Run detection multiple times
        for (int i = 0; i < 5; i++) {
          checkDetector.detectCheckAfterMove(move);
        }

        // Assert: Board should be unchanged
        for (final entry in originalBoard.entries) {
          expect(boardState[entry.key].piece, equals(entry.value));
        }
      });
    });
  });
}
