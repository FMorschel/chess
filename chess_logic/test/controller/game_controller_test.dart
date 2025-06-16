import 'package:chess_logic/src/controller/game_controller.dart';
import 'package:chess_logic/src/controller/game_state.dart';
import 'package:chess_logic/src/controller/team_score.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/position/rank.dart';
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
          from: Position.fromAlgebraic('e2'),
          to: Position.fromAlgebraic('e3'),
          moving: Pawn(Team.white),
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
        final customPieces = <Position, Piece>{
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
        };

        final controller = GameController.custom(teams, customPieces);

        expect(controller.teams, equals(teams));
        expect(controller.scores, hasLength(2));
        expect(controller.currentTeam, equals(Team.white));
        expect(controller.history, isEmpty);
        expect(
          controller.state[Position.fromAlgebraic('e1')].piece,
          isA<King>(),
        );
        expect(
          controller.state[Position.fromAlgebraic('e8')].piece,
          isA<King>(),
        );
      });

      test('should throw assertion error with single team', () {
        expect(
          () => GameController.custom([Team.white], {}),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('constructor.import', () {
      test(
        'should create game controller from import data with teams only',
        () {
          final data = {
            'teams': {'0': 'White', '1': 'Black'},
          };

          final controller = GameController.import(data);

          expect(controller.teams, hasLength(2));
          expect(
            controller.teams.map((t) => t.name),
            containsAll(['White', 'Black']),
          );
        },
      );
      test(
        'should create game controller from import data with custom pieces',
        () {
          final data = {
            'teams': {'0': 'White', '1': 'Black'},
            'custom': {'e1': 'White - K', 'e8': 'Black - K'},
          };

          final controller = GameController.import(data);

          expect(controller.teams, hasLength(2));
          expect(
            controller.state[Position.fromAlgebraic('e1')].piece,
            isA<King>(),
          );
          expect(
            controller.state[Position.fromAlgebraic('e8')].piece,
            isA<King>(),
          );
        },
      );
      test('should handle empty import data', () {
        final data = {
          'teams': {'0': 'White', '1': 'Black'},
        };

        final controller = GameController.import(data);

        expect(controller.teams, hasLength(2));
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
        final customPieces = <Position, Piece>{
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
        };
        controller = GameController.custom(teams, customPieces);
      });

      test('should return possible moves for specified team', () {
        final whiteMoves = controller.movesFor(team: Team.white);
        expect(whiteMoves, isNotEmpty);
        expect(whiteMoves.every((move) => move.team == Team.white), isTrue);
      });

      test('should return empty list for team with no pieces', () {
        final customPieces = <Position, Piece>{
          Position.fromAlgebraic('e1'): King(Team.white),
        };
        final testController = GameController.custom(teams, customPieces);

        final blackMoves = testController.movesFor(team: Team.black);
        expect(blackMoves, isEmpty);
      });
    });

    group('nextPossibleMoves', () {
      late GameController controller;

      setUp(() {
        final customPieces = <Position, Piece>{
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
        };
        controller = GameController.custom(teams, customPieces);
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
        final customPieces = <Position, Piece>{
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d2'): Pawn(Team.white),
          Position.fromAlgebraic('d7'): Pawn(Team.black),
        };
        controller = GameController.custom(teams, customPieces);
      });
      test('should execute move and switch teams', () {
        final initialTeam = controller.currentTeam;
        final move = Move.create(
          from: Position.fromAlgebraic('d2'),
          to: Position.fromAlgebraic('d3'),
          moving: Pawn(Team.white),
        );

        controller.move(move);

        expect(controller.history, contains(move));
        expect(controller.currentTeam, isNot(equals(initialTeam)));
      });
      test('should update score on capture move', () {
        final initialWhiteScore = controller[Team.white];
        final captureMove = CaptureMove.create(
          from: Position.fromAlgebraic('d2'),
          to: Position.fromAlgebraic('e3'),
          moving: Pawn(Team.white),
          captured: Pawn(Team.black),
        );

        controller.move(captureMove);

        expect(controller[Team.white], greaterThan(initialWhiteScore));
      });
      test('should cycle through teams correctly', () {
        final move1 = Move.create(
          from: Position.fromAlgebraic('d2'),
          to: Position.fromAlgebraic('d3'),
          moving: Pawn(Team.white),
        );
        final move2 = Move.create(
          from: Position.fromAlgebraic('d7'),
          to: Position.fromAlgebraic('d6'),
          moving: Pawn(Team.black),
        );

        expect(controller.currentTeam, equals(Team.white));
        controller.move(move1);
        expect(controller.currentTeam, equals(Team.black));
        controller.move(move2);
        expect(controller.currentTeam, equals(Team.white));
      });
    });

    group('export', () {
      test('should export game state with custom pieces', () {
        final customPieces = <Position, Piece>{
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
        };
        final controller = GameController.custom(teams, customPieces);

        final exported = controller.export;

        expect(exported, contains('custom'));
        expect(exported, contains('teams'));
        expect(exported['custom'], isNotEmpty);
        expect(exported['teams'], isNotEmpty);
      });

      test('should export game state with move history', () {
        final customPieces = <Position, Piece>{
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d2'): Pawn(Team.white),
        };
        final testController = GameController.custom(teams, customPieces);

        final exported = testController.export;

        expect(exported, contains('teams'));
        if (testController.nextPossibleMoves.isNotEmpty) {
          expect(exported, contains('history'));
        }
      });

      test('should export minimal data when no custom pieces or history', () {
        final exported = GameController.clear(teams).export;

        expect(exported, contains('teams'));
        expect(exported.containsKey('custom'), isFalse);
      });
    });

    group('state', () {
      late GameController controller;

      setUp(() {
        final customPieces = <Position, Piece>{
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
        };
        controller = GameController.custom(teams, customPieces);
      });

      test('should provide access to board state', () {
        expect(controller.state, isNotNull);
        expect(
          controller.state[Position.fromAlgebraic('e1')].piece,
          isA<King>(),
        );
        expect(
          controller.state[Position.fromAlgebraic('e8')].piece,
          isA<King>(),
        );
      });
    });

    group('history', () {
      test('should track move history', () {
        final customPieces = <Position, Piece>{
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d2'): Pawn(Team.white),
        };
        final controller = GameController.custom(teams, customPieces);

        expect(controller.history, isEmpty);
        final move = Move.create(
          from: Position.fromAlgebraic('d2'),
          to: Position.fromAlgebraic('d3'),
          moving: Pawn(Team.white),
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
        final customPieces = <Position, Piece>{
          Position.fromAlgebraic('e1'): King(Team.white),
          Position.fromAlgebraic('e8'): King(Team.black),
          Position.fromAlgebraic('d2'): Pawn(Team.white),
          Position.fromAlgebraic('d7'): Pawn(Team.black),
        };
        final controller = GameController.custom(teams, customPieces);
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
              from: Position._(File.e, Rank.two),
              to: Position._(File.e, Rank.four),
              moving: Pawn(Team.white),
            ),
            PawnInitialMove(
              from: Position._(File.e, Rank.seven),
              to: Position._(File.e, Rank.five),
              moving: Pawn(Team.black),
            ),
            BishopMove(
              from: Position._(File.f, Rank.one),
              to: Position._(File.c, Rank.four),
              moving: Bishop(Team.white),
            ),
            KnightMove(
              from: Position._(File.b, Rank.eight),
              to: Position._(File.c, Rank.six),
              moving: Knight(Team.black),
            ),
            QueenMove(
              from: Position._(File.d, Rank.one),
              to: Position._(File.h, Rank.five),
              moving: Queen(Team.white),
            ),
            KnightMove(
              from: Position._(File.g, Rank.eight),
              to: Position._(File.f, Rank.six),
              moving: Knight(Team.black),
            ),
            QueenCaptureMove(
              from: Position._(File.h, Rank.five),
              to: Position._(File.f, Rank.seven),
              moving: Queen(Team.white),
              captured: Pawn(Team.black),
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
          Position._(File.h, Rank.eight): King(Team.black),
          Position._(File.h, Rank.six): King(Team.white),
          Position._(File.f, Rank.five): Queen(Team.white),
        });

        final move = Move.create(
          from: Position._(File.f, Rank.five),
          to: Position._(File.g, Rank.five),
          moving: Queen(Team.white),
        );

        controller.move(move);

        expect(controller.gameState, equals(GameState.stalemate));
      });
      test('set state to draw on insufficient material - King vs King', () {
        final controller = GameController.custom(Team.values, {
          Position._(File.h, Rank.five): King(Team.white),
          Position._(File.e, Rank.eight): King(Team.black),
          // Last piece to be captured
          Position._(File.h, Rank.four): Pawn(Team.black),
        });

        expect(controller.gameState, equals(GameState.inProgress));

        // Move to capture the last remaining piece besides kings
        final move = CaptureMove.create(
          from: Position._(File.h, Rank.five),
          to: Position._(File.h, Rank.four),
          moving: King(Team.white),
          captured: Pawn(Team.black),
        );

        controller.move(move);

        expect(controller.gameState, equals(GameState.draw));
      });

      test(
        'set state to draw on insufficient material - King vs King + Bishop',
        () {
          final controller = GameController.custom(Team.values, {
            Position._(File.e, Rank.one): King(Team.black),
            Position._(File.h, Rank.five): King(Team.white),
            Position._(File.c, Rank.one): Bishop(Team.white),
            // Last piece to be captured
            Position._(File.h, Rank.four): Pawn(Team.black),
          });

          expect(controller.gameState, equals(GameState.inProgress));

          // Move to capture the last piece besides kings and bishop
          final move = CaptureMove.create(
            from: Position._(File.h, Rank.five),
            to: Position._(File.h, Rank.four),
            moving: King(Team.white),
            captured: Pawn(Team.black),
          );

          controller.move(move);

          expect(controller.gameState, equals(GameState.draw));
        },
      );

      test(
        'set state to draw on insufficient material - King vs King + Knight',
        () {
          final controller = GameController.custom(Team.values, {
            Position._(File.e, Rank.one): King(Team.black),
            Position._(File.h, Rank.five): King(Team.white),
            Position._(File.c, Rank.one): Knight(Team.white),
            // Last piece to be captured
            Position._(File.h, Rank.four): Pawn(Team.black),
          });

          expect(controller.gameState, equals(GameState.inProgress));

          // Move to capture the last piece besides kings and knight
          final move = CaptureMove.create(
            from: Position._(File.h, Rank.five),
            to: Position._(File.h, Rank.four),
            moving: King(Team.white),
            captured: Pawn(Team.black),
          );

          controller.move(move);

          expect(controller.gameState, equals(GameState.draw));
        },
      );

      test('set state to draw on insufficient material - King+Bishop vs '
          'King+Bishop (same color)', () {
        final controller = GameController.custom(Team.values, {
          Position._(File.e, Rank.five): King(Team.white),
          Position._(File.c, Rank.two): Bishop(Team.white),
          Position._(File.e, Rank.eight): King(Team.black),
          Position._(File.c, Rank.eight): Bishop(Team.black),
          // Last piece to be captured
          Position._(File.e, Rank.four): Pawn(Team.black),
        });

        expect(controller.gameState, equals(GameState.inProgress));

        // Move to capture the last piece besides kings and bishops
        final move = CaptureMove.create(
          from: Position._(File.e, Rank.five),
          to: Position._(File.e, Rank.four),
          moving: King(Team.white),
          captured: Pawn(Team.black),
        );

        controller.move(move);

        expect(controller.gameState, equals(GameState.draw));
      });

      test(
        'should not set draw when King+Bishop vs King+Bishop on different colors',
        () {
          final controller = GameController.custom(Team.values, {
            Position._(File.e, Rank.five): King(Team.white),
            Position._(File.c, Rank.one): Bishop(Team.white),
            Position._(File.e, Rank.eight): King(Team.black),
            Position._(File.c, Rank.eight): Bishop(Team.black),
            // Last piece to be captured
            Position._(File.e, Rank.four): Pawn(Team.black),
          });

          expect(controller.gameState, equals(GameState.inProgress));

          // Move to capture the last piece besides kings and bishops
          final move = CaptureMove.create(
            from: Position._(File.e, Rank.five),
            to: Position._(File.e, Rank.four),
            moving: King(Team.white),
            captured: Pawn(Team.black),
          );

          controller.move(move);

          expect(controller.gameState, equals(GameState.inProgress));
        },
      );
    });
  });
}
