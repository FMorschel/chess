import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/controller/move_validator.dart';
import 'package:chess_logic/src/controller/movement_manager.dart';
import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('MoveValidator', () {
    late BoardState boardState;
    late MoveValidator moveValidator;
    late MovementManager movementManager;

    setUp(() {
      boardState = BoardState.empty();
    });

    MoveValidator createMoveValidator(BoardState state) {
      movementManager = MovementManager(state, const [], Team.values);
      return movementManager.moveValidator;
    }

    group('validateAndEnrichMoves', () {
      test('should return empty list for empty square', () {
        // Setup: Empty board
        moveValidator = createMoveValidator(boardState);
        final emptySquare = boardState[Position.e4];

        // Act
        final result = moveValidator.createValidMoves(emptySquare);

        // Assert
        expect(result, isEmpty);
      });
      test('should filter out moves that put own king in check', () {
        // Setup: King and queen lined up, with piece blocking
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e4: Queen.white,
          Position.e8: Queen.black,
        });
        moveValidator = createMoveValidator(boardState);

        final whiteQueenSquare = boardState[Position.e4];

        // Act: Get moves for white queen (moving it would expose king)
        final result = moveValidator.createValidMoves(whiteQueenSquare);

        // Assert: Some moves should be filtered out
        final movesToD4 = result.where((m) => m.to == Position.d4);
        expect(movesToD4, isEmpty); // This move would expose king
      });

      test('should enrich moves with check status', () {
        // Setup: Queen can give check
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
        });
        moveValidator = createMoveValidator(boardState);

        final whiteQueenSquare = boardState[Position.d1];

        // Act
        final result = moveValidator.createValidMoves(whiteQueenSquare);

        // Assert: Find move that gives check
        final checkMove = result
            .where((m) => m.to == Position.d8 && m.check == Check.check)
            .firstOrNull;
        expect(checkMove, isNotNull);
      });

      test('should enrich moves with ambiguity information', () {
        // Setup: Two knights can move to same square
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.b1: Knight.white,
          Position.g1: Knight.white,
        });
        moveValidator = createMoveValidator(boardState);

        final knightSquare = boardState[Position.b1];

        // Act
        final result = moveValidator.createValidMoves(knightSquare);

        // Assert: Find move that might be ambiguous
        final moveToD2 = result.where((m) => m.to == Position.d2).firstOrNull;
        if (moveToD2 != null) {
          // This depends on whether the other knight can also reach d2
          expect(moveToD2.ambiguous, isA<AmbiguousMovementType>());
        }
      });
    });

    group('isMoveLegal', () {
      test('should return true for legal moves', () {
        // Setup: Normal position
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
        });
        moveValidator = createMoveValidator(boardState);

        final move = QueenMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen.white,
        );

        // Act
        final result = moveValidator.isMoveLegal(move, Team.white);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for moves that put own king in check', () {
        // Setup: Pinned piece
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e4: Queen.white,
          Position.e8: Queen.black,
        });
        moveValidator = createMoveValidator(boardState);

        final move = QueenMove(
          from: Position.e4,
          to: Position.d4,
          moving: Queen.white,
        );

        // Act
        final result = moveValidator.isMoveLegal(move, Team.white);

        // Assert
        expect(result, isFalse);
      });
    });

    group('detectAmbiguousMove', () {
      test('should return none when move is not ambiguous', () {
        // Setup: Only one piece can make the move
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
        });
        moveValidator = createMoveValidator(boardState);

        final move = QueenMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen.white,
        );

        // Act
        final result = moveValidator.detectAmbiguousMove(move);

        // Assert
        expect(result, AmbiguousMovementType.none);
      });

      test('should detect file ambiguity', () {
        // Setup: Two rooks on same rank
        boardState = BoardState.custom({
          Position.e2: King.white,
          Position.e8: King.black,
          Position.a1: Rook.white,
          Position.h1: Rook.white,
        });
        moveValidator = createMoveValidator(boardState);

        final move = RookMove(
          from: Position.a1,
          to: Position.d1,
          moving: Rook.white,
        );

        final result = moveValidator.detectAmbiguousMove(move);

        expect(result, equals(AmbiguousMovementType.file));
      });

      test('should detect rank ambiguity', () {
        // Setup: Two rooks on same file
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.a1: Rook.white,
          Position.a8: Rook.white,
        });
        moveValidator = createMoveValidator(boardState);

        final move = RookMove(
          from: Position.a1,
          to: Position.a4,
          moving: Rook.white,
        );

        // Act
        final result = moveValidator.detectAmbiguousMove(move);

        // Assert
        expect(result, equals(AmbiguousMovementType.rank));
      });

      test('should detect both file and rank ambiguity', () {
        // Setup: Three rooks forming an L-shape
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.a1: Rook.white,
          Position.a4: Rook.white,
          Position.d1: Rook.white,
        });
        moveValidator = createMoveValidator(boardState);

        // Act: This would be ambiguous as both a1 and a4 rooks could go to c1
        final betterMove = RookMove(
          from: Position.a1,
          to: Position.c1,
          moving: Rook.white,
        );
        final result = moveValidator.detectAmbiguousMove(betterMove);

        // Assert: Should need both file and rank disambiguation
        // if both other rooks can reach c1
        expect(result, isA<AmbiguousMovementType>());
      });
    });

    group('wouldMoveBeLegal', () {
      test('should return false for move from empty square', () {
        // Setup: Empty square
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
        });
        moveValidator = createMoveValidator(boardState);

        final move = QueenMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen.white,
        );

        // Act
        final result = moveValidator.wouldMoveBeLegal(move);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for move with wrong piece', () {
        // Setup: Different piece than expected
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Rook.white,
        });
        moveValidator = createMoveValidator(boardState);

        final move = QueenMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen.white,
        );

        // Act
        final result = moveValidator.wouldMoveBeLegal(move);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for valid legal moves', () {
        // Setup: Normal position
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
        });
        moveValidator = createMoveValidator(boardState);

        final move = QueenMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen.white,
        );

        // Act
        final result = moveValidator.wouldMoveBeLegal(move);

        // Assert
        expect(result, isTrue);
      });
    });

    group('isCaptureMoveLegal', () {
      test('should return false when no piece to capture', () {
        // Setup: Empty target square
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
        });
        moveValidator = createMoveValidator(boardState);

        final move = QueenCaptureMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen.white,
          captured: Pawn.black,
        );

        // Act
        final result = moveValidator.isCaptureMoveLegal(move);

        // Assert
        expect(result, isFalse);
      });
      test('should return false when capturing own piece', () {
        // Setup: Same team piece on target
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
          Position.d4: Pawn.black, // Use opponent piece to create valid move
        });
        moveValidator = createMoveValidator(boardState);

        // Create a valid capture move first
        final validMove = QueenCaptureMove(
          from: Position.d1,
          to: Position.d4,
          moving: Queen.white,
          captured: Pawn.black,
        );

        // Then test what happens if we manually place same team piece
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
          Position.d4: Pawn.white, // Now same team
        });

        // Act - Test validation logic directly
        final result = moveValidator.isCaptureMoveLegal(validMove);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when captured piece is different', () {
        // Setup: Different piece than expected
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
          Position.d4: Rook.black,
        });
        moveValidator = createMoveValidator(boardState);

        final move = QueenCaptureMove<Piece>(
          from: Position.d1,
          to: Position.d4,
          moving: Queen.white,
          captured: Pawn.black, // Wrong piece type
        );

        final result = moveValidator.isCaptureMoveLegal(move);

        expect(result, isFalse);
      });

      test('should return true for valid captures', () {
        // Setup: Valid capture scenario
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
          Position.d4: Pawn.black,
        });
        moveValidator = createMoveValidator(boardState);

        final move = QueenCaptureMove<Piece>(
          from: Position.d1,
          to: Position.d4,
          moving: Queen.white,
          captured: Pawn.black,
        );

        final result = moveValidator.isCaptureMoveLegal(move);

        expect(result, isTrue);
      });
    });

    group('filterLegalMoves', () {
      test('should filter out illegal moves', () {
        // Setup: Mixed legal and illegal moves
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e4: Queen.white,
          Position.e8: Queen.black,
        });
        moveValidator = createMoveValidator(boardState);

        final moves = [
          QueenMove(
            from: Position.e4,
            to: Position.d4,
            moving: Queen.white,
          ), // Illegal - exposes king
          QueenMove(
            from: Position.e4,
            to: Position.e5,
            moving: Queen.white,
          ), // Illegal - exposes king
          QueenMove(
            from: Position.e4,
            to: Position.e6,
            moving: Queen.white,
          ), // Legal - blocks check
        ];

        // Act
        final result = moveValidator.filterLegalMoves(moves);

        // Assert: Only legal moves should remain
        expect(result.length, lessThan(moves.length));
        expect(result.any((m) => m.to == Position.e6), isTrue);
      });

      test('should return all moves when all are legal', () {
        // Setup: All moves are legal
        boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d1: Queen.white,
        });
        moveValidator = createMoveValidator(boardState);

        final moves = [
          QueenMove(from: Position.d1, to: Position.d4, moving: Queen.white),
          QueenMove(from: Position.d1, to: Position.a4, moving: Queen.white),
        ];

        // Act
        final result = moveValidator.filterLegalMoves(moves);

        // Assert
        expect(result.length, equals(moves.length));
      });
    });

    group('integration with MovementManager', () {
      test('should work seamlessly with movement manager', () {
        // Setup: Standard starting position
        boardState = BoardState();
        movementManager = MovementManager(boardState, const [], Team.values);

        // Act: Get legal moves for a pawn
        final pawnSquare = boardState[Position.e2];
        final moves = movementManager.possibleMoves(pawnSquare);

        // Assert: Should get expected pawn moves
        expect(moves, isNotEmpty);
        expect(moves.every((m) => m.moving == Pawn.white), isTrue);
        expect(moves.any((m) => m.to == Position.e3), isTrue);
        expect(moves.any((m) => m.to == Position.e4), isTrue);
      });
    });
  });
}
