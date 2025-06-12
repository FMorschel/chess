import 'package:chess_logic/src/controller/capture.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:chess_logic/src/utility/extensions.dart';
import 'package:equatable/equatable.dart';

/// Tracks the score and captured pieces for a specific team
final class TeamScore with EquatableMixin {
  TeamScore(this.team, {List<Capture>? captures}) : _captures = [...?captures];

  final Team team;
  final List<Capture> _captures;

  /// List of pieces captured by this team (immutable)
  List<Piece> get capturedPieces => _captures.map((c) => c.piece).toList();

  /// Total point value of captured pieces
  int get score => _captures.totalValue;

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

  @override
  List<Object?> get props => [team, _captures, score];
}
