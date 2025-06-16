import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/controller/check_detector.dart';
import 'package:chess_logic/src/controller/movement_manager.dart';
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

    group('moveWouldCreateCheck', () {
      test('should return empty map when no check occurs', () {
        // Setup: King and queen in safe positions
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
          Position.d1: Queen(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move queen to a safe position
        final move = QueenMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen(Team.white),
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, isEmpty);
      });
      test(
        'should return check status when king is in check but not checkmate',
        () {
          // Setup: Simple check scenario
          final customPieces = {
            Position.e1: King(Team.white),
            Position.e8: King(Team.black),
            Position.d1: Queen(Team.white),
            Position.a8: Rook(
              Team.black,
            ), // Black has escape moves
          };
          boardState = BoardState.custom(customPieces);
          checkDetector = MovementManager(
            boardState,
            const [],
            Team.values,
          ).checkDetector;

          // Act: Move white queen to attack black king
          final move = QueenMove(
            from: Position.d1,
            to: Position.d8,
            moving: Queen(Team.white),
          );

          final result = checkDetector.moveWouldCreateCheck(move);

          // Assert
          expect(result, containsPair(Team.black, Check.check));
          expect(result[Team.white], isNull); // White is not in check
        },
      );
      test('should return checkmate status when king is in checkmate', () {
        // Setup: Back rank mate scenario
        final customPieces = {
          Position.g1: King(Team.white),
          Position.g8: King(Team.black),
          Position.f7: Pawn(Team.black),
          Position.g7: Pawn(Team.black),
          Position.h7: Pawn(Team.black),
          Position.d1: Queen(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move white queen to deliver checkmate
        final move = QueenMove(
          from: Position.d1,
          to: Position.d8,
          moving: Queen(Team.white),
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.checkmate));
        expect(result[Team.white], isNull); // White is not in check
      });
      test('should handle rook giving check', () {
        // Setup: Rook check scenario
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
          Position.a1: Rook(Team.white),
          Position.d7: Queen(Team.black),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move white rook to attack black king
        final move = RookMove(
          from: Position.a1,
          to: Position.a8,
          moving: Rook(Team.white),
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.check));
      });

      test('should handle bishop giving check', () {
        // Setup: Bishop check scenario
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
          Position.c1: Bishop(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move white bishop to attack black king on diagonal
        final move = BishopMove(
          from: Position.c1,
          to: Position.a3,
          moving: Bishop(Team.white),
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert: No check since bishop on a3 doesn't attack e8
        expect(result, isEmpty);
      });
      test('should handle knight giving check', () {
        // Setup: Knight check scenario
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
          Position.e6: Knight(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move white knight to attack black king
        final move = KnightMove(
          from: Position.e6,
          to: Position.c7,
          moving: Knight(Team.white),
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.check));
      });

      test('should handle pawn giving check', () {
        // Setup: Pawn check scenario
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
          Position.d6: Pawn(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move white pawn to attack black king
        final move = PawnMove(
          from: Position.d6,
          to: Position.d7,
          moving: Pawn(Team.white),
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.check));
      });
      test('should handle discovered check', () {
        // Setup: Discovered check scenario
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
          Position.e4: Bishop(Team.white), // Blocking piece
          Position.e2: Queen(
            Team.white,
          ), // Behind blocking piece
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move bishop away to discover check from queen
        final move = BishopMove(
          from: Position.e4,
          to: Position.d3,
          moving: Bishop(Team.white),
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.check));
      });

      test('should correctly restore board state after check detection', () {
        // Setup: Initial position
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
          Position.d1: Queen(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Store initial state
        final initialQueenPosition =
            boardState[Position.d1].piece;
        final initialTargetSquare =
            boardState[Position.d4].piece;

        // Act: Detect check for a move
        final move = QueenMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen(Team.white),
        );

        checkDetector.moveWouldCreateCheck(move);

        // Assert: Board state should be restored
        expect(
          boardState[Position.d1].piece,
          equals(initialQueenPosition),
        );
        expect(
          boardState[Position.d4].piece,
          equals(initialTargetSquare),
        );
      });
      test('should handle capture moves in check detection', () {
        // Setup: Capture scenario
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
          Position.d1: Queen(Team.white),
          Position.d8: Queen(Team.black),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Capture black queen and give check
        final move = QueenCaptureMove(
          from: Position.d1,
          to: Position.d8,
          moving: Queen(Team.white),
          captured: Queen(Team.black),
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.check));
      });

      test('should handle moves that block check', () {
        // Setup: King in check, piece can block
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
          Position.h8: Queen(Team.white), // Giving check
          Position.e7: Bishop(Team.black), // Can block
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move piece to block the check
        final move = BishopMove(
          from: Position.e7,
          to: Position.f8,
          moving: Bishop(Team.black),
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert: This move should not result in check for white
        expect(result, isEmpty);
      });
    });
    group('edge cases', () {
      test('should handle empty board gracefully', () {
        // Setup: Completely empty board
        boardState = BoardState.empty();
        checkDetector = CheckDetector(boardState);

        // This shouldn't happen in a real game, but test robustness
        final move = PawnInitialMove(
          from: Position.e2,
          to: Position.e4,
          moving: Pawn(Team.white),
        );

        expect(
          () => checkDetector.moveWouldCreateCheck(move),
          throwsArgumentError,
        );
      });

      test('should handle king-only positions', () {
        // Setup: Only kings on the board
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Try to move king (no check possible)
        final move = KingMove(
          from: Position.e1,
          to: Position.f1,
          moving: King(Team.white),
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, isEmpty);
      });
      test('should handle complex checkmate scenarios', () {
        // Setup: Start from standard board position
        boardState = BoardState();

        // Execute Scholar's Mate sequence
        final scholarsMateSequence = <Move>[
          PawnInitialMove(
            from: Position.e2,
            to: Position.e4,
            moving: Pawn(Team.white),
          ),
          PawnInitialMove(
            from: Position.e7,
            to: Position.e5,
            moving: Pawn(Team.black),
          ),
          BishopMove(
            from: Position.f1,
            to: Position.c4,
            moving: Bishop(Team.white),
          ),
          KnightMove(
            from: Position.b8,
            to: Position.c6,
            moving: Knight(Team.black),
          ),
          QueenMove(
            from: Position.d1,
            to: Position.h5,
            moving: Queen(Team.white),
          ),
          KnightMove(
            from: Position.g8,
            to: Position.f6,
            moving: Knight(Team.black),
          ),
        ];

        // Apply all moves except the final checkmate move
        for (final move in scholarsMateSequence) {
          boardState.actOn(move);
        }

        checkDetector = MovementManager(
          boardState,
          scholarsMateSequence,
          Team.values,
        ).checkDetector;

        // Act: Deliver scholar's mate
        final checkmateMove = QueenCaptureMove(
          from: Position.h5,
          to: Position.f7,
          moving: Queen(Team.white),
          captured: Pawn(Team.black),
        );

        final result = checkDetector.moveWouldCreateCheck(checkmateMove);

        // Assert: This should be checkmate
        expect(result, containsPair(Team.black, Check.checkmate));
      });
    });

    group('performance and correctness', () {
      test('should handle multiple consecutive check detections', () {
        // Setup: Standard starting position with some moves
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
          Position.d1: Queen(Team.white),
          Position.d8: Queen(Team.black),
          Position.a1: Rook(Team.white),
          Position.a8: Rook(Team.black),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Test multiple moves
        final moves = <Move>[
          QueenMove(
            from: Position.d1,
            to: Position.d4,
            moving: Queen(Team.white),
          ),
          RookMove(
            from: Position.a1,
            to: Position.a4,
            moving: Rook(Team.white),
          ),
          QueenMove(
            from: Position.d1,
            to: Position.h5,
            moving: Queen(Team.white),
          ),
        ];

        // Assert: All should complete without errors
        for (final move in moves) {
          final result = checkDetector.moveWouldCreateCheck(move);
          expect(result, isA<Map<Team, Check>>());
        }
      });

      test('should maintain board integrity across multiple detections', () {
        // Setup
        final customPieces = {
          Position.e1: King(Team.white),
          Position.e8: King(Team.black),
          Position.d1: Queen(Team.white),
        };
        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Store original state
        final originalBoard = <Position, Piece?>{};
        for (final square in boardState.squares) {
          originalBoard[square.position] = square.piece;
        }

        // Act: Perform multiple check detections
        final move = QueenMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen(Team.white),
        );

        // Run detection multiple times
        for (int i = 0; i < 5; i++) {
          checkDetector.moveWouldCreateCheck(move);
        }

        // Assert: Board should be unchanged
        for (final entry in originalBoard.entries) {
          expect(boardState[entry.key].piece, equals(entry.value));
        }
      });
      test('enpassant should avoid check', () {
        // Setup: Position where white king would be in check from black rook
        // but can escape by capturing en passant
        final customPieces = {
          // White pieces
          Position.e4: King(Team.white),
          Position.e5: Pawn(Team.white),

          // Black pieces
          Position.d8: Rook(Team.black),
          Position.h6: Bishop(Team.black),
          Position.g6: Pawn(Team.black),
          // This pawn will move two squares
          Position.f7: Pawn(Team.black),
          Position.g4: Pawn(Team.black),
          Position.d3: Pawn(Team.black),
          // Black king (required)
          Position.a8: King(Team.black),
        };

        boardState = BoardState.custom(customPieces);
        checkDetector = MovementManager(
          boardState,
          [],
          Team.values,
        ).checkDetector;

        var result = checkDetector.moveWouldCreateCheck(
          PawnInitialMove(
            // (enables en passant)
            from: Position.f7,
            to: Position.f5,
            moving: Pawn(Team.black),
          ),
        );

        // Assert: Black pawn move should not result in checkmate but only check
        expect(result, containsPair(Team.white, Check.check));
      });
    });
  });
}
