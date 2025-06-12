import 'package:chess_logic/src/controller/capture.dart';
import 'package:chess_logic/src/controller/team_score.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:collection/collection.dart';

extension IterableCaptureExtension on Iterable<Capture> {
  int get totalValue => fold<int>(0, (sum, capture) => sum + capture.value);
}

extension ListSquareExtension on List<Square> {
  void replace(Square square) {
    final index = at(square.position);
    this[index] = square;
  }

  int at(Position position) {
    final index = indexed
        .firstWhereOrNull((square) => square.$2.position == position)
        ?.$1;
    if (index == null) {
      throw ArgumentError('No square found at position $position');
    }
    return index;
  }
}

extension IterableMoveExtension on Iterable<Move>? {
  List<TeamScore> get scores => (this ?? [])
      .whereType<CaptureMove>()
      .map(Capture.new)
      .fold([], (list, capture) {
        if (list.none((score) => score.team == capture.team)) {
          final teamScore = TeamScore(capture.team);
          teamScore.capture(capture);
          list.add(teamScore);
        } else {
          list
              .firstWhere((score) => score.team == capture.team)
              .capture(capture);
        }
        return list;
      });
}

extension ListTeamScoreExtension on List<TeamScore> {
  void addMissing(List<Team> teams) {
    for (final team in teams) {
      if (none((score) => score.team == team)) {
        add(TeamScore(team));
      }
    }
  }
}

extension IterableTeamExtension on Iterable<Team> {
  List<TeamScore> get scores => map((team) => TeamScore(team)).toList();
}
