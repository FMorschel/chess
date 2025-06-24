import 'package:collection/collection.dart';

import '../move/check.dart';
import '../move/move.dart';
import '../position/position.dart';
import '../square/piece.dart';
import '../team/team.dart';
import 'board_state.dart';
import 'game_rule_engine.dart';
import 'game_state.dart';
import 'game_state_manager.dart';
import 'movement_manager.dart';
import 'score_manager.dart';
import 'team_score.dart';

/// Main game controller that orchestrates chess game logic, moves, and scoring.
class GameController {
  GameController(this._teams, {List<Move>? moveHistory})
    : assert(
        _teams.length > 1,
        'There must be at least two teams to start a game',
      ),
      _scoreManager = ScoreManager(_teams, moveHistory: moveHistory),
      _movementManager = MovementManager(
        BoardState(),
        moveHistory ?? [],
        _teams,
      ),
      _stateManager = GameStateManager(
        _teams,
        moveHistory: moveHistory,
        initialBoardState: BoardState(),
      ),
      _ruleEngine = const GameRuleEngine(),
      _halfmoveClock = _calculateHalfmoveClock(moveHistory ?? []) {
    _updateStateAfterMove(moveHistory?.lastOrNull);
  }

  GameController.clear(this._teams)
    : assert(
        _teams.length > 1,
        'There must be at least two teams to start a game',
      ),
      _scoreManager = ScoreManager.empty(_teams),
      _movementManager = MovementManager(BoardState.empty(), [], _teams),
      _stateManager = GameStateManager(
        _teams,
        initialBoardState: BoardState.empty(),
      ),
      _ruleEngine = const GameRuleEngine(),
      _halfmoveClock = 0;
  GameController.custom(this._teams, Map<Position, Piece> customPieces)
    : assert(
        _teams.length > 1,
        'There must be at least two teams to start a game',
      ),
      _scoreManager = ScoreManager.empty(_teams),
      _movementManager = MovementManager(
        BoardState.custom(customPieces),
        [],
        _teams,
      ),
      _stateManager = GameStateManager(
        _teams,
        initialBoardState: BoardState.custom(customPieces),
      ),
      _ruleEngine = const GameRuleEngine(),
      _halfmoveClock = 0;

  /// Clean up resources
  void dispose() {
    _stateManager.dispose();
  }

  final List<Team> _teams;
  final ScoreManager _scoreManager;
  final MovementManager _movementManager;
  final GameStateManager _stateManager;
  final GameRuleEngine _ruleEngine;

  /// Number of half-moves since the last capture or pawn move.
  /// Used for the 50-move rule.
  int _halfmoveClock;

  /// Calculate the halfmove clock based on the move history.
  static int _calculateHalfmoveClock(List<Move> moveHistory) {
    if (moveHistory.isEmpty) return 0;
    var halfmoveClock = 0;
    var lastMoveIndex = moveHistory.length - 1;
    do {
      final lastMove = moveHistory[lastMoveIndex];
      if (lastMove is CaptureMove || lastMove.moving is Pawn) {
        return halfmoveClock;
      }
      halfmoveClock++;
      lastMoveIndex--;
    } while (lastMoveIndex >= 0 && halfmoveClock < 100);
    return halfmoveClock;
  }

  List<Move> movesFor({Team? team, Position? position}) => state.occupiedSquares
      .where(
        (square) =>
            (team == null || square.piece.team == team) &&
            (position == null || square.position == position),
      )
      .expand(_movementManager.possibleMoves)
      .toList();
  void move(Move move) {
    if (_stateManager.gameState != GameState.inProgress) {
      throw StateError('Cannot move pieces when the game is not in progress');
    }
    if (move is CaptureMove) {
      _scoreManager.processCapture(move);
    }
    move = _movementManager.move(move);
    _updateHalfmoveClock(move);

    // Update state manager with new board state
    _stateManager.recordMove(move, _movementManager.state);

    _updateStateAfterMove(move);
  }

  void pause() {
    if (_stateManager.gameState case GameState.inProgress || GameState.paused) {
      throw StateError('Cannot pause when the game is not in progress');
    }
    _stateManager.pause();
  }

  void draw() {
    if (_stateManager.gameState == GameState.inProgress) {
      _stateManager.declareDraw();
      return;
    }
    throw StateError('Cannot draw when the game is not in progress');
  }

  void resume() {
    if (_stateManager.gameState case GameState.paused || GameState.inProgress) {
      _stateManager.resume();
      return;
    }
    throw StateError('Cannot resume when the game is not paused');
  }

  /// Updates the halfmove clock based on the move
  void _updateHalfmoveClock(Move move) {
    // Reset clock on pawn move or capture
    if (move.moving is Pawn || move is CaptureMove) {
      _halfmoveClock = 0;
    } else {
      _halfmoveClock++;
    }
  }

  void _updateStateAfterMove(Move<Piece>? move) {
    if (move?.check == Check.checkmate) {
      _stateManager.updateGameState(GameState.teamWin);
      return;
    }
    if (_ruleEngine.hasInsufficientMaterial(state)) {
      _stateManager.updateGameState(GameState.draw);
      return;
    }
    // Fifty-move rule: if no capture or pawn move in the last 50 moves
    if (_ruleEngine.isFiftyMoveRule(_halfmoveClock, _teams)) {
      _stateManager.updateGameState(GameState.draw);
      return;
    }
    if (_stalemate) {
      _stateManager.updateGameState(GameState.stalemate);
    }
  }

  /// Get the score for a specific team
  int operator [](Team team) =>
      scores.firstWhere((score) => score.team == team).score;

  /// The current halfmove clock count - number of half-moves since last pawn
  /// move or capture
  int get halfmoveClock => _halfmoveClock;

  /// Access to the game rule engine for special rule validation
  GameRuleEngine get ruleEngine => _ruleEngine;

  List<Team> get teams => _stateManager.teams;

  List<TeamScore> get scores => _scoreManager.scores;

  List<Move> get history => _stateManager.moveHistory;

  BoardState get state => _movementManager.state;

  Team get currentTeam => _stateManager.currentTeam;

  List<Move> get nextPossibleMoves => movesFor(team: currentTeam);

  GameState get gameState => _stateManager.gameState;

  bool get _stalemate => movesFor(team: currentTeam).isEmpty;
  Team? get winner => _stateManager.gameState == GameState.teamWin
      ? history.last.moving.team
      : null;
}
