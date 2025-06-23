import 'package:chess_logic/src/controller/capture.dart';
import 'package:chess_logic/src/controller/team_score.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:chess_logic/src/utility/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Extensions', () {
    group('IterableCaptureExtension', () {
      group('totalValue', () {
        test('should return 0 for empty captures list', () {
          final captures = <Capture>[];

          expect(captures.totalValue, equals(0));
        });

        test('should return correct total value for single capture', () {
          final capture = _createCapture(
            captured: Pawn.black,
            captor: Queen.white,
          );
          final captures = [capture];

          expect(captures.totalValue, equals(1)); // Pawn value
        });

        test('should return correct total value for multiple captures', () {
          final pawnCapture = _createCapture(
            captured: Pawn.black,
            captor: Queen.white,
          );
          final rookCapture = _createCapture(
            captured: Rook.black,
            captor: Queen.white,
          );
          final queenCapture = _createCapture(
            captured: Queen.black,
            captor: Rook.white,
          );
          final captures = [pawnCapture, rookCapture, queenCapture];

          // Pawn (1) + Rook (5) + Queen (9) = 15
          expect(captures.totalValue, equals(15));
        });

        test('should handle captures with zero value pieces correctly', () {
          final kingCapture = _createCapture(
            captured: King.black,
            captor: Queen.white,
          );
          final pawnCapture = _createCapture(
            captured: Pawn.black,
            captor: Queen.white,
          );
          final captures = [kingCapture, pawnCapture];

          // King (0) + Pawn (1) = 1
          expect(captures.totalValue, equals(1));
        });

        test('should work with Set<Capture>', () {
          final capture1 = _createCapture(
            captured: Pawn.black,
            captor: Queen.white,
          );
          final capture2 = _createCapture(
            captured: Rook.black,
            captor: Bishop.white,
          );
          final capturesSet = {capture1, capture2};

          expect(capturesSet.totalValue, equals(6)); // Pawn (1) + Rook (5)
        });
      });
    });

    group('ListSquareExtension', () {
      late List<Square> squares;

      setUp(() {
        squares = [
          const EmptySquare(Position.a1),
          const OccupiedSquare(Position.b1, Rook.white),
          const EmptySquare(Position.c1),
          const OccupiedSquare(Position.d1, Queen.white),
        ];
      });

      group('at', () {
        test('should return correct index for existing position', () {
          final index = squares.at(Position.b1);

          expect(index, equals(1));
          expect(squares[index].position, equals(Position.b1));
        });

        test('should return correct index for first position', () {
          final index = squares.at(Position.a1);

          expect(index, equals(0));
        });

        test('should return correct index for last position', () {
          final index = squares.at(Position.d1);

          expect(index, equals(3));
        });

        test('should throw ArgumentError for non-existent position', () {
          expect(
            () => squares.at(Position.e1),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('No square found at position e1'),
              ),
            ),
          );
        });

        test('should work with empty list', () {
          final emptySquares = <Square>[];

          expect(
            () => emptySquares.at(Position.a1),
            throwsA(isA<ArgumentError>()),
          );
        });
      });

      group('replace', () {
        test('should replace square at existing position', () {
          const newSquare = OccupiedSquare(Position.a1, Pawn.black);

          squares.replace(newSquare);

          expect(squares[0], equals(newSquare));
          expect(squares[0].piece, isA<Pawn>());
          expect(squares[0].piece!.team, equals(Team.black));
        });

        test('should replace occupied square with empty square', () {
          const newSquare = EmptySquare(Position.b1);

          squares.replace(newSquare);

          expect(squares[1], equals(newSquare));
          expect(squares[1].isEmpty, isTrue);
        });

        test('should replace empty square with occupied square', () {
          const newSquare = OccupiedSquare(Position.c1, Knight.black);

          squares.replace(newSquare);

          expect(squares[2], equals(newSquare));
          expect(squares[2].isOccupied, isTrue);
          expect(squares[2].piece, isA<Knight>());
        });

        test('should throw ArgumentError when position not found', () {
          const newSquare = EmptySquare(Position.e1);

          expect(
            () => squares.replace(newSquare),
            throwsA(isA<ArgumentError>()),
          );
        });

        test('should maintain list length after replacement', () {
          final originalLength = squares.length;
          const newSquare = OccupiedSquare(Position.a1, Bishop.white);

          squares.replace(newSquare);

          expect(squares.length, equals(originalLength));
        });
      });
    });

    group('IterableMoveExtension', () {
      group('scores', () {
        test('should return empty list for null moves', () {
          const Iterable<Move>? moves = null;

          final result = moves.scores;

          expect(result, isEmpty);
        });

        test('should return empty list for empty moves list', () {
          final moves = <Move>[];

          final result = moves.scores;

          expect(result, isEmpty);
        });

        test('should return empty list for moves without captures', () {
          final moves = <Move>[
            PawnInitialMove(
              from: Position.e2,
              to: Position.e4,
              moving: Pawn.white,
            ),
            KnightMove(
              from: Position.b1,
              to: Position.c3,
              moving: Knight.white,
            ),
          ];

          final result = moves.scores;

          expect(result, isEmpty);
        });

        test('should create team scores for single capture move', () {
          final captureMove = PawnCaptureMove(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn.white,
            captured: Pawn.black,
          );
          final moves = [captureMove];

          final result = moves.scores;

          expect(result, hasLength(1));
          expect(result.first.team, equals(Team.white));
          expect(result.first.score, equals(1)); // Pawn value
          expect(result.first.capturedPieces, hasLength(1));
          expect(result.first.capturedPieces.first, isA<Pawn>());
        });

        test('should group captures by team', () {
          final whiteCaptureMove = PawnCaptureMove(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn.white,
            captured: Pawn.black,
          );
          final blackCaptureMove = PawnCaptureMove(
            from: Position.d6,
            to: Position.e5,
            moving: Pawn.black,
            captured: Rook.white,
          );
          final moves = [whiteCaptureMove, blackCaptureMove];

          final result = moves.scores;

          expect(result, hasLength(2));

          final whiteScore = result.firstWhere(
            (score) => score.team == Team.white,
          );
          final blackScore = result.firstWhere(
            (score) => score.team == Team.black,
          );

          expect(whiteScore.score, equals(1)); // Pawn
          expect(blackScore.score, equals(5)); // Rook
        });

        test('should accumulate multiple captures for same team', () {
          final captureMove1 = PawnCaptureMove(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn.white,
            captured: Pawn.black,
          );
          final captureMove2 = QueenCaptureMove(
            from: Position.d1,
            to: Position.d6,
            moving: Queen.white,
            captured: Rook.black,
          );
          final moves = <CaptureMove>[captureMove1, captureMove2];

          final result = moves.scores;

          expect(result, hasLength(1));
          expect(result.first.team, equals(Team.white));
          expect(result.first.score, equals(6)); // Pawn (1) + Rook (5)
          expect(result.first.capturedPieces, hasLength(2));
        });

        test('should handle mixed capture and non-capture moves', () {
          final regularMove = PawnInitialMove(
            from: Position.e2,
            to: Position.e4,
            moving: Pawn.white,
          );
          final captureMove = PawnCaptureMove(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn.white,
            captured: Pawn.black,
          );
          final moves = [regularMove, captureMove];

          final result = moves.scores;

          expect(result, hasLength(1));
          expect(result.first.team, equals(Team.white));
          expect(result.first.score, equals(1)); // Only the captured pawn
        });

        test('should handle different types of capture moves', () {
          final pawnCapture = PawnCaptureMove(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn.white,
            captured: Pawn.black,
          );
          final queenCapture = QueenCaptureMove(
            from: Position.d1,
            to: Position.h5,
            moving: Queen.white,
            captured: Bishop.black,
          );
          final rookCapture = RookCaptureMove(
            from: Position.a1,
            to: Position.a8,
            moving: Rook.white,
            captured: Knight.black,
          );
          final moves = <CaptureMove>[pawnCapture, queenCapture, rookCapture];

          final result = moves.scores;

          expect(result, hasLength(1));
          expect(result.first.team, equals(Team.white));
          expect(
            result.first.score,
            equals(7),
          ); // Pawn (1) + Bishop (3) + Knight (3)
          expect(result.first.capturedPieces, hasLength(3));
        });
      });
    });

    group('ListTeamScoreExtension', () {
      group('addMissing', () {
        test('should add missing teams to empty list', () {
          final teamScores = <TeamScore>[];
          final teams = [Team.white, Team.black];

          teamScores.addMissing(teams);

          expect(teamScores, hasLength(2));
          expect(
            teamScores.map((score) => score.team),
            containsAll([Team.white, Team.black]),
          );
          for (final score in teamScores) {
            expect(score.capturedPieces, isEmpty);
            expect(score.score, equals(0));
          }
        });

        test('should add only missing teams when some already exist', () {
          final teamScores = [TeamScore(Team.white)];
          final teams = [Team.white, Team.black];

          teamScores.addMissing(teams);

          expect(teamScores, hasLength(2));
          expect(
            teamScores.map((score) => score.team),
            containsAll([Team.white, Team.black]),
          );

          // White team should be the original one
          final whiteScore = teamScores.firstWhere(
            (score) => score.team == Team.white,
          );
          final blackScore = teamScores.firstWhere(
            (score) => score.team == Team.black,
          );

          expect(whiteScore.capturedPieces, isEmpty);
          expect(blackScore.capturedPieces, isEmpty);
        });

        test('should not add teams that already exist', () {
          final capture = _createCapture(
            captured: Pawn.black,
            captor: Queen.white,
          );
          final whiteScore = TeamScore(Team.white, captures: [capture]);
          final teamScores = [whiteScore];
          final teams = [Team.white];

          teamScores.addMissing(teams);

          expect(teamScores, hasLength(1));
          expect(teamScores.first.team, equals(Team.white));
          expect(
            teamScores.first.score,
            equals(1),
          ); // Should preserve existing captures
          expect(teamScores.first.capturedPieces, hasLength(1));
        });

        test('should handle empty teams list', () {
          final teamScores = [TeamScore(Team.white)];
          final teams = <Team>[];

          teamScores.addMissing(teams);

          expect(teamScores, hasLength(1));
          expect(teamScores.first.team, equals(Team.white));
        });

        test('should handle empty teams and empty scores', () {
          final teamScores = <TeamScore>[];
          final teams = <Team>[];

          teamScores.addMissing(teams);

          expect(teamScores, isEmpty);
        });

        test(
          'should preserve existing team scores when adding missing teams',
          () {
            final capture1 = _createCapture(
              captured: Pawn.black,
              captor: Queen.white,
            );

            final whiteScore = TeamScore(Team.white, captures: [capture1]);
            final teamScores = [whiteScore];
            final teams = [Team.white, Team.black];

            teamScores.addMissing(teams);

            expect(teamScores, hasLength(2));

            final preservedWhiteScore = teamScores.firstWhere(
              (score) => score.team == Team.white,
            );
            final newBlackScore = teamScores.firstWhere(
              (score) => score.team == Team.black,
            );

            expect(preservedWhiteScore.score, equals(1)); // Preserved
            expect(preservedWhiteScore.capturedPieces, hasLength(1));
            expect(newBlackScore.score, equals(0)); // New, empty
            expect(newBlackScore.capturedPieces, isEmpty);
          },
        );

        test('should handle teams in different order', () {
          final blackScore = TeamScore(Team.black);
          final teamScores = [blackScore];
          final teams = [Team.white, Team.black]; // White first, black second

          teamScores.addMissing(teams);

          expect(teamScores, hasLength(2));
          expect(
            teamScores.map((score) => score.team),
            containsAll([Team.white, Team.black]),
          );
        });
      });
    });

    group('IterableTeamExtension', () {
      group('scores', () {
        test('should create empty team scores for empty team list', () {
          final teams = <Team>[];

          final result = teams.scores;

          expect(result, isEmpty);
        });

        test('should create team score for single team', () {
          final teams = [Team.white];

          final result = teams.scores;

          expect(result, hasLength(1));
          expect(result.first.team, equals(Team.white));
          expect(result.first.capturedPieces, isEmpty);
          expect(result.first.score, equals(0));
        });

        test('should create team scores for both teams', () {
          final teams = [Team.white, Team.black];

          final result = teams.scores;

          expect(result, hasLength(2));
          expect(
            result.map((score) => score.team),
            containsAll([Team.white, Team.black]),
          );

          for (final score in result) {
            expect(score.capturedPieces, isEmpty);
            expect(score.score, equals(0));
          }
        });

        test('should create team scores in same order as input', () {
          final teams = [Team.black, Team.white]; // Black first

          final result = teams.scores;

          expect(result, hasLength(2));
          expect(result[0].team, equals(Team.black));
          expect(result[1].team, equals(Team.white));
        });

        test('should handle duplicate teams by creating separate scores', () {
          final teams = [Team.white, Team.white, Team.black];

          final result = teams.scores;

          expect(result, hasLength(3));
          expect(
            result.where((score) => score.team == Team.white),
            hasLength(2),
          );
          expect(
            result.where((score) => score.team == Team.black),
            hasLength(1),
          );
        });

        test('should work with Set<Team>', () {
          final teams = {Team.white, Team.black};

          final result = teams.scores;

          expect(result, hasLength(2));
          expect(
            result.map((score) => score.team),
            containsAll([Team.white, Team.black]),
          );
        });

        test('should create independent team scores', () {
          final teams = [Team.white, Team.black];

          final result = teams.scores;

          // Modify one score
          final capture = _createCapture(
            captured: Pawn.black,
            captor: Queen.white,
          );
          result.first.capture(capture);

          // Other score should be unaffected
          expect(result.first.score, equals(1));
          expect(result.last.score, equals(0));
        });
      });
    });
  });
}

/// Helper function to create a Capture for testing
Capture _createCapture<P extends Piece, C extends Piece>({
  required C captured,
  required P captor,
}) {
  // Use different positions based on piece type to ensure valid moves
  Position from;
  Position to;

  if (captor is Rook) {
    from = Position.a1;
    to = Position.a8; // Vertical move for rook
  } else if (captor is Bishop) {
    from = Position.a1;
    to = Position.h8; // Diagonal move for bishop
  } else if (captor is Knight) {
    from = Position.b1;
    to = Position.c3; // L-shaped move for knight
  } else if (captor is Queen) {
    from = Position.d1;
    to = Position.d8; // Vertical move for queen
  } else if (captor is King) {
    from = Position.e1;
    to = Position.e2; // One square move for king
  } else {
    // Default for pawns and other pieces - diagonal capture for pawn
    from = Position.e2;
    to = Position.d3; // Diagonal capture move
  }

  final move = CaptureMove<P, C>.create(
    from: from,
    to: to,
    moving: captor,
    captured: captured,
  );
  return Capture(move);
}
