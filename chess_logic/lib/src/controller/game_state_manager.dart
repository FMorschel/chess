import 'dart:async';

import '../move/move.dart';
import '../position/position.dart';
import '../square/piece.dart';
import '../team/team.dart';
import 'board_state.dart';
import 'game_state.dart';
import 'game_state_event.dart';

/// Manages game state transitions, history, and notifications.
///
/// This class is responsible for:
/// - Tracking current game state and active player
/// - Managing move history with undo/redo capabilities
/// - Providing immutable state updates
/// - Notifying observers of state changes
/// - Handling state persistence and serialization
class GameStateManager {
  GameStateManager(
    this._teams, {
    List<Move>? moveHistory,
    BoardState? initialBoardState,
  }) : assert(_teams.length > 1, 'At least two teams required'),
       _moveHistory = List.from(moveHistory ?? []),
       _initialBoardState = initialBoardState ?? BoardState(),
       _boardState = initialBoardState ?? BoardState(),
       _currentTeamIndex = _calculateCurrentTeamIndex(_teams, moveHistory),
       _gameState = GameState.inProgress,
       _stateController = StreamController<GameStateEvent>.broadcast();
  GameStateManager.custom(this._teams, Map<Position, Piece> customPieces)
    : assert(
        _teams.length > 1,
        'There must be at least two teams to start a game',
      ),
      _gameState = GameState.inProgress,
      _initialBoardState = BoardState.custom(customPieces),
      _boardState = BoardState.custom(customPieces),
      _stateController = StreamController<GameStateEvent>.broadcast(),
      _currentTeamIndex = 0,
      _moveHistory = [];

