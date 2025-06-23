import '../move/move.dart';
import '../square/piece.dart';
import '../team/team.dart';
import '../utility/extensions.dart';
import 'capture.dart';
import 'team_score.dart';

/// Manages team scores and captured pieces throughout a chess game.
///
/// The ScoreManager is responsible for:
/// - Tracking scores for each team
/// - Managing captured pieces and their point values
/// - Providing score comparisons between teams
/// - Maintaining score history and statistics
class ScoreManager {
  ScoreManager(List<Team> teams, {List<Move>? moveHistory})
    : _scores = moveHistory.scores..addMissing(teams);

  ScoreManager.empty(List<Team> teams) : _scores = teams.scores;

  final List<TeamScore> _scores;

  /// Process a capture move and update the appropriate team's score
  void processCapture(CaptureMove move) {
    final teamScore = _scores.firstWhere((score) => score.team == move.team);
    teamScore.capture(Capture(move));
  }

  /// Get the score for a specific team
  int operator [](Team team) =>
      _scores.firstWhere((score) => score.team == team).score;

  /// Get all team scores (immutable)
  List<TeamScore> get scores => List.unmodifiable(_scores);

  /// Get the leading team (highest score)
  Team? get leadingTeam {
    if (_scores.isEmpty) return null;

    final sortedScores = [..._scores]
      ..sort((a, b) => b.score.compareTo(a.score));
    final highestScore = sortedScores.first.score;

    // Check if there's a tie for the highest score
    final leadingTeams = sortedScores.where((s) => s.score == highestScore);
    if (leadingTeams.length > 1) return null; // Tie

    return sortedScores.first.team;
  }

  /// Get the score difference between two teams
  int scoreDifference(Team team1, Team team2) {
    return this[team1] - this[team2];
  }

  /// Get teams sorted by score (descending)
  List<TeamScore> get teamsByScore {
    final sortedScores = [..._scores];
    sortedScores.sort((a, b) => b.score.compareTo(a.score));
    return List.unmodifiable(sortedScores);
  }

  /// Get all captured pieces for a team
  List<Piece> capturedPiecesFor(Team team) {
    final teamScore = _scores.firstWhere((score) => score.team == team);
    return teamScore.capturedPieces;
  }

  /// Check if a team has captured a specific piece type
  bool hasTeamCaptured<T extends Piece>(Team team) {
    return capturedPiecesFor(team).any((piece) => piece is T);
  }

  /// Get the total material captured by all teams
  int get totalMaterialCaptured {
    return _scores.fold(0, (total, score) => total + score.score);
  }

  @override
  String toString() {
    final buffer = StringBuffer('[\n');
    for (final score in teamsByScore) {
      buffer.writeln('  $score');
    }
    buffer.write(']');
    return buffer.toString();
  }
}
