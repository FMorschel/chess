import '../move/move.dart';
import '../team/team.dart';
import 'game_state.dart';

/// Events emitted when game state changes
sealed class GameStateEvent {
  const GameStateEvent();

  factory GameStateEvent.moveRecorded(Move move, Team nextTeam) =
      _MoveRecordedEvent;
  factory GameStateEvent.gameStateChanged(GameState from, GameState to) =
      _GameStateChangedEvent;
  factory GameStateEvent.moveUndone(Team currentTeam) = _MoveUndoneEvent;
  factory GameStateEvent.moveRedone(Team currentTeam) = _MoveRedoneEvent;
}

class _MoveRecordedEvent extends GameStateEvent {
  const _MoveRecordedEvent(this.move, this.nextTeam);

  final Move move;
  final Team nextTeam;

  @override
  String toString() => 'MoveRecorded(move: $move, nextTeam: $nextTeam)';
}

class _GameStateChangedEvent extends GameStateEvent {
  const _GameStateChangedEvent(this.from, this.to);

  final GameState from;
  final GameState to;

  @override
  String toString() => 'GameStateChanged(from: $from, to: $to)';
}

class _MoveUndoneEvent extends GameStateEvent {
  const _MoveUndoneEvent(this.currentTeam);

  final Team currentTeam;

  @override
  String toString() => 'MoveUndone(currentTeam: $currentTeam)';
}

class _MoveRedoneEvent extends GameStateEvent {
  const _MoveRedoneEvent(this.currentTeam);

  final Team currentTeam;

  @override
  String toString() => 'MoveRedone(currentTeam: $currentTeam)';
}
