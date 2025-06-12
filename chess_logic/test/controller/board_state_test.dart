import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/utility/extensions.dart';
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
        final e1 = Position.fromAlgebraic('e1');
        final d1 = Position.fromAlgebraic('d1');
        final a1 = Position.fromAlgebraic('a1');
        final h1 = Position.fromAlgebraic('h1');
        final b1 = Position.fromAlgebraic('b1');
        final g1 = Position.fromAlgebraic('g1');
        final c1 = Position.fromAlgebraic('c1');
        final f1 = Position.fromAlgebraic('f1');

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
        final e8 = Position.fromAlgebraic('e8');
        final d8 = Position.fromAlgebraic('d8');
        final a8 = Position.fromAlgebraic('a8');
        final h8 = Position.fromAlgebraic('h8');
        final b8 = Position.fromAlgebraic('b8');
        final g8 = Position.fromAlgebraic('g8');
        final c8 = Position.fromAlgebraic('c8');
        final f8 = Position.fromAlgebraic('f8');

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
      test('should create board with provided history', () {
        final e2 = Position.fromAlgebraic('e2');
        final e4 = Position.fromAlgebraic('e4');
        final e7 = Position.fromAlgebraic('e7');
        final e5 = Position.fromAlgebraic('e5');

        final moves = [
          PawnInitialMove(from: e2, to: e4, moving: Pawn(Team.white)),
          PawnInitialMove(from: e7, to: e5, moving: Pawn(Team.black)),
        ];

        final board = BoardState(history: moves);

        // Check that moves were applied
        expect(board[e2].isEmpty, isTrue);
        expect(board[e4].piece, isA<Pawn>());
        expect(board[e4].piece!.team, equals(Team.white));

        expect(board[e7].isEmpty, isTrue);
        expect(board[e5].piece, isA<Pawn>());
        expect(board[e5].piece!.team, equals(Team.black));
      });
    });

    group('BoardState.clear', () {
      test('should create empty board', () {
        final board = BoardState.clear();

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
        final e1 = Position.fromAlgebraic('e1');
        final e8 = Position.fromAlgebraic('e8');
        final d1 = Position.fromAlgebraic('d1');
        final d8 = Position.fromAlgebraic('d8');

        final customPieces = {
          e1: King(Team.white),
          e8: King(Team.black),
          d1: Queen(Team.white),
          d8: Queen(Team.black),
        };

        final board = BoardState.custom(customPieces);

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
            if (!customPieces.containsKey(position)) {
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
        final e4 = Position.fromAlgebraic('e4');
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
        final from = Position.fromAlgebraic('e2');
        final to = Position.fromAlgebraic('e3');
        final move = PawnMove(from: from, to: to, moving: Pawn(Team.white));

        boardState.actOn(move);

        expect(boardState[from].isEmpty, isTrue);
        expect(boardState[to].piece, isA<Pawn>());
        expect(boardState[to].piece!.team, equals(Team.white));
      });
      test('should handle capture moves', () {
        // Position instances
        final e4 = Position.fromAlgebraic('e4');
        final d5 = Position.fromAlgebraic('d5');

        // Setup: place a black pawn at d5 and white pawn at e4
        final blackPawn = Pawn(Team.black);
        final whitePawn = Pawn(Team.white);

        boardState.squares.replace(OccupiedSquare(d5, blackPawn));
        boardState.squares.replace(OccupiedSquare(e4, whitePawn));

        final move = PawnCaptureMove(
          from: e4,
          to: d5,
          moving: whitePawn,
          captured: blackPawn,
        );

        boardState.actOn(move);

        expect(boardState[e4].isEmpty, isTrue);
        expect(boardState[d5].piece, equals(whitePawn));
      });
      test('should handle en passant captures', () {
        // Position instances
        final e5 = Position.fromAlgebraic('e5');
        final d5 = Position.fromAlgebraic('d5');
        final d6 = Position.fromAlgebraic('d6');

        // Setup: white pawn at e5, black pawn at d5
        final whitePawn = Pawn(Team.white);
        final blackPawn = Pawn(Team.black);

        boardState.squares.replace(OccupiedSquare(e5, whitePawn));
        boardState.squares.replace(OccupiedSquare(d5, blackPawn));

        final move = EnPassantMove(
          from: e5,
          to: d6,
          moving: whitePawn,
          captured: blackPawn,
        );

        boardState.actOn(move);

        expect(boardState[e5].isEmpty, isTrue);
        expect(boardState[d6].piece, equals(whitePawn));
        expect(boardState[d5].isEmpty, isTrue); // Captured pawn removed
      });
      test('should throw ArgumentError when piece does not match', () {
        // Position instances
        final e4 = Position.fromAlgebraic('e4');
        final e5 = Position.fromAlgebraic('e5');

        final move = PawnMove(
          from: e4, // Empty square
          to: e5,
          moving: Pawn(Team.white),
        );

        expect(
          () => boardState.actOn(move),
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
        final e2 = Position.fromAlgebraic('e2');
        final f4 = Position.fromAlgebraic('f4');

        final move = KnightMove(
          from: e2, // Has pawn, not knight
          to: f4,
          moving: Knight(Team.white),
        );

        expect(
          () => boardState.actOn(move),
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
        final e2 = Position.fromAlgebraic('e2');
        final e4 = Position.fromAlgebraic('e4');
        final d7 = Position.fromAlgebraic('d7');
        final d5 = Position.fromAlgebraic('d5');
        final g1 = Position.fromAlgebraic('g1');
        final f3 = Position.fromAlgebraic('f3');

        final moves = <Move>[
          PawnInitialMove(from: e2, to: e4, moving: Pawn(Team.white)),
          PawnInitialMove(from: d7, to: d5, moving: Pawn(Team.black)),
          KnightMove(from: g1, to: f3, moving: Knight(Team.white)),
        ];

        for (final move in moves) {
          boardState.actOn(move);
        }

        expect(boardState[e2].isEmpty, isTrue);
        expect(boardState[e4].piece, isA<Pawn>());
        expect(boardState[d7].isEmpty, isTrue);
        expect(boardState[d5].piece, isA<Pawn>());
        expect(boardState[g1].isEmpty, isTrue);
        expect(boardState[f3].piece, isA<Knight>());
      });
    });

    group('undo', () {
      test('should reverse a regular move', () {
        final from = Position.fromAlgebraic('e2');
        final to = Position.fromAlgebraic('e4');
        final pawn = Pawn(Team.white);
        final move = PawnInitialMove(from: from, to: to, moving: pawn);

        // Apply move
        boardState.actOn(move);
        expect(boardState[from].isEmpty, isTrue);
        expect(boardState[to].piece, equals(pawn));

        // Undo move
        boardState.undo(move);
        expect(boardState[from].piece, equals(pawn));
        expect(boardState[to].isEmpty, isTrue);
      });
      test('should reverse a capture move', () {
        // Position instances
        final e4 = Position.fromAlgebraic('e4');
        final d5 = Position.fromAlgebraic('d5');

        // Setup: place pieces
        final whitePawn = Pawn(Team.white);
        final blackPawn = Pawn(Team.black);

        boardState.squares.replace(OccupiedSquare(e4, whitePawn));
        boardState.squares.replace(OccupiedSquare(d5, blackPawn));

        final move = PawnCaptureMove(
          from: e4,
          to: d5,
          moving: whitePawn,
          captured: blackPawn,
        );

        // Apply move
        boardState.actOn(move);
        expect(boardState[e4].isEmpty, isTrue);
        expect(boardState[d5].piece, equals(whitePawn));

        // Undo move
        boardState.undo(move);
        expect(boardState[e4].piece, equals(whitePawn));
        expect(boardState[d5].piece, equals(blackPawn));
      });
      test('should reverse an en passant move', () {
        // Position instances
        final e5 = Position.fromAlgebraic('e5');
        final d5 = Position.fromAlgebraic('d5');
        final d6 = Position.fromAlgebraic('d6');

        // Setup: place pieces
        final whitePawn = Pawn(Team.white);
        final blackPawn = Pawn(Team.black);

        boardState.squares.replace(OccupiedSquare(e5, whitePawn));
        boardState.squares.replace(OccupiedSquare(d5, blackPawn));

        final move = EnPassantMove(
          from: e5,
          to: d6,
          moving: whitePawn,
          captured: blackPawn,
        );

        // Apply move
        boardState.actOn(move);
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
        final e2 = Position.fromAlgebraic('e2');
        final e4 = Position.fromAlgebraic('e4');

        // Setup: make a move first
        final move = PawnMove(from: e2, to: e4, moving: Pawn(Team.white));
        boardState.actOn(move);

        // Try to undo with wrong piece
        final wrongMove = KnightMove(
          from: e2,
          to: e4,
          moving: Knight(Team.white),
        );

        expect(
          () => boardState.undo(wrongMove),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('The piece at e2 does not match the moving piece'),
            ),
          ),
        );
      });
      test('should handle multiple moves and undos', () {
        final e2 = Position.fromAlgebraic('e2');
        final e4 = Position.fromAlgebraic('e4');
        final d7 = Position.fromAlgebraic('d7');
        final d5 = Position.fromAlgebraic('d5');

        final moves = [
          PawnInitialMove(from: e2, to: e4, moving: Pawn(Team.white)),
          PawnInitialMove(from: d7, to: d5, moving: Pawn(Team.black)),
        ];

        // Apply moves
        for (final move in moves) {
          boardState.actOn(move);
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
        final e2 = Position.fromAlgebraic('e2');
        final e4 = Position.fromAlgebraic('e4');
        final g1 = Position.fromAlgebraic('g1');
        final f3 = Position.fromAlgebraic('f3');
        final e1 = Position.fromAlgebraic('e1');

        // Make some moves to change the board
        boardState.actOn(
          PawnInitialMove(from: e2, to: e4, moving: Pawn(Team.white)),
        );
        boardState.actOn(
          KnightMove(from: g1, to: f3, moving: Knight(Team.white)),
        );

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
        final e1 = Position.fromAlgebraic('e1');
        final e8 = Position.fromAlgebraic('e8');

        final emptyBoard = BoardState.clear();

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
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
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
      test('should handle Scholar\'s Mate sequence', () {
        final moves = <Move>[
          PawnMove(
            from: Position.fromAlgebraic('e2'),
            to: Position.fromAlgebraic('e4'),
            moving: Pawn(Team.white),
          ),
          PawnMove(
            from: Position.fromAlgebraic('e7'),
            to: Position.fromAlgebraic('e5'),
            moving: Pawn(Team.black),
          ),
          BishopMove(
            from: Position.fromAlgebraic('f1'),
            to: Position.fromAlgebraic('c4'),
            moving: Bishop(Team.white),
          ),
          KnightMove(
            from: Position.fromAlgebraic('b8'),
            to: Position.fromAlgebraic('c6'),
            moving: Knight(Team.black),
          ),
          QueenMove(
            from: Position.fromAlgebraic('d1'),
            to: Position.fromAlgebraic('h5'),
            moving: Queen(Team.white),
          ),
          KnightMove(
            from: Position.fromAlgebraic('g8'),
            to: Position.fromAlgebraic('f6'),
            moving: Knight(Team.black),
          ),
          QueenCaptureMove(
            from: Position.fromAlgebraic('h5'),
            to: Position.fromAlgebraic('f7'),
            moving: Queen(Team.white),
            captured: Pawn(Team.black),
          ),
        ];

        for (final move in moves) {
          boardState.actOn(move);
        }

        // Verify final position
        expect(boardState[Position.fromAlgebraic('f7')].piece, isA<Queen>());
        expect(
          boardState[Position.fromAlgebraic('f7')].piece!.team,
          equals(Team.white),
        );
        expect(boardState[Position.fromAlgebraic('h5')].isEmpty, isTrue);
        expect(boardState[Position.fromAlgebraic('c4')].piece, isA<Bishop>());
        expect(boardState[Position.fromAlgebraic('e4')].piece, isA<Pawn>());
        expect(boardState[Position.fromAlgebraic('e5')].piece, isA<Pawn>());
      });

      test('should maintain board consistency during complex sequence', () {
        final d2 = Position.fromAlgebraic('d2');
        final d4 = Position.fromAlgebraic('d4');
        final d5 = Position.fromAlgebraic('d5');
        final d7 = Position.fromAlgebraic('d7');

        final moves = [
          PawnInitialMove(from: d2, to: d4, moving: Pawn(Team.white)),
          PawnInitialMove(from: d7, to: d5, moving: Pawn(Team.black)),
          PawnCaptureMove(
            from: d4,
            to: d5,
            moving: Pawn(Team.white),
            captured: Pawn(Team.black),
          ),
        ];

        for (final move in moves) {
          boardState.actOn(move);
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
        expect(boardState[d5].piece, isA<Pawn>());
        expect(boardState[d5].piece!.team, equals(Team.white));
        expect(boardState[d7].isEmpty, isTrue);
      });

      test('should handle castling moves', () {
        // Position instances
        final e1 = Position.fromAlgebraic('e1');
        final f1 = Position.fromAlgebraic('f1');
        final g1 = Position.fromAlgebraic('g1');
        final h1 = Position.fromAlgebraic('h1');

        // Clear pieces between king and rook
        boardState.squares.replace(EmptySquare(f1));
        boardState.squares.replace(EmptySquare(g1));

        final castlingMove = KingMove.kingsideCastling(
          king: King(Team.white),
          from: e1,
          to: g1,
          rook: RookMove(from: h1, to: f1, moving: Rook(Team.white)),
        );

        boardState.actOn(castlingMove);

        expect(boardState[e1].isEmpty, isTrue);
        expect(boardState[g1].piece, isA<King>());
        expect(boardState[h1].isEmpty, isTrue);
        expect(boardState[f1].piece, isA<Rook>());
      });
    });

    group('edge cases', () {
      test('should handle moves on empty board', () {
        // Position instances
        final e4 = Position.fromAlgebraic('e4');
        final e5 = Position.fromAlgebraic('e5');

        final emptyBoard = BoardState.clear();

        // Place a piece manually
        emptyBoard.squares.replace(OccupiedSquare(e4, Pawn(Team.white)));

        final move = PawnMove(from: e4, to: e5, moving: Pawn(Team.white));

        emptyBoard.actOn(move);

        expect(emptyBoard[e4].isEmpty, isTrue);
        expect(emptyBoard[e5].piece, isA<Pawn>());
      });

      test('should handle promotion moves', () {
        // Position instances
        final e7 = Position.fromAlgebraic('e7');
        final e8 = Position.fromAlgebraic('e8');

        // Setup: white pawn at e7
        boardState.squares.replace(EmptySquare(e7));
        boardState.squares.replace(OccupiedSquare(e7, Pawn(Team.white)));

        final move = PromotionMove(
          from: e7,
          to: e8,
          moving: Pawn(Team.white),
          promotion: PieceSymbol.queen,
        );

        boardState.actOn(move);

        expect(boardState[e7].isEmpty, isTrue);
        expect(boardState[e8].piece, isA<Queen>());
        expect(boardState[e8].piece!.team, equals(Team.white));
      });

      test('should handle board with single piece', () {
        // Position instances
        final a1 = Position.fromAlgebraic('a1');
        final a2 = Position.fromAlgebraic('a2');

        final singlePieceBoard = BoardState.custom({a1: King(Team.white)});

        final move = KingMove(from: a1, to: a2, moving: King(Team.white));

        singlePieceBoard.actOn(move);

        expect(singlePieceBoard[a1].isEmpty, isTrue);
        expect(singlePieceBoard[a2].piece, isA<King>());
      });
    });

    group('board state preservation', () {
      test('should preserve other pieces when making a move', () {
        final e2 = Position.fromAlgebraic('e2');
        final e4 = Position.fromAlgebraic('e4');
        final originalPieces = <Position, Piece>{};

        // Record all original pieces
        for (final file in File.values) {
          for (final rank in Rank.values) {
            final position = Position(file, rank);
            final piece = boardState[position].piece;
            if (piece != null) {
              originalPieces[position] = piece;
            }
          }
        }

        // Make a simple pawn move
        final move = PawnInitialMove(
          from: e2,
          to: e4,
          moving: Pawn(Team.white),
        );
        boardState.actOn(move);

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
