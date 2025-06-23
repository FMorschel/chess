import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/position/rank.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('BoardState', () {
    late BoardState boardState;

    setUp(() {
      boardState = BoardState();
    });
    group('constructor', () {
      test('should create board with standard starting position', () {
        final board = BoardState();

        // Position instances
        const e1 = Position.e1;
        const d1 = Position.d1;
        const a1 = Position.a1;
        const h1 = Position.h1;
        const b1 = Position.b1;
        const g1 = Position.g1;
        const c1 = Position.c1;
        const f1 = Position.f1;

        // Test white pieces
        expect(board[e1].piece, isA<King>());
        expect(board[e1].piece!.team, equals(Team.white));

        expect(board[d1].piece, isA<Queen>());
        expect(board[d1].piece!.team, equals(Team.white));

        expect(board[a1].piece, isA<Rook>());
        expect(board[h1].piece, isA<Rook>());

        expect(board[b1].piece, isA<Knight>());
        expect(board[g1].piece, isA<Knight>());

        expect(board[c1].piece, isA<Bishop>());
        expect(board[f1].piece, isA<Bishop>());

        // Test white pawns
        for (final file in File.values) {
          final position = Position(file, Rank.two);
          expect(board[position].piece, isA<Pawn>());
          expect(board[position].piece!.team, equals(Team.white));
        } // Test black pieces
        const e8 = Position.e8;
        const d8 = Position.d8;
        const a8 = Position.a8;
        const h8 = Position.h8;
        const b8 = Position.b8;
        const g8 = Position.g8;
        const c8 = Position.c8;
        const f8 = Position.f8;

        expect(board[e8].piece, isA<King>());
        expect(board[e8].piece!.team, equals(Team.black));

        expect(board[d8].piece, isA<Queen>());
        expect(board[d8].piece!.team, equals(Team.black));

        expect(board[a8].piece, isA<Rook>());
        expect(board[h8].piece, isA<Rook>());

        expect(board[b8].piece, isA<Knight>());
        expect(board[g8].piece, isA<Knight>());

        expect(board[c8].piece, isA<Bishop>());
        expect(board[f8].piece, isA<Bishop>());

        // Test black pawns
        for (final file in File.values) {
          final position = Position(file, Rank.seven);
          expect(board[position].piece, isA<Pawn>());
          expect(board[position].piece!.team, equals(Team.black));
        }

        // Test empty squares
        for (final file in File.values) {
          for (final rank in [Rank.three, Rank.four, Rank.five, Rank.six]) {
            final position = Position(file, rank);
            expect(board[position].isEmpty, isTrue);
          }
        }
      });
    });

    group('BoardState.clear', () {
      test('should create empty board', () {
        final board = BoardState.empty();

        for (final file in File.values) {
          for (final rank in Rank.values) {
            final position = Position(file, rank);
            expect(board[position].isEmpty, isTrue);
          }
        }
      });
    });
    group('BoardState.custom', () {
      test('should create board with custom pieces', () {
        const e1 = Position.e1;
        const e8 = Position.e8;
        const d1 = Position.d1;
        const d8 = Position.d8;

        const positions = [e1, e8, d1, d8];

        final board = BoardState.custom({
          e1: King.white,
          e8: King.black,
          d1: Queen.white,
          d8: Queen.black,
        });

        expect(board[e1].piece, isA<King>());
        expect(board[e1].piece!.team, equals(Team.white));
        expect(board[e8].piece, isA<King>());
        expect(board[e8].piece!.team, equals(Team.black));
        expect(board[d1].piece, isA<Queen>());
        expect(board[d1].piece!.team, equals(Team.white));
        expect(board[d8].piece, isA<Queen>());
        expect(board[d8].piece!.team, equals(Team.black));

        // All other squares should be empty
        for (final file in File.values) {
          for (final rank in Rank.values) {
            final position = Position(file, rank);
            if (!positions.contains(position)) {
              expect(board[position].isEmpty, isTrue);
            }
          }
        }
      });

      test('should create empty board when no custom pieces provided', () {
        final board = BoardState.custom({});

        for (final file in File.values) {
          for (final rank in Rank.values) {
            final position = Position(file, rank);
            expect(board[position].isEmpty, isTrue);
          }
        }
      });
    });
    group('operator []', () {
      test('should return square at given position', () {
        const e4 = Position.e4;
        final square = boardState[e4];

        expect(square.position, equals(e4));
      });

      test('should return correct square for all positions', () {
        for (final file in File.values) {
          for (final rank in Rank.values) {
            final position = Position(file, rank);
            final square = boardState[position];

            expect(square.position, equals(position));
          }
        }
      });
    });

    group('actOn', () {
      test('should move piece from one square to another', () {
        const from = Position.e2;
        const to = Position.e3;
        final move = PawnMove(from: from, to: to, moving: Pawn.white);

        boardState.move(move);

        expect(boardState[from].isEmpty, isTrue);
        expect(boardState[to].piece, isA<Pawn>());
        expect(boardState[to].piece!.team, equals(Team.white));
      });
      test('should handle capture moves', () {
        // Position instances
        const e4 = Position.e4;
        const d5 = Position.d5;

        // Setup: place a black pawn at d5 and white pawn at e4
        const blackPawn = Pawn.black;
        const whitePawn = Pawn.white;

        boardState.replace(const OccupiedSquare(d5, blackPawn));
        boardState.replace(const OccupiedSquare(e4, whitePawn));

        final move = PawnCaptureMove(
          from: e4,
          to: d5,
          moving: whitePawn,
          captured: blackPawn,
        );

        boardState.move(move);

        expect(boardState[e4].isEmpty, isTrue);
        expect(boardState[d5].piece, equals(whitePawn));
      });
      test('should handle en passant captures', () {
        // Position instances
        const e5 = Position.e5;
        const d5 = Position.d5;
        const d6 = Position.d6;

        // Setup: white pawn at e5, black pawn at d5
        const whitePawn = Pawn.white;
        const blackPawn = Pawn.black;

        boardState.replace(const OccupiedSquare(e5, whitePawn));
        boardState.replace(const OccupiedSquare(d5, blackPawn));

        final move = EnPassantMove(
          from: e5,
          to: d6,
          moving: whitePawn,
          captured: blackPawn,
        );

        boardState.move(move);

        expect(boardState[e5].isEmpty, isTrue);
        expect(boardState[d6].piece, equals(whitePawn));
        expect(boardState[d5].isEmpty, isTrue); // Captured pawn removed
      });
      test('should throw ArgumentError when piece does not match', () {
        // Position instances
        const e4 = Position.e4;
        const e5 = Position.e5;

        final move = PawnMove(
          from: e4, // Empty square
          to: e5,
          moving: Pawn.white,
        );

        expect(
          () => boardState.move(move),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('The piece at e4 does not match the moving piece'),
            ),
          ),
        );
      });
      test('should throw ArgumentError when wrong piece type', () {
        // Position instances
        const e2 = Position.e2;
        const f4 = Position.f4;

        final move = KnightMove(
          from: e2, // Has pawn, not knight
          to: f4,
          moving: Knight.white,
        );

        expect(
          () => boardState.move(move),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('The piece at e2 does not match the moving piece'),
            ),
          ),
        );
      });
      test('should handle multiple moves in sequence', () {
        const e2 = Position.e2;
        const e4 = Position.e4;
        const d7 = Position.d7;
        const d5 = Position.d5;
        const g1 = Position.g1;
        const f3 = Position.f3;

        final moves = <Move>[
          PawnInitialMove(from: e2, to: e4, moving: Pawn.white),
          PawnInitialMove(from: d7, to: d5, moving: Pawn.black),
          KnightMove(from: g1, to: f3, moving: Knight.white),
        ];

        for (final move in moves) {
          boardState.move(move);
        }

        expect(boardState[e2].isEmpty, isTrue);
        expect(boardState[e4].piece, isA<Pawn>());
        expect(boardState[d7].isEmpty, isTrue);
        expect(boardState[d5].piece, isA<Pawn>());
        expect(boardState[g1].isEmpty, isTrue);
        expect(boardState[f3].piece, isA<Knight>());
      });
      test('should throw ArgumentError when moving to occupied square with '
          'non-capture move', () {
        // Setup: place pieces on board
        const e4 = Position.e4;
        const e5 = Position.e5;

        const whitePawn = Pawn.white;
        const blackPawn = Pawn.black;

        // Place white pawn at e4 and black pawn at e5
        boardState.replace(const OccupiedSquare(e4, whitePawn));
        boardState.replace(const OccupiedSquare(e5, blackPawn));

        // Try to move white pawn from e4 to e5 (occupied by black pawn)
        // using a regular PawnMove (not PawnCaptureMove)
        final invalidMove = PawnMove(from: e4, to: e5, moving: whitePawn);

        expect(
          () => boardState.move(invalidMove),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Cannot move to an occupied square: e5'),
            ),
          ),
        );

        // Verify board state is unchanged
        expect(boardState[e4].piece, equals(whitePawn));
        expect(boardState[e5].piece, equals(blackPawn));
      });

      test('should allow moving to occupied square with capture move', () {
        // Setup: place pieces on board
        const e4 = Position.e4;
        const d5 = Position.d5;

        const whitePawn = Pawn.white;
        const blackPawn = Pawn.black;

        // Place white pawn at e4 and black pawn at d5
        boardState.replace(const OccupiedSquare(e4, whitePawn));
        boardState.replace(const OccupiedSquare(d5, blackPawn));

        // Move white pawn from e4 to d5 (capturing black pawn)
        // using PawnCaptureMove - this should work
        final captureMove = PawnCaptureMove(
          from: e4,
          to: d5,
          moving: whitePawn,
          captured: blackPawn,
        );

        // This should not throw an error
        expect(() => boardState.move(captureMove), returnsNormally);

        // Verify the capture was successful
        expect(boardState[e4].isEmpty, isTrue);
        expect(boardState[d5].piece, equals(whitePawn));
      });
    });

    group('undo', () {
      test('should reverse a regular move', () {
        const from = Position.e2;
        const to = Position.e4;
        const pawn = Pawn.white;
        final move = PawnInitialMove(from: from, to: to, moving: pawn);

        // Apply move
        boardState.move(move);
        expect(boardState[from].isEmpty, isTrue);
        expect(boardState[to].piece, equals(pawn));

        // Undo move
        boardState.undo(move);
        expect(boardState[from].piece, equals(pawn));
        expect(boardState[to].isEmpty, isTrue);
      });
      test('should reverse a capture move', () {
        // Position instances
        const e4 = Position.e4;
        const d5 = Position.d5;

        // Setup: place pieces
        const whitePawn = Pawn.white;
        const blackPawn = Pawn.black;

        boardState.replace(const OccupiedSquare(e4, whitePawn));
        boardState.replace(const OccupiedSquare(d5, blackPawn));

        final move = PawnCaptureMove(
          from: e4,
          to: d5,
          moving: whitePawn,
          captured: blackPawn,
        );

        // Apply move
        boardState.move(move);
        expect(boardState[e4].isEmpty, isTrue);
        expect(boardState[d5].piece, equals(whitePawn));

        // Undo move
        boardState.undo(move);
        expect(boardState[e4].piece, equals(whitePawn));
        expect(boardState[d5].piece, equals(blackPawn));
      });
      test('should reverse an en passant move', () {
        // Position instances
        const e5 = Position.e5;
        const d5 = Position.d5;
        const d6 = Position.d6;

        // Setup: place pieces
        const whitePawn = Pawn.white;
        const blackPawn = Pawn.black;

        boardState.replace(const OccupiedSquare(e5, whitePawn));
        boardState.replace(const OccupiedSquare(d5, blackPawn));

        final move = EnPassantMove(
          from: e5,
          to: d6,
          moving: whitePawn,
          captured: blackPawn,
        );

        // Apply move
        boardState.move(move);
        expect(boardState[e5].isEmpty, isTrue);
        expect(boardState[d6].piece, equals(whitePawn));
        expect(boardState[d5].isEmpty, isTrue);

        // Undo move
        boardState.undo(move);
        expect(boardState[e5].piece, equals(whitePawn));
        expect(boardState[d6].isEmpty, isTrue);
        expect(boardState[d5].piece, equals(blackPawn));
      });
      test('should throw ArgumentError when piece does not match', () {
        // Position instances
        const e2 = Position.e2;
        const e4 = Position.e4;

        // Setup: make a move first
        final move = PawnInitialMove(from: e2, to: e4, moving: Pawn.white);
        boardState.move(move);

        // Try to undo with wrong piece
        final wrongMove = KnightMove(
          from: e2,
          to: Position.f4,
          moving: Knight.white,
        );

        expect(
          () => boardState.undo(wrongMove),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('The piece at f4 does not match the moving piece'),
            ),
          ),
        );
      });
      test('should handle multiple moves and undos', () {
        const e2 = Position.e2;
        const e4 = Position.e4;
        const d7 = Position.d7;
        const d5 = Position.d5;

        final moves = [
          PawnInitialMove(from: e2, to: e4, moving: Pawn.white),
          PawnInitialMove(from: d7, to: d5, moving: Pawn.black),
        ];

        // Apply moves
        for (final move in moves) {
          boardState.move(move);
        }

        // Verify moves were applied
        expect(boardState[e2].isEmpty, isTrue);
        expect(boardState[e4].piece, isA<Pawn>());
        expect(boardState[d7].isEmpty, isTrue);
        expect(boardState[d5].piece, isA<Pawn>());

        // Undo moves in reverse order
        for (final move in moves.reversed) {
          boardState.undo(move);
        }

        // Verify board is back to starting position
        expect(boardState[e2].piece, isA<Pawn>());
        expect(boardState[e4].isEmpty, isTrue);
        expect(boardState[d7].piece, isA<Pawn>());
        expect(boardState[d5].isEmpty, isTrue);
      });
    });
    group('reset', () {
      test('should reset board to starting position', () {
        const e2 = Position.e2;
        const e4 = Position.e4;
        const g1 = Position.g1;
        const f3 = Position.f3;
        const e1 = Position.e1;

        // Make some moves to change the board
        boardState.move(PawnInitialMove(from: e2, to: e4, moving: Pawn.white));
        boardState.move(KnightMove(from: g1, to: f3, moving: Knight.white));

        // Reset board
        boardState.reset();

        // Verify starting position
        expect(boardState[e1].piece, isA<King>());
        expect(boardState[e1].piece!.team, equals(Team.white));
        expect(boardState[e2].piece, isA<Pawn>());
        expect(boardState[e2].piece!.team, equals(Team.white));
        expect(boardState[e4].isEmpty, isTrue);
        expect(boardState[g1].piece, isA<Knight>());
        expect(boardState[f3].isEmpty, isTrue);
      });
      test('should reset empty board to starting position', () {
        const e1 = Position.e1;
        const e8 = Position.e8;

        final emptyBoard = BoardState.empty();

        emptyBoard.reset();

        // Verify starting position
        expect(emptyBoard[e1].piece, isA<King>());
        expect(emptyBoard[e1].piece!.team, equals(Team.white));
        expect(emptyBoard[e8].piece, isA<King>());
        expect(emptyBoard[e8].piece!.team, equals(Team.black));
      });
    });

    group('clear', () {
      test('should clear all pieces from board', () {
        boardState.clear();

        for (final file in File.values) {
          for (final rank in Rank.values) {
            final position = Position(file, rank);
            expect(boardState[position].isEmpty, isTrue);
          }
        }
      });

      test('should clear custom board', () {
        final customBoard = BoardState.custom({
          Position.e1: King.white,
          Position.e8: King.black,
        });

        customBoard.clear();

        for (final file in File.values) {
          for (final rank in Rank.values) {
            final position = Position(file, rank);
            expect(customBoard[position].isEmpty, isTrue);
          }
        }
      });
    });

    group('integration tests', () {
      test("should handle Scholar's Mate sequence", () {
        final moves = <Move>[
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
          QueenCaptureMove(
            from: Position.h5,
            to: Position.f7,
            moving: Queen.white,
            captured: Pawn.black,
          ),
        ];

        for (final move in moves) {
          boardState.move(move);
        }

        // Verify final position
        expect(boardState[Position.f7].piece, isA<Queen>());
        expect(boardState[Position.f7].piece!.team, equals(Team.white));
        expect(boardState[Position.h5].isEmpty, isTrue);
        expect(boardState[Position.c4].piece, isA<Bishop>());
        expect(boardState[Position.e4].piece, isA<Pawn>());
        expect(boardState[Position.e5].piece, isA<Pawn>());
      });

      test('should maintain board consistency during complex sequence', () {
        const d2 = Position.d2;
        const d4 = Position.d4;
        const e5 = Position.e5;
        const e7 = Position.e7;

        final moves = [
          PawnInitialMove(from: d2, to: d4, moving: Pawn.white),
          PawnInitialMove(from: e7, to: e5, moving: Pawn.black),
          PawnCaptureMove(
            from: d4,
            to: e5,
            moving: Pawn.white,
            captured: Pawn.black,
          ),
        ];

        for (final move in moves) {
          boardState.move(move);
        }

        // Check piece count - should have 31 pieces (32 - 1 captured)
        var pieceCount = 0;
        for (final file in File.values) {
          for (final rank in Rank.values) {
            final position = Position(file, rank);
            if (boardState[position].isOccupied) {
              pieceCount++;
            }
          }
        }
        expect(pieceCount, equals(31));

        // Verify specific positions
        expect(boardState[d2].isEmpty, isTrue);
        expect(boardState[d4].isEmpty, isTrue);
        expect(boardState[e5].piece, isA<Pawn>());
        expect(boardState[e5].piece!.team, equals(Team.white));
        expect(boardState[e7].isEmpty, isTrue);
      });

      test('should handle castling moves', () {
        // Position instances
        const e1 = Position.e1;
        const f1 = Position.f1;
        const g1 = Position.g1;
        const h1 = Position.h1;

        // Clear pieces between king and rook
        boardState.replace(const EmptySquare(f1));
        boardState.replace(const EmptySquare(g1));

        final castlingMove = KingMove.kingsideCastling(
          king: King.white,
          from: e1,
          to: g1,
          rook: RookMove(from: h1, to: f1, moving: Rook.white),
        );

        boardState.move(castlingMove);

        expect(boardState[e1].isEmpty, isTrue);
        expect(boardState[g1].piece, isA<King>());
        expect(boardState[h1].isEmpty, isTrue);
        expect(boardState[f1].piece, isA<Rook>());
      });
    });

    group('edge cases', () {
      test('should handle moves on empty board', () {
        // Position instances
        const e4 = Position.e4;
        const e5 = Position.e5;

        final emptyBoard = BoardState.empty();

        // Place a piece manually
        emptyBoard.replace(const OccupiedSquare(e4, Pawn.white));

        final move = PawnMove(from: e4, to: e5, moving: Pawn.white);

        emptyBoard.move(move);

        expect(emptyBoard[e4].isEmpty, isTrue);
        expect(emptyBoard[e5].piece, isA<Pawn>());
      });

      test('should handle promotion moves', () {
        // Position instances
        const e7 = Position.e7;
        const e8 = Position.e8;

        // Setup: white pawn at e7
        boardState.replace(const EmptySquare(e8));
        boardState.replace(const EmptySquare(e7));
        boardState.replace(const OccupiedSquare(e7, Pawn.white));

        final move = PromotionMove(
          from: e7,
          to: e8,
          moving: Pawn.white,
          promotion: PieceSymbol.queen,
        );

        boardState.move(move);

        expect(boardState[e7].isEmpty, isTrue);
        expect(boardState[e8].piece, isA<Queen>());
        expect(boardState[e8].piece!.team, equals(Team.white));
      });

      test('should handle board with single piece', () {
        // Position instances
        const a1 = Position.a1;
        const a2 = Position.a2;

        final singlePieceBoard = BoardState.custom({a1: King.white});

        final move = KingMove(from: a1, to: a2, moving: King.white);

        singlePieceBoard.move(move);

        expect(singlePieceBoard[a1].isEmpty, isTrue);
        expect(singlePieceBoard[a2].piece, isA<King>());
      });
    });

    group('board state preservation', () {
      test('should preserve other pieces when making a move', () {
        const e2 = Position.e2;
        const e4 = Position.e4;
        final originalPieces = <Position, Piece>{};

        // Record all original pieces
        for (final square in boardState.occupiedSquares) {
          originalPieces[square.position] = square.piece;
        }

        // Make a simple pawn move
        final move = PawnInitialMove(from: e2, to: e4, moving: Pawn.white);
        boardState.move(move);

        // Check that all other pieces remain unchanged
        for (final entry in originalPieces.entries) {
          final position = entry.key;
          final originalPiece = entry.value;

          if (position == e2) {
            // This square should now be empty
            expect(boardState[position].isEmpty, isTrue);
          } else if (position == e4) {
            // This square should have the moved pawn
            expect(boardState[position].piece, equals(originalPiece));
          } else {
            // All other squares should be unchanged
            expect(boardState[position].piece, equals(originalPiece));
          }
        }
      });
    });
  });
}
