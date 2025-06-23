import 'package:equatable/equatable.dart';

import '../square/piece.dart';
import '../team/team.dart';
import '../utility/extensions.dart';
import 'capture.dart';

/// Tracks the score and captured pieces for a specific team
final class TeamScore with EquatableMixin {
  TeamScore(this.team, {List<Capture>? captures}) : _captures = [...?captures];

  final Team team;
  final List<Capture> _captures;

  /// Add a captured piece and return a new TeamScore instance
  void capture(Capture capture) {
    if (capture.team != team) {
      throw ArgumentError.value(
        capture.team,
        'capture.team',
        'The capture must belong to the team',
      );
    }
    _captures.add(capture);
  }

  bool operator >(TeamScore other) => score > other.score;
  bool operator <(TeamScore other) => score < other.score;

  @override
  String toString() {
    return 'team: ${team.name}, captures: ${_captures.length}, score: '
        '$score';
  }

  /// Immutable list of pieces captured by this team
  List<Piece> get capturedPieces =>
      List.unmodifiable(_captures.map((c) => c.piece));

  /// Total point value of captured pieces
  int get score => _captures.totalValue;

  @override
  List<Object?> get props => [team, _captures, score];
}
