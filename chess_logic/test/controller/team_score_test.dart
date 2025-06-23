import 'package:chess_logic/src/controller/capture.dart';
import 'package:chess_logic/src/controller/team_score.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('TeamScore', () {
    late Team team;
    late TeamScore teamScore;

    setUp(() {
      team = Team.white;
      teamScore = TeamScore(team);
    });

    group('constructor', () {
      test('should create TeamScore with empty captures', () {
        expect(teamScore.team, equals(team));
        expect(teamScore.capturedPieces, isEmpty);
        expect(teamScore.score, equals(0));
      });
      test('should create TeamScore with initial captures', () {
        final capture = _createCapture(
          captured: Pawn.black,
          captor: Queen.white,
        );
        final score = TeamScore(team, captures: [capture]);

        expect(score.team, equals(team));
        expect(score.capturedPieces, hasLength(1));
        expect(score.capturedPieces.first, isA<Pawn>());
        expect(score.score, equals(1)); // Pawn value
      });
    });
    group('capture', () {
      test('should add capture for same team', () {
        final capture = _createCapture(
          captured: Pawn.black,
          captor: Queen.white,
        );

        teamScore.capture(capture);

        expect(teamScore.capturedPieces, hasLength(1));
        expect(teamScore.capturedPieces.first, isA<Pawn>());
        expect(teamScore.score, equals(1));
      });

      test('should throw ArgumentError for different team', () {
        final capture = _createCapture(
          captured: Pawn.white,
          captor: Queen.black,
        );

        expect(
          () => teamScore.capture(capture),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'The capture must belong to the team',
            ),
          ),
        );
      });
      test('should accumulate multiple captures', () {
        final pawnCapture = _createCapture(
          captured: Pawn.black,
          captor: Queen.white,
        );
        final rookCapture = _createCapture(
          captured: Rook.black,
          captor: Queen.white,
        );

        teamScore.capture(pawnCapture);
        teamScore.capture(rookCapture);

        expect(teamScore.capturedPieces, hasLength(2));
        expect(teamScore.score, equals(6)); // Pawn (1) + Rook (5)
      });
    });

    group('capturedPieces', () {
      test('should return immutable list', () {
        final capture = _createCapture(
          captured: Pawn.black,
          captor: Queen.white,
        );
        teamScore.capture(capture);

        final pieces = teamScore.capturedPieces;
        expect(pieces, hasLength(1));

        // Verify it's a new list (modifications don't affect original)
        expect(pieces.clear, throwsUnsupportedError);
      });

      test('should maintain correct order of captures', () {
        final pawnCapture = _createCapture(
          captured: Pawn.black,
          captor: Queen.white,
        );
        final rookCapture = _createCapture(
          captured: Rook.black,
          captor: Queen.white,
        );
        final bishopCapture = _createCapture(
          captured: Bishop.black,
          captor: Queen.white,
        );

        teamScore.capture(pawnCapture);
        teamScore.capture(rookCapture);
        teamScore.capture(bishopCapture);

        final pieces = teamScore.capturedPieces;
        expect(pieces[0], isA<Pawn>());
        expect(pieces[1], isA<Rook>());
        expect(pieces[2], isA<Bishop>());
      });
    });

    group('score', () {
      test('should start at zero', () {
        expect(teamScore.score, equals(0));
      });
      test('should calculate correct total for single capture', () {
        final queenCapture = _createCapture(
          captured: Queen.black,
          captor: Rook.white,
        );
        teamScore.capture(queenCapture);

        expect(teamScore.score, equals(9)); // Queen value
      });

      test('should calculate correct total for multiple captures', () {
        final captures = [
          _createCapture(captured: Queen.black, captor: Rook.white), // 9 points
          _createCapture(
            captured: Rook.black,
            captor: Bishop.white,
          ), // 5 points
          _createCapture(
            captured: Bishop.black,
            captor: Knight.white,
          ), // 3 points
          _createCapture(
            captured: Knight.black,
            captor: Pawn.white,
          ), // 3 points
          _createCapture(captured: Pawn.black, captor: Queen.white), // 1 point
        ];

        for (final capture in captures) {
          teamScore.capture(capture);
        }

        expect(teamScore.score, equals(21)); // 9+5+3+3+1
      });

      test('should handle king captures (value 0)', () {
        final kingCapture = _createCapture(
          captured: King.black,
          captor: Queen.white,
        );
        teamScore.capture(kingCapture);

        expect(teamScore.score, equals(0)); // King has value 0
      });
    });

    group('comparison operators', () {
      late TeamScore otherScore;

      setUp(() {
        otherScore = TeamScore(Team.black);
      });
      test('should compare scores correctly with > operator', () {
        final highValueCapture = _createCapture(
          captured: Queen.black,
          captor: Rook.white,
        );
        final lowValueCapture = _createCapture(
          captured: Pawn.white,
          captor: Queen.black,
        );

        teamScore.capture(highValueCapture); // 9 points
        otherScore.capture(lowValueCapture); // 1 point

        expect(teamScore > otherScore, isTrue);
        expect(otherScore > teamScore, isFalse);
      });

      test('should compare scores correctly with < operator', () {
        final highValueCapture = _createCapture(
          captured: Queen.white,
          captor: Rook.black,
        );
        final lowValueCapture = _createCapture(
          captured: Pawn.black,
          captor: Queen.white,
        );

        teamScore.capture(lowValueCapture); // 1 point
        otherScore.capture(highValueCapture); // 9 points

        expect(teamScore < otherScore, isTrue);
        expect(otherScore < teamScore, isFalse);
      });

      test('should handle equal scores', () {
        final capture1 = _createCapture(
          captured: Rook.black,
          captor: Queen.white,
        );
        final capture2 = _createCapture(
          captured: Rook.white,
          captor: Queen.black,
        );

        teamScore.capture(capture1); // 5 points
        otherScore.capture(capture2); // 5 points

        expect(teamScore > otherScore, isFalse);
        expect(teamScore < otherScore, isFalse);
      });
    });

    group('toString', () {
      test('should display correct format with no captures', () {
        final result = teamScore.toString();
        expect(result, equals('team: White, captures: 0, score: 0'));
      });
      test('should display correct format with captures', () {
        final pawnCapture = _createCapture(
          captured: Pawn.black,
          captor: Queen.white,
        );
        final rookCapture = _createCapture(
          captured: Rook.black,
          captor: Queen.white,
        );

        teamScore.capture(pawnCapture);
        teamScore.capture(rookCapture);

        final result = teamScore.toString();
        expect(result, equals('team: White, captures: 2, score: 6'));
      });

      test('should work with black team', () {
        final blackScore = TeamScore(Team.black);
        final capture = _createCapture(
          captured: Queen.white,
          captor: Rook.black,
        );
        blackScore.capture(capture);

        final result = blackScore.toString();
        expect(result, equals('team: Black, captures: 1, score: 9'));
      });
    });

    group('equality', () {
      test('should be equal with same team and no captures', () {
        final other = TeamScore(team);

        expect(teamScore, equals(other));
        expect(teamScore.hashCode, equals(other.hashCode));
      });

      test('should be equal with same team and same captures', () {
        final capture = _createCapture(
          captured: Pawn.black,
          captor: Queen.white,
        );

        teamScore.capture(capture);

        final other = TeamScore(team);
        other.capture(capture);

        expect(teamScore, equals(other));
        expect(teamScore.hashCode, equals(other.hashCode));
      });

      test('should not be equal with different teams', () {
        final other = TeamScore(Team.black);

        expect(teamScore, isNot(equals(other)));
      });
      test('should not be equal with different captures', () {
        final pawnCapture = _createCapture(
          captured: Pawn.black,
          captor: Queen.white,
        );
        final rookCapture = _createCapture(
          captured: Rook.black,
          captor: Queen.white,
        );

        teamScore.capture(pawnCapture);

        final other = TeamScore(team);
        other.capture(rookCapture);

        expect(teamScore, isNot(equals(other)));
      });
    });

    group('edge cases', () {
      test('should handle many captures of same piece type', () {
        for (int i = 0; i < 8; i++) {
          final pawnCapture = _createCapture(
            captured: Pawn.black,
            captor: Queen.white,
          );
          teamScore.capture(pawnCapture);
        }

        expect(teamScore.capturedPieces, hasLength(8));
        expect(teamScore.score, equals(8)); // 8 pawns
        expect(teamScore.capturedPieces.every((p) => p is Pawn), isTrue);
      });

      test('should handle all piece types', () {
        final captures = [
          _createCapture(captured: King.black, captor: Queen.white),
          _createCapture(captured: Queen.black, captor: Rook.white),
          _createCapture(captured: Rook.black, captor: Bishop.white),
          _createCapture(captured: Bishop.black, captor: Knight.white),
          _createCapture(captured: Knight.black, captor: Pawn.white),
          _createCapture(captured: Pawn.black, captor: King.white),
        ];

        for (final capture in captures) {
          teamScore.capture(capture);
        }

        expect(teamScore.capturedPieces, hasLength(6));
        expect(teamScore.score, equals(21)); // 0+9+5+3+3+1

        // Verify all piece types are present
        final pieceTypes = teamScore.capturedPieces
            .map((p) => p.runtimeType)
            .toSet();
        expect(pieceTypes, hasLength(6));
      });

      test('should work with complex capture scenarios', () {
        // Simulate a complex game with many captures
        final captures = [
          _createCapture(captured: Pawn.black, captor: Pawn.white), // 1
          _createCapture(captured: Knight.black, captor: Bishop.white), // 3
          _createCapture(captured: Bishop.black, captor: Knight.white), // 3
          _createCapture(captured: Rook.black, captor: Rook.white), // 5
          _createCapture(captured: Queen.black, captor: Queen.white), // 9
          _createCapture(captured: Pawn.black, captor: Rook.white), // 1
        ];

        for (final capture in captures) {
          teamScore.capture(capture);
        }

        expect(teamScore.capturedPieces, hasLength(6));
        expect(teamScore.score, equals(22)); // 1+3+3+5+9+1
      });
    });

    group('integration with extensions', () {
      test('should work with totalValue extension', () {
        final captures = [
          _createCapture(captured: Queen.black, captor: Rook.white),
          _createCapture(captured: Rook.black, captor: Bishop.white),
        ];

        for (final capture in captures) {
          teamScore.capture(capture);
        }

        // The score should use the totalValue extension internally
        expect(teamScore.score, equals(14)); // 9+5
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
