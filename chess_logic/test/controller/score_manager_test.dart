import 'package:chess_logic/src/controller/score_manager.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('ScoreManager', () {
    late List<Team> teams;
    late ScoreManager scoreManager;

    setUp(() {
      teams = [Team.white, Team.black];
      scoreManager = ScoreManager.empty(teams);
    });

    group('constructor', () {
      test('should create ScoreManager with empty scores', () {
        expect(scoreManager.scores, hasLength(2));
        expect(scoreManager[Team.white], equals(0));
        expect(scoreManager[Team.black], equals(0));
      });
      test('should create ScoreManager from move history', () {
        final moveHistory = <Move>[
          PawnInitialMove(
            from: Position.e2,
            to: Position.e4,
            moving: Pawn.white,
          ),
          PawnCaptureMove(
            from: Position.d7,
            to: Position.e6,
            moving: Pawn.black,
            captured: Pawn.white,
          ),
        ];

        final managerWithHistory = ScoreManager(
          teams,
          moveHistory: moveHistory,
        );

        expect(managerWithHistory[Team.black], equals(1)); // Captured a pawn
        expect(managerWithHistory[Team.white], equals(0));
      });
    });

    group('processCapture', () {
      test('should process capture and update team score', () {
        final captureMove = PawnCaptureMove(
          from: Position.e4,
          to: Position.d5,
          moving: Pawn.white,
          captured: Pawn.black,
        );

        scoreManager.processCapture(captureMove);

        expect(scoreManager[Team.white], equals(1));
        expect(scoreManager[Team.black], equals(0));
      });

      test('should process multiple captures', () {
        final pawnCapture = PawnCaptureMove(
          from: Position.e4,
          to: Position.d5,
          moving: Pawn.white,
          captured: Pawn.black,
        );
        final queenCapture = QueenCaptureMove(
          from: Position.d1,
          to: Position.d8,
          moving: Queen.white,
          captured: Queen.black,
        );

        scoreManager.processCapture(pawnCapture);
        scoreManager.processCapture(queenCapture);

        expect(scoreManager[Team.white], equals(10)); // Pawn (1) + Queen (9)
      });
    });

    group('leadingTeam', () {
      test('should return null when scores are tied', () {
        expect(scoreManager.leadingTeam, isNull);
      });

      test('should return team with highest score', () {
        final captureMove = PawnCaptureMove(
          from: Position.e4,
          to: Position.d5,
          moving: Pawn.white,
          captured: Pawn.black,
        );

        scoreManager.processCapture(captureMove);

        expect(scoreManager.leadingTeam, equals(Team.white));
      });
    });

    group('scoreDifference', () {
      test('should calculate correct score difference', () {
        final whitePawnCapture = PawnCaptureMove(
          from: Position.e4,
          to: Position.d5,
          moving: Pawn.white,
          captured: Pawn.black,
        );
        final blackQueenCapture = QueenCaptureMove(
          from: Position.d8,
          to: Position.d1,
          moving: Queen.black,
          captured: Queen.white,
        );

        scoreManager.processCapture(whitePawnCapture);
        scoreManager.processCapture(blackQueenCapture);

        expect(
          scoreManager.scoreDifference(Team.black, Team.white),
          equals(8),
        ); // 9 - 1
        expect(
          scoreManager.scoreDifference(Team.white, Team.black),
          equals(-8),
        ); // 1 - 9
      });
    });

    group('teamsByScore', () {
      test('should return teams sorted by score descending', () {
        final whitePawnCapture = PawnCaptureMove(
          from: Position.e4,
          to: Position.d5,
          moving: Pawn.white,
          captured: Pawn.black,
        );
        final blackQueenCapture = QueenCaptureMove(
          from: Position.d8,
          to: Position.d1,
          moving: Queen.black,
          captured: Queen.white,
        );

        scoreManager.processCapture(whitePawnCapture);
        scoreManager.processCapture(blackQueenCapture);

        final sortedTeams = scoreManager.teamsByScore;
        expect(sortedTeams.first.team, equals(Team.black));
        expect(sortedTeams.last.team, equals(Team.white));
      });
    });

    group('capturedPiecesFor', () {
      test('should return captured pieces for team', () {
        final captureMove = PawnCaptureMove(
          from: Position.e4,
          to: Position.d5,
          moving: Pawn.white,
          captured: Pawn.black,
        );

        scoreManager.processCapture(captureMove);

        final capturedPieces = scoreManager.capturedPiecesFor(Team.white);
        expect(capturedPieces, hasLength(1));
        expect(capturedPieces.first, isA<Pawn>());
      });
    });

    group('hasTeamCaptured', () {
      test('should detect if team has captured specific piece type', () {
        final captureMove = QueenCaptureMove(
          from: Position.d1,
          to: Position.d8,
          moving: Queen.white,
          captured: Queen.black,
        );

        scoreManager.processCapture(captureMove);

        expect(scoreManager.hasTeamCaptured<Queen>(Team.white), isTrue);
        expect(scoreManager.hasTeamCaptured<Rook>(Team.white), isFalse);
        expect(scoreManager.hasTeamCaptured<Queen>(Team.black), isFalse);
      });
    });

    group('totalMaterialCaptured', () {
      test('should calculate total material captured by all teams', () {
        final whitePawnCapture = PawnCaptureMove(
          from: Position.e4,
          to: Position.d5,
          moving: Pawn.white,
          captured: Pawn.black,
        );
        final blackQueenCapture = QueenCaptureMove(
          from: Position.d8,
          to: Position.d1,
          moving: Queen.black,
          captured: Queen.white,
        );

        scoreManager.processCapture(whitePawnCapture);
        scoreManager.processCapture(blackQueenCapture);

        expect(scoreManager.totalMaterialCaptured, equals(10)); // 1 + 9
      });
    });

    group('toString', () {
      test('should provide readable string representation', () {
        final captureMove = PawnCaptureMove(
          from: Position.e4,
          to: Position.d5,
          moving: Pawn.white,
          captured: Pawn.black,
        );

        scoreManager.processCapture(captureMove);

        final result = scoreManager.toString().split('\n');
        expect(result[1], contains('White'));
        expect(result[1], contains('captures: 1'));
        expect(result[1], contains('score: 1'));
      });
    });
  });
}
