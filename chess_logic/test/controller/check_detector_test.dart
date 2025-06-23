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
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move queen to a safe position
        final move = QueenMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen.white,
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, isEmpty);
      });
      test(
        'should return check status when king is in check but not checkmate',
        () {
          // Setup: Simple check scenario
          boardState = BoardState.custom({
            Position.e1: King.white,
            Position.e8: King.black,
            Position.d1: Queen.white,
            Position.a8: Rook.black, // Black has escape moves
          });
          checkDetector = MovementManager(
            boardState,
            const [],
            Team.values,
          ).checkDetector;

          // Act: Move white queen to attack black king
          final move = QueenMove(
            from: Position.d1,
            to: Position.d8,
            moving: Queen.white,
          );

          final result = checkDetector.moveWouldCreateCheck(move);

          // Assert
          expect(result, containsPair(Team.black, Check.check));
          expect(result[Team.white], isNull); // White is not in check
        },
      );
      test('should return checkmate status when king is in checkmate', () {
        // Setup: Back rank mate scenario
        boardState = BoardState.custom({
          Position.g1: King.white,
          Position.g8: King.black,
          Position.f7: Pawn.black,
          Position.g7: Pawn.black,
          Position.h7: Pawn.black,
          Position.d1: Queen.white,
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move white queen to deliver checkmate
        final move = QueenMove(
          from: Position.d1,
          to: Position.d8,
          moving: Queen.white,
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.checkmate));
        expect(result[Team.white], isNull); // White is not in check
      });
      test('should handle rook giving check', () {
        // Setup: Rook check scenario
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.a1: Rook.white,
          Position.d7: Queen.black,
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move white rook to attack black king
        final move = RookMove(
          from: Position.a1,
          to: Position.a8,
          moving: Rook.white,
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.check));
      });
      test('should handle bishop giving check', () {
        // Setup: Bishop check scenario
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.c1: Bishop.white,
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move white bishop to attack black king on diagonal
        final move = BishopMove(
          from: Position.c1,
          to: Position.a3,
          moving: Bishop.white,
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert: No check since bishop on a3 doesn't attack e8
        expect(result, isEmpty);
      });
      test('should handle knight giving check', () {
        // Setup: Knight check scenario
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.e6: Knight.white,
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move white knight to attack black king
        final move = KnightMove(
          from: Position.e6,
          to: Position.c7,
          moving: Knight.white,
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.check));
      });
      test('should handle pawn giving check', () {
        // Setup: Pawn check scenario
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d6: Pawn.white,
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move white pawn to attack black king
        final move = PawnMove(
          from: Position.d6,
          to: Position.d7,
          moving: Pawn.white,
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.check));
      });
      test('should handle discovered check', () {
        // Setup: Discovered check scenario
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.e4: Bishop.white, // Blocking piece
          Position.e2: Queen.white, // Behind blocking piece
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move bishop away to discover check from queen
        final move = BishopMove(
          from: Position.e4,
          to: Position.d3,
          moving: Bishop.white,
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.check));
      });
      test('should correctly restore board state after check detection', () {
        // Setup: Initial position
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Store initial state
        final initialQueenPosition = boardState[Position.d1].piece;
        final initialTargetSquare = boardState[Position.d4].piece;

        // Act: Detect check for a move
        final move = QueenMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen.white,
        );

        checkDetector.moveWouldCreateCheck(move);

        // Assert: Board state should be restored
        expect(boardState[Position.d1].piece, equals(initialQueenPosition));
        expect(boardState[Position.d4].piece, equals(initialTargetSquare));
      });
      test('should handle capture moves in check detection', () {
        // Setup: Capture scenario
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
          Position.d8: Queen.black,
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Capture black queen and give check
        final move = QueenCaptureMove(
          from: Position.d1,
          to: Position.d8,
          moving: Queen.white,
          captured: Queen.black,
        );

        final result = checkDetector.moveWouldCreateCheck(move);

        // Assert
        expect(result, containsPair(Team.black, Check.check));
      });
      test('should handle moves that block check', () {
        // Setup: King in check, piece can block
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.h8: Queen.white, // Giving check
          Position.e7: Bishop.black, // Can block
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Move piece to block the check
        final move = BishopMove(
          from: Position.e7,
          to: Position.f8,
          moving: Bishop.black,
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
          moving: Pawn.white,
        );

        expect(
          () => checkDetector.moveWouldCreateCheck(move),
          throwsArgumentError,
        );
      });
      test('should handle king-only positions', () {
        // Setup: Only kings on the board
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Try to move king (no check possible)
        final move = KingMove(
          from: Position.e1,
          to: Position.f1,
          moving: King.white,
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
            moving: Pawn.white,
          ),
          PawnInitialMove(
            from: Position.e7,
            to: Position.e5,
            moving: Pawn.black,
          ),
          BishopMove(from: Position.f1, to: Position.c4, moving: Bishop.white),
          KnightMove(from: Position.b8, to: Position.c6, moving: Knight.black),
          QueenMove(from: Position.d1, to: Position.h5, moving: Queen.white),
          KnightMove(from: Position.g8, to: Position.f6, moving: Knight.black),
        ];

        checkDetector = MovementManager(
          boardState,
          scholarsMateSequence,
          Team.values,
        ).checkDetector;

        // Act: Deliver scholar's mate
        final checkmateMove = QueenCaptureMove(
          from: Position.h5,
          to: Position.f7,
          moving: Queen.white,
          captured: Pawn.black,
        );

        final result = checkDetector.moveWouldCreateCheck(checkmateMove);

        // Assert: This should be checkmate
        expect(result, containsPair(Team.black, Check.checkmate));
      });
    });

    group('performance and correctness', () {
      test('should handle multiple consecutive check detections', () {
        // Setup: Standard starting position with some moves
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
          Position.d8: Queen.black,
          Position.a1: Rook.white,
          Position.a8: Rook.black,
        });
        checkDetector = MovementManager(
          boardState,
          const [],
          Team.values,
        ).checkDetector;

        // Act: Test multiple moves
        final moves = <Move>[
          QueenMove(from: Position.d1, to: Position.d4, moving: Queen.white),
          RookMove(from: Position.a1, to: Position.a4, moving: Rook.white),
          QueenMove(from: Position.d1, to: Position.h5, moving: Queen.white),
        ];

        // Assert: All should complete without errors
        for (final move in moves) {
          final result = checkDetector.moveWouldCreateCheck(move);
          expect(result, isA<Map<Team, Check>>());
        }
      });
      test('should maintain board integrity across multiple detections', () {
        // Setup
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
        });
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
          moving: Queen.white,
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
        boardState = BoardState.custom({
          // White pieces
          Position.e4: King.white,
          Position.e5: Pawn.white,

          // Black pieces
          Position.d8: Rook.black,
          Position.h6: Bishop.black,
          Position.g6: Pawn.black,
          // This pawn will move two squares
          Position.f7: Pawn.black,
          Position.g4: Pawn.black,
          Position.d3: Pawn.black,
          // Black king (required)
          Position.a8: King.black,
        });
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
            moving: Pawn.black,
          ),
        );

        // Assert: Black pawn move should not result in checkmate but only check
        expect(result, containsPair(Team.white, Check.check));
      });
    });
  });
}