  /// Import state from serialized data
  ///
  /// Creates a [GameStateManager] from exported data. Supports both simple
  /// export format and GameController-compatible format.
  factory GameStateManager.import(Map<String, Map<String, String>> data) {
    final teams = <Team>[];
    final customPieces = <Position, Piece>{};

    if (data.containsKey('teams')) {
      for (final MapEntry(value: name) in data['teams']!.entries) {
        final team = Team(name);
        teams.add(team);
      }
    }

    if (data.containsKey('custom')) {
      for (final entry in data['custom']!.entries) {
        customPieces[Position.fromAlgebraic(entry.key)] = Piece.import(
          entry.value,
        );
      }
    }

    final manager = GameStateManager.custom(teams, customPieces);

    if (data.containsKey('history')) {
      for (final MapEntry(key: teamName, value: algebraic)
          in data['history']!.entries) {
        final currentTeam = Team(teamName);
        final move = Move.fromAlgebraic(
          algebraic,
          currentTeam,
          enpassant: ({required from, required to}) {
            final position = Position(to.file, from.rank);
            final piece = manager.boardState[position].piece;
            if (piece is Pawn && piece.team != currentTeam) {
              return piece;
            }
            return null;
          },
          pieceAt: (position) => manager.boardState[position].piece,
          pieceOrigin: ({required piece, required to, required ambiguous}) {
            final squares = manager.boardState.squares.where(
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
        manager.recordMove(move, manager.boardState);
      }
    }
    return manager;
  }
  final List<Team> _teams;
  final List<Move> _moveHistory;
  final StreamController<GameStateEvent> _stateController;
  final BoardState _initialBoardState;

  // Redo stack for moves that have been undone
  final List<Move> _redoStack = [];

  BoardState _boardState;
  int _currentTeamIndex;
  GameState _gameState;

  /// Stream of game state change events
  Stream<GameStateEvent> get stateChanges => _stateController.stream;

  /// Current game state
  GameState get gameState => _gameState;

  /// Current active team
  Team get currentTeam => _teams[_currentTeamIndex];

  /// All teams in the game
  List<Team> get teams => List.unmodifiable(_teams);

  /// Complete move history (immutable view)
  List<Move> get moveHistory => List.unmodifiable(_moveHistory);

  /// Current board state
  BoardState get boardState => _boardState;

  /// Whether the game has ended
  bool get isGameEnded => _gameState.end;

  /// Whether the game is currently active (in progress)
  bool get isGameActive => _gameState.active;

  /// Whether undo operation is available
  bool get canUndo => _moveHistory.isNotEmpty;

  /// Whether redo operation is available
  bool get canRedo => _redoStack.isNotEmpty;

  /// Add a move to the history and update state immutably
  void recordMove(Move move, BoardState newBoardState) {
    if (!isGameActive) {
      throw StateError('Cannot record move when game is not active');
    }

    // Clear redo stack when new move is made
    _redoStack.clear();

    // Update state
    _moveHistory.add(move);
    _boardState = newBoardState;
    _advanceToNextTeam();

    // Notify observers
    _notifyStateChange(GameStateEvent.moveRecorded(move, currentTeam));
  }

  /// Update the game state (e.g., to checkmate, draw, etc.)
  void updateGameState(GameState newState) {
    if (_gameState == newState) return;

    final previousState = _gameState;
    _gameState = newState;

    _notifyStateChange(
      GameStateEvent.gameStateChanged(previousState, newState),
    );
  }

  /// Pause the game
  void pause() {
    if (_gameState != GameState.inProgress) {
      throw StateError('Can only pause a game in progress');
    }
    updateGameState(GameState.paused);
  }

  /// Resume a paused game
  void resume() {
    if (_gameState != GameState.paused) {
      throw StateError('Can only resume a paused game');
    }
    updateGameState(GameState.inProgress);
  }

  /// End the game with a draw
  void declareDraw() {
    if (!isGameActive) {
      throw StateError('Cannot declare draw when game is not active');
    }
    updateGameState(GameState.draw);
  }

  /// End the game with team victory
  void declareWinner(Team winner) {
    if (!isGameActive) {
      throw StateError('Cannot declare winner when game is not active');
    }
    if (!_teams.contains(winner)) {
      throw ArgumentError('Winner must be one of the participating teams');
    }
    updateGameState(GameState.teamWin);
  }

  /// Undo the last move
  void undo() {
    if (!canUndo) {
      throw StateError('No moves to undo');
    }

    // Move the last move from history to redo stack
    final moveToUndo = _moveHistory.removeLast();
    _redoStack.add(moveToUndo);

    // Recalculate state from the remaining move history
    _recalculateStateFromHistory();

    _notifyStateChange(GameStateEvent.moveUndone(currentTeam));
  }

  /// Redo the last undone move
  void redo() {
    if (!canRedo) {
      throw StateError('No moves to redo');
    }

    // Move the last undone move back to history
    final moveToRedo = _redoStack.removeLast();
    _moveHistory.add(moveToRedo);

    // Recalculate state from the updated move history
    _recalculateStateFromHistory();

    _notifyStateChange(GameStateEvent.moveRedone(currentTeam));
  }

  /// Export state in GameController-compatible format
  ///
  /// Returns data in the format expected by [GameStateManager.import].
  Map<String, Map<String, String>> export({
    Map<Position, Piece>? customPieces,
  }) {
    final result = <String, Map<String, String>>{
      'teams': {for (final team in _teams) '${team.index}': team.name},
    };

    // Add custom pieces if provided
    if (customPieces != null && customPieces.isNotEmpty) {
      result['custom'] = {
        for (final MapEntry(key: position, value: piece)
            in customPieces.entries)
          position.toAlgebraic(): piece.export,
      };
    }

    // Add move history
    if (_moveHistory.isNotEmpty) {
      result['history'] = {
        for (final move in _moveHistory) move.team.name: move.toAlgebraic(),
      };
    }

    return result;
  }

  /// Calculate current team index based on move history
  static int _calculateCurrentTeamIndex(
    List<Team> teams,
    List<Move>? moveHistory,
  ) {
    if (moveHistory == null || moveHistory.isEmpty) {
      return 0; // Start with first team
    }

    final lastMove = moveHistory.last;
    final lastTeamIndex = teams.indexWhere((team) => team == lastMove.team);
    return (lastTeamIndex + 1) % teams.length;
  }

  /// Advance to the next team in rotation
  void _advanceToNextTeam() {
    _currentTeamIndex = (_currentTeamIndex + 1) % _teams.length;
  }

  /// Recalculate game state from move history
  ///
  /// This method rebuilds the board state and current team from the complete
  /// move history, used after undo/redo operations.
  void _recalculateStateFromHistory() {
    // Create a fresh copy of the initial board state
    final initialPieces = <Position, Piece>{};
    for (final square in _initialBoardState.occupiedSquares) {
      initialPieces[square.position] = square.piece;
    }

    // Reset to initial state
    _boardState = initialPieces.isEmpty
        ? BoardState.empty()
        : BoardState.custom(initialPieces);
    _currentTeamIndex = 0;
    _gameState = GameState.inProgress;

    // Replay all moves in history to reconstruct current state
    for (final move in _moveHistory) {
      // Apply move to board state
      _boardState.move(move);

      // Advance to next team
      _advanceToNextTeam();
    }

    // Recalculate current team index based on move history
    _currentTeamIndex = _calculateCurrentTeamIndex(_teams, _moveHistory);
  }

  /// Notify observers of state changes
  void _notifyStateChange(GameStateEvent event) {
    _stateController.add(event);
  }

  /// Clean up resources
  void dispose() {
    _stateController.close();
  }
}
