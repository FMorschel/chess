import 'package:chess_logic/src/controller/game_controller.dart';
import 'package:chess_logic/src/controller/game_state.dart';
import 'package:chess_logic/src/controller/team_score.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('GameController', () {
    late List<Team> teams;

    setUp(() {
      teams = [Team.white, Team.black];
    });

    group('constructor', () {
      test('should create game controller with valid teams', () {
        final controller = GameController(teams);

        expect(controller.teams, equals(teams));
        expect(controller.scores, hasLength(2));
        expect(controller.currentTeam, equals(Team.white));
        expect(controller.history, isEmpty);
      });
      test('should create game controller with move history', () {
        final move = Move.create(
          from: Position.e2,
          to: Position.e3,
          moving: Pawn.white,
        );
        final moveHistory = [move];

        final controller = GameController(teams, moveHistory: moveHistory);

        expect(controller.history, equals(moveHistory));
        expect(
          controller.currentTeam,
          equals(Team.black),
        ); // Next team after white
      });

      test('should throw assertion error with single team', () {
        expect(
          () => GameController([Team.white]),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should throw assertion error with empty teams', () {
        expect(() => GameController([]), throwsA(isA<AssertionError>()));
      });
    });

    group('constructor.clear', () {
      test('should create game controller with empty board', () {
        final controller = GameController.clear(teams);

        expect(controller.teams, equals(teams));
        expect(controller.scores, hasLength(2));
        expect(controller.currentTeam, equals(Team.white));
        expect(controller.history, isEmpty);
      });

      test('should throw assertion error with single team', () {
        expect(
          () => GameController.clear([Team.white]),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('constructor.custom', () {
      test('should create game controller with custom pieces', () {
        final controller = GameController.custom(teams, {
          Position.e1: King.white,
          Position.e8: King.black,
        });

        expect(controller.teams, equals(teams));
        expect(controller.scores, hasLength(2));
        expect(controller.currentTeam, equals(Team.white));
        expect(controller.history, isEmpty);
        expect(controller.state[Position.e1].piece, isA<King>());
        expect(controller.state[Position.e8].piece, isA<King>());
      });

      test('should throw assertion error with single team', () {
        expect(
          () => GameController.custom([Team.white], {}),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('team management', () {
      late GameController controller;

      setUp(() {
        controller = GameController.clear(teams);
      });

      test('should return current team', () {
        expect(controller.currentTeam, equals(Team.white));
      });

      test('should return unmodifiable teams list', () {
        final teamsList = controller.teams;
        expect(() => teamsList.add(Team.white), throwsUnsupportedError);
      });
    });

    group('score management', () {
      late GameController controller;

      setUp(() {
        controller = GameController.clear(teams);
      });

      test('should return unmodifiable scores list', () {
        final scoresList = controller.scores;
        expect(
          () => scoresList.add(TeamScore(Team.white)),
          throwsUnsupportedError,
        );
      });

      test('should get team score using operator []', () {
        expect(controller[Team.white], equals(0));
        expect(controller[Team.black], equals(0));
      });
    });

    group('movesFor', () {
      late GameController controller;
      setUp(() {
        // Create a simple custom setup with just kings
        controller = GameController.custom(teams, {
          Position.e1: King.white,
          Position.e8: King.black,
        });
      });

      test('should return possible moves for specified team', () {
        final whiteMoves = controller.movesFor(team: Team.white);
        expect(whiteMoves, isNotEmpty);
        expect(whiteMoves.every((move) => move.team == Team.white), isTrue);
      });
      test('should return empty list for team with no pieces', () {
        final testController = GameController.custom(teams, {
          Position.e1: King.white,
        });

        final blackMoves = testController.movesFor(team: Team.black);
        expect(blackMoves, isEmpty);
      });
    });
    group('nextPossibleMoves', () {
      late GameController controller;

      setUp(() {
        controller = GameController.custom(teams, {
          Position.e1: King.white,
          Position.e8: King.black,
        });
      });

      test('should return possible moves for current team', () {
        final moves = controller.nextPossibleMoves;
        expect(moves, isNotEmpty);
        expect(
          moves.every((move) => move.team == controller.currentTeam),
          isTrue,
        );
      });
    });
    group('move', () {
      late GameController controller;

      setUp(() {
        controller = GameController.custom(teams, {
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d2: Pawn.white,
          Position.d7: Pawn.black,
        });
      });
      test('should execute move and switch teams', () {
        final initialTeam = controller.currentTeam;
        final move = Move.create(
          from: Position.d2,
          to: Position.d3,
          moving: Pawn.white,
        );

        controller.move(move);

        expect(controller.history, contains(move));
        expect(controller.currentTeam, isNot(equals(initialTeam)));
      });
      test('should update score on capture move', () {
        final initialWhiteScore = controller[Team.white];
        final captureMove = CaptureMove.create(
          from: Position.d2,
          to: Position.e3,
          moving: Pawn.white,
          captured: Pawn.black,
        );

        controller.move(captureMove);

        expect(controller[Team.white], greaterThan(initialWhiteScore));
      });
      test('should cycle through teams correctly', () {
        final move1 = Move.create(
          from: Position.d2,
          to: Position.d3,
          moving: Pawn.white,
        );
        final move2 = Move.create(
          from: Position.d7,
          to: Position.d6,
          moving: Pawn.black,
        );

        expect(controller.currentTeam, equals(Team.white));
        controller.move(move1);
        expect(controller.currentTeam, equals(Team.black));
        controller.move(move2);
        expect(controller.currentTeam, equals(Team.white));
      });
    });

    group('state', () {
      late GameController controller;

      setUp(() {
        controller = GameController.custom(teams, {
          Position.e1: King.white,
          Position.e8: King.black,
        });
      });

      test('should provide access to board state', () {
        expect(controller.state, isNotNull);
        expect(controller.state[Position.e1].piece, isA<King>());
        expect(controller.state[Position.e8].piece, isA<King>());
      });
    });

    group('history', () {
      test('should track move history', () {
        final controller = GameController.custom(teams, {
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d2: Pawn.white,
        });

        expect(controller.history, isEmpty);
        final move = Move.create(
          from: Position.d2,
          to: Position.d3,
          moving: Pawn.white,
        );

        controller.move(move);

        expect(controller.history, hasLength(1));
        expect(controller.history.first, equals(move));
      });
    });

    group('edge cases', () {
      test('should handle multiple teams correctly', () {
        final multipleTeams = [Team.white, Team.black];
        final controller = GameController.clear(multipleTeams);

        expect(controller.teams, equals(multipleTeams));
        expect(controller.scores, hasLength(2));
      });
      test('should maintain team order in cycling', () {
        final controller = GameController.custom(teams, {
          Position.e1: King.white,
          Position.e8: King.black,
          Position.d2: Pawn.white,
          Position.d7: Pawn.black,
        });
        // Make several moves to test team cycling
        for (int i = 0; i < 4; i++) {
          final currentTeam = controller.currentTeam;
          final expectedNextTeam =
              teams[(teams.indexOf(currentTeam) + 1) % teams.length];

          // Create a simple move for current team
          final possibleMoves = controller.nextPossibleMoves;

          if (possibleMoves.isNotEmpty) {
            controller.move(possibleMoves.first);
            expect(controller.currentTeam, equals(expectedNextTeam));
          }
        }
      });
    });

    group('Game state', () {
      test(
        'should set game state to teamWin after Scholar\'s Mate sequence',
        () {
          final controller = GameController(teams);

          // Scholar's Mate sequence
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
            BishopMove(
              from: Position.f1,
              to: Position.c4,
              moving: Bishop.white,
            ),
            KnightMove(
              from: Position.b8,
              to: Position.c6,
              moving: Knight.black,
            ),
            QueenMove(from: Position.d1, to: Position.h5, moving: Queen.white),
            KnightMove(
              from: Position.g8,
              to: Position.f6,
              moving: Knight.black,
            ),
            QueenCaptureMove(
              from: Position.h5,
              to: Position.f7,
              moving: Queen.white,
              captured: Pawn.black,
            ),
          ]; // Execute all moves except the last one
          for (int i = 0; i < moves.length - 1; i++) {
            controller.move(moves[i]);
            expect(controller.gameState, equals(GameState.inProgress));
          }

          // Execute the final move (checkmate)
          controller.move(moves.last);

          // Verify the game state is set to teamWin (checkmate)
          expect(controller.gameState, equals(GameState.teamWin));
          expect(controller.winner, equals(Team.white));
        },
      );
      test('set state to stalemate', () {
        final controller = GameController.custom(Team.values, {
          Position.h8: King.black,
          Position.h6: King.white,
          Position.f5: Queen.white,
        });

        final move = Move.create(
          from: Position.f5,
          to: Position.g5,
          moving: Queen.white,
        );

        controller.move(move);

        expect(controller.gameState, equals(GameState.stalemate));
      });
      test('set state to draw on insufficient material - King vs King', () {
        final controller = GameController.custom(Team.values, {
          Position.h5: King.white,
          Position.e8: King.black,
          // Last piece to be captured
          Position.h4: Pawn.black,
        });

        expect(controller.gameState, equals(GameState.inProgress));

        // Move to capture the last remaining piece besides kings
        final move = CaptureMove.create(
          from: Position.h5,
          to: Position.h4,
          moving: King.white,
          captured: Pawn.black,
        );

        controller.move(move);

        expect(controller.gameState, equals(GameState.draw));
      });

      test(
        'set state to draw on insufficient material - King vs King + Bishop',
        () {
          final controller = GameController.custom(Team.values, {
            Position.e1: King.black,
            Position.h5: King.white,
            Position.c1: Bishop.white,
            // Last piece to be captured
            Position.h4: Pawn.black,
          });

          expect(controller.gameState, equals(GameState.inProgress));

          // Move to capture the last piece besides kings and bishop
          final move = CaptureMove.create(
            from: Position.h5,
            to: Position.h4,
            moving: King.white,
            captured: Pawn.black,
          );

          controller.move(move);

          expect(controller.gameState, equals(GameState.draw));
        },
      );

      test(
        'set state to draw on insufficient material - King vs King + Knight',
        () {
          final controller = GameController.custom(Team.values, {
            Position.e1: King.black,
            Position.h5: King.white,
            Position.c1: Knight.white,
            // Last piece to be captured
            Position.h4: Pawn.black,
          });

          expect(controller.gameState, equals(GameState.inProgress));

          // Move to capture the last piece besides kings and knight
          final move = CaptureMove.create(
            from: Position.h5,
            to: Position.h4,
            moving: King.white,
            captured: Pawn.black,
          );

          controller.move(move);

          expect(controller.gameState, equals(GameState.draw));
        },
      );

      test('set state to draw on insufficient material - King+Bishop vs '
          'King+Bishop (same color)', () {
        final controller = GameController.custom(Team.values, {
          Position.e5: King.white,
          Position.c2: Bishop.white,
          Position.e8: King.black,
          Position.c8: Bishop.black,
          // Last piece to be captured
          Position.e4: Pawn.black,
        });

        expect(controller.gameState, equals(GameState.inProgress));

        // Move to capture the last piece besides kings and bishops
        final move = CaptureMove.create(
          from: Position.e5,
          to: Position.e4,
          moving: King.white,
          captured: Pawn.black,
        );

        controller.move(move);

        expect(controller.gameState, equals(GameState.draw));
      });

      test('should not set draw when King+Bishop vs King+Bishop on different '
          'colors', () {
        final controller = GameController.custom(Team.values, {
          Position.e5: King.white,
          Position.c1: Bishop.white,
          Position.e8: King.black,
          Position.c8: Bishop.black,
          // Last piece to be captured
          Position.e4: Pawn.black,
        });

        expect(controller.gameState, equals(GameState.inProgress));

        // Move to capture the last piece besides kings and bishops
        final move = CaptureMove.create(
          from: Position.e5,
          to: Position.e4,
          moving: King.white,
          captured: Pawn.black,
        );

        controller.move(move);

        expect(controller.gameState, equals(GameState.inProgress));
      });

      group('50-move rule', () {
        test('should initialize halfmove clock to 0 in new game', () {
          final controller = GameController(teams);
          expect(controller.halfmoveClock, equals(0));
        });
        test(
          'should increment halfmove clock on non-pawn, non-capture moves',
          () {
            final controller = GameController.custom(Team.values, {
              Position.e1: King.white,
              Position.e8: King.black,
              Position.b1: Knight.white,
              Position.b8: Knight.black,
            });

            expect(controller.halfmoveClock, equals(0));

            // Non-pawn, non-capture move
            final move1 = KnightMove(
              from: Position.b1,
              to: Position.c3,
              moving: Knight.white,
            );
            controller.move(move1);
            expect(controller.halfmoveClock, equals(1));

            // Another non-pawn, non-capture move
            final move2 = KnightMove(
              from: Position.b8,
              to: Position.c6,
              moving: Knight.black,
            );
            controller.move(move2);
            expect(controller.halfmoveClock, equals(2));
          },
        );
        test('should reset halfmove clock on pawn move', () {
          final controller = GameController.custom(Team.values, {
            Position.e1: King.white,
            Position.e8: King.black,
            Position.e2: Pawn.white,
            Position.b1: Knight.white,
          });

          // Make some non-pawn moves to increment clock
          final knightMove = KnightMove(
            from: Position.b1,
            to: Position.c3,
            moving: Knight.white,
          );
          controller.move(knightMove);
          expect(controller.halfmoveClock, equals(1));

          // Move pawn - should reset clock
          final pawnMove = PawnMove(
            from: Position.e2,
            to: Position.e3,
            moving: Pawn.white,
          );
          controller.move(pawnMove);
          expect(controller.halfmoveClock, equals(0));
        });
        test('should reset halfmove clock on capture move', () {
          final controller = GameController.custom(Team.values, {
            Position.e1: King.white,
            Position.e8: King.black,
            Position.c3: Knight.white,
            Position.d4: Pawn.black,
          });

          // Make a non-pawn move to increment clock
          final knightMove = KnightMove(
            from: Position.c3,
            to: Position.e2,
            moving: Knight.white,
          );
          controller.move(knightMove);
          expect(controller.halfmoveClock, equals(1));

          // Make a capture move - should reset clock
          final captureMove = CaptureMove.create(
            from: Position.e2,
            to: Position.d4,
            moving: Knight.white,
            captured: Pawn.black,
          );
          controller.move(captureMove);
          expect(controller.halfmoveClock, equals(0));
        });
        test('should trigger draw when 50-move rule is reached', () {
          final controller = GameController.custom(Team.values, {
            Position.a1: King.white,
            Position.h8: King.black,
            Position.a4: Pawn.white,
            Position.a5: Pawn.black,
          });

          expect(controller.gameState, equals(GameState.inProgress));

          // Simulate 50 full moves (100 half-moves) without pawn moves or
          // captures Kings moving back and forth
          for (int i = 0; i < 50; i++) {
            // White king moves
            final whiteFrom = switch (i % 4) {
              0 => Position.a1,
              1 => Position.a2,
              2 => Position.b2,
              int _ => Position.b1,
            };
            final whiteTo = switch (i % 4) {
              0 => Position.a2,
              1 => Position.b2,
              2 => Position.b1,
              int _ => Position.a1,
            };
            final whiteMove = KingMove(
              from: whiteFrom,
              to: whiteTo,
              moving: King.white,
            );
            controller.move(whiteMove);

            // Check that we haven't reached the limit yet (except on the last
            // iteration)
            if (controller.halfmoveClock < 100) {
              expect(controller.gameState, equals(GameState.inProgress));
            }

            // Black king moves
            final blackFrom = switch (i % 4) {
              0 => Position.h8,
              1 => Position.h7,
              2 => Position.g7,
              int _ => Position.g8,
            };
            final blackTo = switch (i % 4) {
              0 => Position.h7,
              1 => Position.g7,
              2 => Position.g8,
              int _ => Position.h8,
            };
            final blackMove = KingMove(
              from: blackFrom,
              to: blackTo,
              moving: King.black,
            );
            controller.move(blackMove);
          }

          // After 100 half-moves, should trigger draw
          expect(controller.halfmoveClock, equals(100));
          expect(controller.gameState, equals(GameState.draw));
        });
        test('should calculate correct halfmove clock from move history', () {
          // Create a move history with mixed pawn moves and piece moves
          // Starting from standard board position
          final moveHistory = <Move>[
            PawnInitialMove(
              from: Position.e2,
              to: Position.e4,
              moving: Pawn.white,
            ), // Reset clock
            PawnInitialMove(
              from: Position.e7,
              to: Position.e5,
              moving: Pawn.black,
            ), // Reset clock
            KnightMove(
              from: Position.g1,
              to: Position.f3,
              moving: Knight.white,
            ), // Clock = 1
            KnightMove(
              from: Position.b8,
              to: Position.c6,
              moving: Knight.black,
            ), // Clock = 2
            BishopMove(
              from: Position.f1,
              to: Position.c4,
              moving: Bishop.white,
            ), // Clock = 3
          ];

          final controller = GameController(teams, moveHistory: moveHistory);
          expect(controller.halfmoveClock, equals(3));
        });
        test('should handle capture in move history for halfmove clock', () {
          final moveHistory = <Move>[
            PawnInitialMove(
              from: Position.e2,
              to: Position.e4,
              moving: Pawn.white,
            ), // Reset clock
            PawnInitialMove(
              from: Position.d7,
              to: Position.d5,
              moving: Pawn.black,
            ), // Reset clock
            KnightMove(
              from: Position.g1,
              to: Position.f3,
              moving: Knight.white,
            ), // Clock = 1
            KnightMove(
              from: Position.b8,
              to: Position.c6,
              moving: Knight.black,
            ), // Clock = 2
            PawnCaptureMove(
              from: Position.e4,
              to: Position.d5,
              moving: Pawn.white,
              captured: Pawn.black,
            ), // Reset clock
            KnightMove(
              from: Position.c6,
              to: Position.d4,
              moving: Knight.black,
            ), // Clock = 1
          ];

          final controller = GameController(teams, moveHistory: moveHistory);
          expect(controller.halfmoveClock, equals(1));
        });
        test('should not trigger 50-move rule before reaching the limit', () {
          final controller = GameController.custom(Team.values, {
            Position.a1: King.white,
            Position.h8: King.black,
            Position.a4: Pawn.white,
            Position.a5: Pawn.black,
          });

          // Make 99 half-moves (just under the limit of 100)
          for (int i = 0; i < 49; i++) {
            final whiteFrom = switch (i % 4) {
              0 => Position.a1,
              1 => Position.a2,
              2 => Position.b2,
              int _ => Position.b1,
            };
            final whiteTo = switch (i % 4) {
              0 => Position.a2,
              1 => Position.b2,
              2 => Position.b1,
              int _ => Position.a1,
            };
            final whiteMove = KingMove(
              from: whiteFrom,
              to: whiteTo,
              moving: King.white,
            );
            controller.move(whiteMove);

            final blackFrom = switch (i % 4) {
              0 => Position.h8,
              1 => Position.h7,
              2 => Position.g7,
              int _ => Position.g8,
            };
            final blackTo = switch (i % 4) {
              0 => Position.h7,
              1 => Position.g7,
              2 => Position.g8,
              int _ => Position.h8,
            };
            final blackMove = KingMove(
              from: blackFrom,
              to: blackTo,
              moving: King.black,
            );
            controller.move(blackMove);
          }

          // Make one more white move to reach 99 half-moves
          final finalWhiteMove = KingMove(
            from: Position.a2,
            to: Position.b2,
            moving: King.white,
          );
          controller.move(finalWhiteMove);

          expect(controller.halfmoveClock, equals(99));
          expect(controller.gameState, equals(GameState.inProgress));
        });
      });
    });
  });
}
