import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/controller/movement_manager.dart';
import 'package:chess_logic/src/controller/team_score.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:chess_logic/src/utility/extensions.dart';

/// Main game controller that orchestrates chess game logic, moves, and scoring.
class GameController {
  GameController(this._teams, {List<Move>? moveHistory})
    : assert(
        _teams.length > 1,
        'There must be at least two teams to start a game',
      ),
      _custom = null,
      _scores = moveHistory.scores..addMissing(_teams),
      movementManager = MovementManager(
        BoardState(history: moveHistory),
        moveHistory ?? [],
        _teams,
      );

  GameController.clear(this._teams)
    : assert(
        _teams.length > 1,
        'There must be at least two teams to start a game',
      ),
      _custom = null,
      _scores = _teams.scores,
      movementManager = MovementManager(BoardState.clear(), [], _teams);

  GameController.custom(this._teams, Map<Position, Piece> customPieces)
    : assert(
        _teams.length > 1,
        'There must be at least two teams to start a game',
      ),
      _custom = customPieces,
      _scores = _teams.scores,
      movementManager = MovementManager(
        BoardState.custom(customPieces),
        [],
        _teams,
      );

  factory GameController.import(Map<String, Map<String, String>> data) {
    final teams = <Team>[];
    final customPieces = <Position, Piece>{};

    if (data.containsKey('teams')) {
      for (var MapEntry(value: name) in data['teams']!.entries) {
        final team = Team(name);
        teams.add(team);
      }
    }

    if (data.containsKey('custom')) {
      for (var entry in data['custom']!.entries) {
        customPieces[Position.fromAlgebraic(entry.key)] = Piece.import(
          entry.value,
        );
      }
    }

    final controller = GameController.custom(teams, customPieces);

    if (data.containsKey('history')) {
      for (var MapEntry(key: teamName, value: algebraic)
          in data['history']!.entries) {
        final currentTeam = Team(teamName);
        final move = Move.fromAlgebraic(
          algebraic,
          currentTeam,
          enpassant: ({required from, required to}) {
            final position = Position(to.file, from.rank);
            final piece = controller.boardState[position].piece;
            if (piece is Pawn && piece.team != currentTeam) {
              return piece;
            }
            return null;
          },
          pieceAt: (position) => controller.boardState[position].piece,
          pieceOrigin: ({required piece, required to, required ambiguous}) {
            final squares = controller.boardState.squares.where(
              (sq) =>
                  sq.piece == piece &&
                  (ambiguous?.couldBe(sq.position) ?? true),
            );
            if (squares.length == 1) {
              return squares.first.position;
            }
            if (squares.isEmpty) {
              throw ArgumentError(
                'No piece found matching $piece at '
                '${ambiguous?.toAlgebraic() ?? 'anywhere'}',
              );
            }
            throw ArgumentError(
              'Ambiguous piece position for $piece at '
              '${ambiguous?.toAlgebraic() ?? 'anywhere'}',
            );
          },
        );
        controller.move(move);
      }
    }

    return controller;
  }

  final Map<Position, Piece>? _custom;
  final List<TeamScore> _scores;
  final List<Team> _teams;
  final MovementManager movementManager;

  List<Team> get teams => List.unmodifiable(_teams);
  List<TeamScore> get scores => List.unmodifiable(_scores);
  List<Move> get moves => movementManager.moveHistory;
  BoardState get boardState => movementManager.state;

  void move(Move move) {
    // TODO: this.
  }

  /// Get the score for a specific team
  int operator [](Team team) =>
      scores.firstWhere((score) => score.team == team).score;

  Map<String, Map<String, String>> get export => {
    if (_custom case Map(:var entries) when entries.isNotEmpty)
      'custom': {
        for (var MapEntry(key: position, value: piece) in entries)
          position.toAlgebraic(): piece.export,
      },
    if (moves.isNotEmpty)
      'history': {for (var move in moves) move.team.name: move.toAlgebraic()},
    if (teams.isNotEmpty)
      'teams': {for (var team in teams) '${team.index}': team.name},
  };
}
