import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/controller/threat_detector.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('ThreatDetector', () {
    late BoardState boardState;
    late ThreatDetector threatDetector;
    // Define piece instances once for all tests
    final whiteKing = King(Team.white);
    final whiteQueen = Queen(Team.white);
    final whiteKnight = Knight(Team.white);
    final whitePawn = Pawn(Team.white);

    final blackQueen = Queen(Team.black);
    final blackRook = Rook(Team.black);
    final blackKnight = Knight(
      Team.black,
    ); // Define position instances once for all tests
    final a1 = Position.a1;
    final a2 = Position.a2;
    final a3 = Position.a3;
    final a4 = Position.a4;
    final b3 = Position.b3;
    final c2 = Position.c2;
    final c6 = Position.c6;
    final d1 = Position.d1;
    final d2 = Position.d2;
    final d3 = Position.d3;
    final d4 = Position.d4;
    final d5 = Position.d5;
    final d8 = Position.d8;
    final e1 = Position.e1;
    final e2 = Position.e2;
    final e3 = Position.e3;
    final e4 = Position.e4;
    final e6 = Position.e6;
    final e8 = Position.e8;
    final f5 = Position.f5;
    final g7 = Position.g7;
    final h1 = Position.h1;
    final h2 = Position.h2;
    final h3 = Position.h3;
    final h4 = Position.h4;
    final h7 = Position.h7;
    final h8 = Position.h8;

    setUp(() {
      boardState = BoardState.empty();
      threatDetector = ThreatDetector(boardState);
    });
    group('isPieceUnderThreat', () {
      test('should return true when piece is under attack', () {
        // Setup: White king under attack by black queen
        final customPieces = {e1: whiteKing, e8: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final whiteKingOnBoard = boardState[e1];

        expect(threatDetector.isPieceUnderThreat(whiteKingOnBoard), isTrue);
      });

      test('should return false when piece is safe', () {
        // Setup: White king safe from black queen
        final customPieces = {a1: whiteKing, h7: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);
        final whiteKingOnBoard = boardState[a1];

        expect(threatDetector.isPieceUnderThreat(whiteKingOnBoard), isFalse);
      });

      test('should return false when attacked by same team piece', () {
        // Setup: White king "attacked" by white queen (same team)
        final customPieces = {e1: whiteKing, e8: whiteQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final whiteKingOnBoard = boardState[e1];

        expect(threatDetector.isPieceUnderThreat(whiteKingOnBoard), isFalse);
      });
    });
    group('isPositionUnderAttackFor', () {
      test('should return true when position is under attack by opponent', () {
        // Setup: Black queen attacking e1
        final customPieces = {e8: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        expect(threatDetector.isPositionUnderAttackFor(e1, Team.white), isTrue);
      });

      test('should return false when position is safe', () {
        // Setup: Black queen not attacking a2
        final customPieces = {h8: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        expect(
          threatDetector.isPositionUnderAttackFor(a2, Team.white),
          isFalse,
        );
      });

      test('should return false when attacked by same team', () {
        // Setup: White queen at e8, checking if e1 is under attack for white team
        final customPieces = {e8: whiteQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        expect(
          threatDetector.isPositionUnderAttackFor(e1, Team.white),
          isFalse,
        );
      });
    });
    group('canPieceAttackPosition', () {
      test('should return true when piece can attack target position', () {
        // Setup: Queen can attack multiple positions
        final customPieces = {d4: whiteQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final queenOnBoard = boardState[d4];

        expect(threatDetector.canPieceAttackPosition(queenOnBoard, d8), isTrue);
        expect(threatDetector.canPieceAttackPosition(queenOnBoard, h4), isTrue);
        expect(threatDetector.canPieceAttackPosition(queenOnBoard, a1), isTrue);
      });

      test('should return false when piece cannot attack target position', () {
        // Setup: Knight cannot attack certain positions
        final customPieces = {d4: whiteKnight};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final knightOnBoard = boardState[d4];

        expect(
          threatDetector.canPieceAttackPosition(knightOnBoard, d5),
          isFalse,
        );
        expect(
          threatDetector.canPieceAttackPosition(knightOnBoard, a1),
          isFalse,
        );
      });

      test('should return true for valid knight moves', () {
        // Setup: Knight valid moves
        final customPieces = {d4: whiteKnight};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final knightOnBoard = boardState[d4];

        expect(
          threatDetector.canPieceAttackPosition(knightOnBoard, c6),
          isTrue,
        );
        expect(
          threatDetector.canPieceAttackPosition(knightOnBoard, e6),
          isTrue,
        );
        expect(
          threatDetector.canPieceAttackPosition(knightOnBoard, f5),
          isTrue,
        );
      });
    });
    group('getThreateningPieces', () {
      test('should return all pieces threatening the target square', () {
        final customPieces = {e1: whiteKing, e8: blackQueen, a1: blackRook};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final whiteKingOnBoard = boardState[e1];
        final threatening = threatDetector.getThreateningPieces(
          whiteKingOnBoard,
        );

        expect(threatening.length, equals(2));
        expect(threatening, containsAll([e8 < blackQueen, a1 < blackRook]));
      });

      test('should return empty list when no pieces threaten target', () {
        // Setup: King safe from all pieces
        final customPieces = {a1: whiteKing, h7: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final whiteKingOnBoard = boardState[a1];
        final threatening = threatDetector.getThreateningPieces(
          whiteKingOnBoard,
        );

        expect(threatening, isEmpty);
      });
    });

    group('getThreatenedPositions', () {
      test('should return all positions threatened by a piece', () {
        // Setup: Queen threatening multiple positions
        final customPieces = {d4: whiteQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final threatenedPositions = threatDetector.getThreatenedPositions(
          whiteQueen,
          d4,
        );

        expect(threatenedPositions, isNotEmpty);
        expect(threatenedPositions, contains(d1));
        expect(threatenedPositions, contains(d8));
        expect(threatenedPositions, contains(a4));
        expect(threatenedPositions, contains(h4));
        expect(threatenedPositions, contains(a1));
        expect(threatenedPositions, contains(g7));
      });
      test('should return limited positions for knight', () {
        // Setup: Knight with limited moves
        final customPieces = {a1: whiteKnight};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final threatenedPositions = threatDetector.getThreatenedPositions(
          whiteKnight,
          a1,
        );

        expect(threatenedPositions.length, equals(2)); // Only b3 and c2 from a1
        expect(threatenedPositions, contains(b3));
        expect(threatenedPositions, contains(c2));
      });
    });
    group('wouldMoveExposePieceToThreat', () {
      test('should return true when move exposes piece to threat', () {
        // Setup: Moving a piece that was blocking an attack
        final customPieces = {d2: whiteKing, e2: whitePawn, h2: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final pawnMove = Move.create(from: e2, to: e3, moving: whitePawn);
        final whiteKingOnBoard = boardState[d2];

        expect(
          threatDetector.wouldMoveExposePieceToThreat(
            pawnMove,
            whiteKingOnBoard,
          ),
          isTrue,
        );
      });
      test('should return false when piece is already under threat', () {
        // Setup: Move that doesn't expose the king
        final customPieces = {e1: whiteKing, d2: whitePawn, e8: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final pawnMove = Move.create(from: d2, to: d3, moving: whitePawn);
        final whiteKingOnBoard = boardState[e1];

        expect(
          threatDetector.wouldMoveExposePieceToThreat(
            pawnMove,
            whiteKingOnBoard,
          ),
          isFalse,
        );
      });
      test('should return false when move does not expose piece', () {
        // Setup: Moving a piece that was blocking an attack
        final customPieces = {d2: whiteKing, e2: whitePawn, h1: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final pawnMove = Move.create(from: e2, to: e3, moving: whitePawn);
        final whiteKingOnBoard = boardState[d2];

        expect(
          threatDetector.wouldMoveExposePieceToThreat(
            pawnMove,
            whiteKingOnBoard,
          ),
          isFalse,
        );
      });
      test('should return false when move protects piece', () {
        // Setup: Moving a piece that was blocking an attack
        final customPieces = {d3: whiteKing, e2: whitePawn, h3: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final pawnMove = Move.create(from: e2, to: e3, moving: whitePawn);
        final whiteKingOnBoard = boardState[d3];

        expect(
          threatDetector.wouldMoveExposePieceToThreat(
            pawnMove,
            whiteKingOnBoard,
          ),
          isFalse,
        );
      });
    });
    group('isPositionSafeFor', () {
      test('should return true when position is safe for team', () {
        // Setup: Safe position for white pieces
        final customPieces = {h3: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        expect(threatDetector.isPositionSafeFor(a1, Team.white), isTrue);
      });

      test('should return false when position is under attack', () {
        // Setup: Dangerous position for white pieces
        final customPieces = {e8: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        expect(threatDetector.isPositionSafeFor(e1, Team.white), isFalse);
      });
    });
    group('isPieceTypeThreateningPosition', () {
      test(
        'should return true when specific piece type threatens position',
        () {
          // Setup: Queen threatening a position
          final customPieces = {e1: whiteKing, e8: blackQueen, a1: blackRook};
          boardState = BoardState.custom(customPieces);
          threatDetector = ThreatDetector(boardState);

          final whiteKingOnBoard = boardState[e1];

          expect(
            threatDetector.isPieceTypeThreateningPosition<Queen>(
              whiteKingOnBoard,
            ),
            isTrue,
          );
        },
      );

      test(
        'should return false when piece type is not threatening position',
        () {
          // Setup: No rook threatening the position
          final customPieces = {
            e1: whiteKing,
            d2: blackQueen, // Queen threatens but we're checking for Rook
          };
          boardState = BoardState.custom(customPieces);
          threatDetector = ThreatDetector(boardState);
          final whiteKingOnBoard = boardState[e1];

          expect(
            threatDetector.isPieceTypeThreateningPosition<Rook>(
              whiteKingOnBoard,
            ),
            isFalse,
          );
        },
      );
    });
    group('complex scenarios', () {
      test('should handle multiple simultaneous threats', () {
        // Setup: King under attack by multiple pieces
        final customPieces = {
          e4: whiteKing,
          e8: blackQueen,
          a4: blackRook,
          c6: blackKnight,
        };
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);
        final whiteKingOnBoard = boardState[e4];

        expect(threatDetector.isPieceUnderThreat(whiteKingOnBoard), isTrue);

        final threatening = threatDetector.getThreateningPieces(
          whiteKingOnBoard,
        );
        expect(threatening.length, greaterThan(1));
      });

      test('should handle pieces blocked by other pieces', () {
        // Setup: Queen blocked by pawn
        final customPieces = {e1: whiteKing, e2: whitePawn, e8: blackQueen};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);
        final whiteKingOnBoard = boardState[e1];

        expect(threatDetector.isPieceUnderThreat(whiteKingOnBoard), isFalse);

        // But the pawn is under threat
        final whitePawnOnBoard = boardState[e2];
        expect(threatDetector.isPieceUnderThreat(whitePawnOnBoard), isTrue);
      });
    });
    group('wouldMoveResolvePieceThreat', () {
      test(
        'should return true when move resolves piece threat by blocking',
        () {
          // Setup: King under attack, moving a piece to block the attack
          final customPieces = {e1: whiteKing, e8: blackQueen, d3: whiteQueen};
          boardState = BoardState.custom(customPieces);
          threatDetector = ThreatDetector(boardState);

          final queenMove = Move.create(from: d3, to: e3, moving: whiteQueen);
          final whiteKingOnBoard = boardState[e1];

          expect(
            threatDetector.wouldMoveResolvePieceThreat(
              queenMove,
              whiteKingOnBoard,
            ),
            isTrue,
          );
        },
      );

      test(
        'should return true when move resolves threat by capturing attacker',
        () {
          // Setup: King under attack, capturing the attacking piece
          final customPieces = {e1: whiteKing, e2: blackQueen, d3: whiteQueen};
          boardState = BoardState.custom(customPieces);
          threatDetector = ThreatDetector(boardState);

          final queenCapture = CaptureMove.create(
            from: d3,
            to: e2,
            moving: whiteQueen,
            captured: blackQueen,
          );
          final whiteKingOnBoard = boardState[e1];

          expect(
            threatDetector.wouldMoveResolvePieceThreat(
              queenCapture,
              whiteKingOnBoard,
            ),
            isTrue,
          );
        },
      );

      test(
        'should return true when move resolves threat by moving threatened piece',
        () {
          // Setup: King under attack, moving the king to safety
          final customPieces = {e1: whiteKing, e8: blackQueen};
          boardState = BoardState.custom(customPieces);
          threatDetector = ThreatDetector(boardState);

          final kingMove = Move.create(from: e1, to: d1, moving: whiteKing);
          final whiteKingOnBoard = boardState[e1];

          expect(
            threatDetector.wouldMoveResolvePieceThreat(
              kingMove,
              whiteKingOnBoard,
            ),
            isTrue,
          );
        },
      );

      test('should return false when piece is not currently under threat', () {
        // Setup: King is safe, move doesn't affect threat status
        final customPieces = {a1: whiteKing, h8: blackQueen, d2: whitePawn};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final pawnMove = Move.create(from: d2, to: d3, moving: whitePawn);
        final whiteKingOnBoard = boardState[a1];

        expect(
          threatDetector.wouldMoveResolvePieceThreat(
            pawnMove,
            whiteKingOnBoard,
          ),
          isFalse,
        );
      });

      test('should return false when move does not resolve threat', () {
        // Setup: King under attack, but move doesn't help
        final customPieces = {e1: whiteKing, e8: blackQueen, a2: whitePawn};
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final pawnMove = Move.create(from: a2, to: a3, moving: whitePawn);
        final whiteKingOnBoard = boardState[e1];

        expect(
          threatDetector.wouldMoveResolvePieceThreat(
            pawnMove,
            whiteKingOnBoard,
          ),
          isFalse,
        );
      });

      test('should return false when move creates new threat', () {
        // Setup: Piece under attack, move removes blocker creating new threat
        final customPieces = {
          d4: whiteKing,
          d2: whitePawn,
          d8: blackQueen,
          h4: blackRook,
        };
        boardState = BoardState.custom(customPieces);
        threatDetector = ThreatDetector(boardState);

        final pawnMove = Move.create(from: d2, to: d3, moving: whitePawn);
        final whiteKingOnBoard = boardState[d4];

        expect(
          threatDetector.wouldMoveResolvePieceThreat(
            pawnMove,
            whiteKingOnBoard,
          ),
          isFalse,
        );
      });
    });
  });
}
