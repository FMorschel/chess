import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/controller/game_rule_engine.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('GameRuleEngine', () {
    late GameRuleEngine ruleEngine;

    setUp(() {
      ruleEngine = const GameRuleEngine();
    });

    group('isFiftyMoveRule', () {
      test('should return false for moves less than 50-move rule', () {
        final teams = [Team.white, Team.black];
        const halfmoveClock = 99; // Less than 100 (50 moves * 2 teams)

        final result = ruleEngine.isFiftyMoveRule(halfmoveClock, teams);

        expect(result, isFalse);
      });

      test('should return true when 50-move rule is reached', () {
        final teams = [Team.white, Team.black];
        const halfmoveClock = 100; // Exactly 50 moves * 2 teams

        final result = ruleEngine.isFiftyMoveRule(halfmoveClock, teams);

        expect(result, isTrue);
      });

      test('should return true when 50-move rule is exceeded', () {
        final teams = [Team.white, Team.black];
        const halfmoveClock = 150; // More than 50 moves * 2 teams

        final result = ruleEngine.isFiftyMoveRule(halfmoveClock, teams);

        expect(result, isTrue);
      });
      test('should work with multiple teams', () {
        final teams = [Team.white, Team.black]; // Using only valid teams
        const halfmoveClock = 100; // 50 moves * 2 teams = 100

        final result = ruleEngine.isFiftyMoveRule(halfmoveClock, teams);

        expect(result, isTrue);
      });
    });

    group('hasInsufficientMaterial', () {
      test('should return true for King vs King', () {
        final boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
        });

        final result = ruleEngine.hasInsufficientMaterial(boardState);

        expect(result, isTrue);
      });

      test('should return false for King + Queen vs King', () {
        final boardState = BoardState.custom({
          Position.e1: King.white,
          Position.d1: Queen.white,
          Position.e8: King.black,
        });

        final result = ruleEngine.hasInsufficientMaterial(boardState);

        expect(result, isFalse);
      });

      test('should return true for King vs King + Bishop', () {
        final boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.f8: Bishop.black,
        });

        final result = ruleEngine.hasInsufficientMaterial(boardState);

        expect(result, isTrue);
      });

      test('should return true for King vs King + Knight', () {
        final boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
          Position.g8: Knight.black,
        });

        final result = ruleEngine.hasInsufficientMaterial(boardState);

        expect(result, isTrue);
      });

      test('should return true for King + Bishop vs King + Bishop (same color '
          'squares)', () {
        final boardState = BoardState.custom({
          Position.e1: King.white,
          Position.f1: Bishop.white, // Light square
          Position.e8: King.black,
          Position.c8: Bishop.black, // Light square
        });

        final result = ruleEngine.hasInsufficientMaterial(boardState);

        expect(result, isTrue);
      });

      test('should return false for King + Bishop vs King + Bishop (different '
          'color squares)', () {
        final boardState = BoardState.custom({
          Position.e1: King.white,
          Position.f1: Bishop.white, // Light square
          Position.e8: King.black,
          Position.f8: Bishop.black, // Dark square
        });

        final result = ruleEngine.hasInsufficientMaterial(boardState);

        expect(result, isFalse);
      });

      test('should return false when there are pawns', () {
        final boardState = BoardState.custom({
          Position.e1: King.white,
          Position.e2: Pawn.white,
          Position.e8: King.black,
        });

        final result = ruleEngine.hasInsufficientMaterial(boardState);

        expect(result, isFalse);
      });

      test('should return false when there are rooks', () {
        final boardState = BoardState.custom({
          Position.e1: King.white,
          Position.a1: Rook.white,
          Position.e8: King.black,
        });

        final result = ruleEngine.hasInsufficientMaterial(boardState);

        expect(result, isFalse);
      });
    });

    group('isStalemate', () {
      test('should return true when no moves available and not in check', () {
        final possibleMoves = <Move>[];
        const isInCheck = false;

        final result = ruleEngine.isStalemate(
          possibleMoves,
          isInCheck: isInCheck,
        );

        expect(result, isTrue);
      });

      test('should return false when no moves available but in check', () {
        final possibleMoves = <Move>[];
        const isInCheck = true;

        final result = ruleEngine.isStalemate(
          possibleMoves,
          isInCheck: isInCheck,
        );

        expect(result, isFalse);
      });
      test('should return false when moves are available', () {
        final possibleMoves = [
          Move.create(from: Position.e2, to: Position.e3, moving: Pawn.white),
        ];
        const isInCheck = false;

        final result = ruleEngine.isStalemate(
          possibleMoves,
          isInCheck: isInCheck,
        );

        expect(result, isFalse);
      });
    });

    group('isCheckmate', () {
      test('should return true when no moves available and in check', () {
        final possibleMoves = <Move>[];
        const isInCheck = true;

        final result = ruleEngine.isCheckmate(
          possibleMoves,
          isInCheck: isInCheck,
        );

        expect(result, isTrue);
      });

      test('should return false when no moves available but not in check', () {
        final possibleMoves = <Move>[];
        const isInCheck = false;

        final result = ruleEngine.isCheckmate(
          possibleMoves,
          isInCheck: isInCheck,
        );

        expect(result, isFalse);
      });

      test('should return false when moves are available even if in check', () {
        final possibleMoves = [
          Move.create(from: Position.e1, to: Position.f1, moving: King.white),
        ];
        const isInCheck = true;

        final result = ruleEngine.isCheckmate(
          possibleMoves,
          isInCheck: isInCheck,
        );

        expect(result, isFalse);
      });
    });

    group('isEnPassantLegal', () {
      test('should return false when last move was not a pawn move', () {
        const capturingPawn = Pawn.white;
        const capturePosition = Position.d6;
        final lastMove = Move.create(
          from: Position.e1,
          to: Position.f1,
          moving: King.black,
        );
        final boardState = BoardState.custom({
          Position.c5: capturingPawn,
          Position.d5: Pawn.black,
        });

        final result = ruleEngine.isEnPassantLegal(
          capturingPawn,
          capturePosition,
          lastMove,
          boardState,
        );

        expect(result, isFalse);
      });

      test('should return false when last pawn move was not a double move', () {
        const capturingPawn = Pawn.white;
        const capturePosition = Position.d6;
        final lastMove = PawnMove(
          from: Position.d6,
          to: Position.d5,
          moving: Pawn.black,
        );
        final boardState = BoardState.custom({
          Position.c5: capturingPawn,
          Position.d5: Pawn.black,
        });

        final result = ruleEngine.isEnPassantLegal(
          capturingPawn,
          capturePosition,
          lastMove,
          boardState,
        );

        expect(result, isFalse);
      });
      test('should return true for valid en passant scenario', () {
        const capturingPawn = Pawn.white;
        const capturePosition = Position.d6;
        final lastMove = PawnMove.initial(
          pawn: Pawn.black,
          from: Position.d7,
          to: Position.d5,
        );
        final boardState = BoardState.custom({
          Position.c5: capturingPawn,
          Position.d5: Pawn.black,
        });

        final result = ruleEngine.isEnPassantLegal(
          capturingPawn,
          capturePosition,
          lastMove,
          boardState,
        );

        expect(result, isTrue);
      });
      test('should return false when capturing pawn is on wrong rank', () {
        const capturingPawn = Pawn.white;
        const capturePosition = Position.d6;
        final lastMove = PawnMove.initial(
          pawn: Pawn.black,
          from: Position.d7,
          to: Position.d5,
        );
        final boardState = BoardState.custom({
          Position.c4: capturingPawn, // Wrong rank for white pawn
          Position.d5: Pawn.black,
        });

        final result = ruleEngine.isEnPassantLegal(
          capturingPawn,
          capturePosition,
          lastMove,
          boardState,
        );

        expect(result, isFalse);
      });

      test('should return false when pawns are not adjacent', () {
        const capturingPawn = Pawn.white;
        const capturePosition = Position.d6;
        final lastMove = PawnMove.initial(
          pawn: Pawn.black,
          from: Position.d7,
          to: Position.d5,
        );
        final boardState = BoardState.custom({
          Position.a5: capturingPawn, // Not adjacent to d5
          Position.d5: Pawn.black,
        });

        final result = ruleEngine.isEnPassantLegal(
          capturingPawn,
          capturePosition,
          lastMove,
          boardState,
        );

        expect(result, isFalse);
      });

      test('should return false when capturing own team pawn', () {
        const capturingPawn = Pawn.white;
        const capturePosition = Position.d6;
        final lastMove = PawnMove.initial(
          pawn: Pawn.white, // Same team as capturing pawn
          from: Position.d2,
          to: Position.d4,
        );
        final boardState = BoardState.custom({
          Position.c5: capturingPawn,
          Position.d5: Pawn.white,
        });

        final result = ruleEngine.isEnPassantLegal(
          capturingPawn,
          capturePosition,
          lastMove,
          boardState,
        );

        expect(result, isFalse);
      });
    });

    group('isPawnPromotionRequired', () {
      test('should return true for white pawn reaching 8th rank', () {
        const pawn = Pawn.white;
        const targetPosition = Position.e8;

        final result = ruleEngine.isPawnPromotionRequired(pawn, targetPosition);

        expect(result, isTrue);
      });

      test('should return true for black pawn reaching 1st rank', () {
        const pawn = Pawn.black;
        const targetPosition = Position.e1;

        final result = ruleEngine.isPawnPromotionRequired(pawn, targetPosition);

        expect(result, isTrue);
      });

      test('should return false for white pawn not reaching 8th rank', () {
        const pawn = Pawn.white;
        const targetPosition = Position.e7;

        final result = ruleEngine.isPawnPromotionRequired(pawn, targetPosition);

        expect(result, isFalse);
      });

      test('should return false for black pawn not reaching 1st rank', () {
        const pawn = Pawn.black;
        const targetPosition = Position.e2;

        final result = ruleEngine.isPawnPromotionRequired(pawn, targetPosition);

        expect(result, isFalse);
      });
    });

    group('isPromotionPieceLegal', () {
      test('should return true for queen promotion', () {
        const promotedPiece = Queen.white;
        const pawnTeam = Team.white;

        final result = ruleEngine.isPromotionPieceLegal(
          promotedPiece,
          pawnTeam,
        );

        expect(result, isTrue);
      });

      test('should return true for rook promotion', () {
        const promotedPiece = Rook.white;
        const pawnTeam = Team.white;

        final result = ruleEngine.isPromotionPieceLegal(
          promotedPiece,
          pawnTeam,
        );

        expect(result, isTrue);
      });

      test('should return true for bishop promotion', () {
        const promotedPiece = Bishop.white;
        const pawnTeam = Team.white;

        final result = ruleEngine.isPromotionPieceLegal(
          promotedPiece,
          pawnTeam,
        );

        expect(result, isTrue);
      });

      test('should return true for knight promotion', () {
        const promotedPiece = Knight.white;
        const pawnTeam = Team.white;

        final result = ruleEngine.isPromotionPieceLegal(
          promotedPiece,
          pawnTeam,
        );

        expect(result, isTrue);
      });

      test('should return false for king promotion', () {
        const promotedPiece = King.white;
        const pawnTeam = Team.white;

        final result = ruleEngine.isPromotionPieceLegal(
          promotedPiece,
          pawnTeam,
        );

        expect(result, isFalse);
      });

      test('should return false for pawn promotion', () {
        const promotedPiece = Pawn.white;
        const pawnTeam = Team.white;

        final result = ruleEngine.isPromotionPieceLegal(
          promotedPiece,
          pawnTeam,
        );

        expect(result, isFalse);
      });

      test('should return false for different team promotion', () {
        const promotedPiece = Queen.black;
        const pawnTeam = Team.white;

        final result = ruleEngine.isPromotionPieceLegal(
          promotedPiece,
          pawnTeam,
        );

        expect(result, isFalse);
      });
    });

    group('isCastlingLegal', () {
      test('should return false for different team king and rook', () {
        const king = King.white;
        const rook = Rook.black;
        const kingFrom = Position.e1;
        const kingTo = Position.g1;
        const rookFrom = Position.h1;
        final boardState = BoardState.custom({
          Position.e1: king,
          Position.h1: rook,
        });
        final moveHistory = <Move>[];
        bool isSquareAttacked(Position position, Team byTeam) => false;

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isFalse);
      });

      test('should return false when king and rook are on different ranks', () {
        const king = King.white;
        const rook = Rook.white;
        const kingFrom = Position.e1;
        const kingTo = Position.g1;
        const rookFrom = Position.h2; // Different rank
        final boardState = BoardState.custom({
          Position.e1: king,
          Position.h2: rook,
        });
        final moveHistory = <Move>[];
        bool isSquareAttacked(Position position, Team byTeam) => false;

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isFalse);
      });

      test('should return false when king has moved', () {
        const king = King.white;
        const rook = Rook.white;
        const kingFrom = Position.e1;
        const kingTo = Position.g1;
        const rookFrom = Position.h1;
        final boardState = BoardState.custom({
          Position.e1: king,
          Position.h1: rook,
        });
        final moveHistory = [
          KingMove(from: Position.e1, to: Position.e2, moving: king),
          KingMove(from: Position.e2, to: Position.e1, moving: king),
        ];
        bool isSquareAttacked(Position position, Team byTeam) => false;

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isFalse);
      });

      test('should return false when rook has moved', () {
        const king = King.white;
        const rook = Rook.white;
        const kingFrom = Position.e1;
        const kingTo = Position.g1;
        const rookFrom = Position.h1;
        final boardState = BoardState.custom({
          Position.e1: king,
          Position.h1: rook,
        });
        final moveHistory = [
          RookMove(from: Position.h1, to: Position.h2, moving: rook),
          RookMove(from: Position.h2, to: Position.h1, moving: rook),
        ];
        bool isSquareAttacked(Position position, Team byTeam) => false;

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isFalse);
      });

      test('should return false when king is in check', () {
        const king = King.white;
        const rook = Rook.white;
        const kingFrom = Position.e1;
        const kingTo = Position.g1;
        const rookFrom = Position.h1;
        final boardState = BoardState.custom({
          Position.e1: king,
          Position.h1: rook,
        });
        final moveHistory = <Move>[];
        bool isSquareAttacked(Position position, Team byTeam) {
          return position == kingFrom && byTeam == Team.black;
        }

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isFalse);
      });

      test(
        'should return false when there are pieces between king and rook',
        () {
          const king = King.white;
          const rook = Rook.white;
          const kingFrom = Position.e1;
          const kingTo = Position.g1;
          const rookFrom = Position.h1;
          final boardState = BoardState.custom({
            Position.e1: king,
            Position.f1: Bishop.white, // Piece between king and rook
            Position.h1: rook,
          });
          final moveHistory = <Move>[];
          bool isSquareAttacked(Position position, Team byTeam) => false;

          final result = ruleEngine.isCastlingLegal(
            king,
            rook,
            kingFrom,
            kingTo,
            rookFrom,
            boardState,
            moveHistory,
            isSquareAttacked,
          );

          expect(result, isFalse);
        },
      );

      test('should return false when king passes through attacked square', () {
        const king = King.white;
        const rook = Rook.white;
        const kingFrom = Position.e1;
        const kingTo = Position.g1;
        const rookFrom = Position.h1;
        final boardState = BoardState.custom({
          Position.e1: king,
          Position.h1: rook,
        });
        final moveHistory = <Move>[];
        bool isSquareAttacked(Position position, Team byTeam) {
          return position == Position.f1 &&
              byTeam == Team.black; // f1 is attacked
        }

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isFalse);
      });

      test('should return false when king lands on attacked square', () {
        const king = King.white;
        const rook = Rook.white;
        const kingFrom = Position.e1;
        const kingTo = Position.g1;
        const rookFrom = Position.h1;
        final boardState = BoardState.custom({
          Position.e1: king,
          Position.h1: rook,
        });
        final moveHistory = <Move>[];
        bool isSquareAttacked(Position position, Team byTeam) {
          return position == Position.g1 &&
              byTeam == Team.black; // g1 is attacked
        }

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isFalse);
      });

      test('should return true for valid kingside castling', () {
        const king = King.white;
        const rook = Rook.white;
        const kingFrom = Position.e1;
        const kingTo = Position.g1;
        const rookFrom = Position.h1;
        final boardState = BoardState.custom({
          Position.e1: king,
          Position.h1: rook,
        });
        final moveHistory = <Move>[];
        bool isSquareAttacked(Position position, Team byTeam) => false;

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isTrue);
      });      test('should return true for valid queenside castling', () {
        const king = King.white;
        const rook = Rook.white;
        const kingFrom = Position.e1;
        const kingTo = Position.c1;
        const rookFrom = Position.a1;
        final boardState = BoardState.custom({
          Position.e1: king,
          Position.a1: rook,
        });
        final moveHistory = <Move>[];
        bool isSquareAttacked(Position position, Team byTeam) => false;

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isTrue);
      });

      test('should return false when king is not in initial position', () {
        const king = King.white;
        const rook = Rook.white;
        const kingFrom = Position.d1; // Wrong initial position
        const kingTo = Position.f1;
        const rookFrom = Position.h1;
        final boardState = BoardState.custom({
          Position.d1: king,
          Position.h1: rook,
        });
        final moveHistory = <Move>[];
        bool isSquareAttacked(Position position, Team byTeam) => false;

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isFalse);
      });

      test('should return false when rook is not in initial position', () {
        const king = King.white;
        const rook = Rook.white;
        const kingFrom = Position.e1;
        const kingTo = Position.g1;
        const rookFrom = Position.g1; // Wrong initial position
        final boardState = BoardState.custom({
          Position.e1: king,
          Position.g1: rook,
        });
        final moveHistory = <Move>[];
        bool isSquareAttacked(Position position, Team byTeam) => false;

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isFalse);
      });

      test('should return true for valid black kingside castling', () {
        const king = King.black;
        const rook = Rook.black;
        const kingFrom = Position.e8;
        const kingTo = Position.g8;
        const rookFrom = Position.h8;
        final boardState = BoardState.custom({
          Position.e8: king,
          Position.h8: rook,
        });
        final moveHistory = <Move>[];
        bool isSquareAttacked(Position position, Team byTeam) => false;

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isTrue);
      });

      test('should return true for valid black queenside castling', () {
        const king = King.black;
        const rook = Rook.black;
        const kingFrom = Position.e8;
        const kingTo = Position.c8;
        const rookFrom = Position.a8;
        final boardState = BoardState.custom({
          Position.e8: king,
          Position.a8: rook,
        });
        final moveHistory = <Move>[];
        bool isSquareAttacked(Position position, Team byTeam) => false;

        final result = ruleEngine.isCastlingLegal(
          king,
          rook,
          kingFrom,
          kingTo,
          rookFrom,
          boardState,
          moveHistory,
          isSquareAttacked,
        );

        expect(result, isTrue);
      });
    });
  });
}
