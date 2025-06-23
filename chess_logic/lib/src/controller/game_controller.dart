import 'package:collection/collection.dart';

import '../move/check.dart';
import '../move/move.dart';
import '../position/position.dart';
import '../square/piece.dart';
import '../team/team.dart';
import '../utility/extensions.dart';
import 'board_state.dart';
import 'capture.dart';
import 'game_state.dart';
import 'movement_manager.dart';
import 'team_score.dart';

/// Main game controller that orchestrates chess game logic, moves, and scoring.
class GameController {
  GameController(this._teams, {List<Move>? moveHistory})
    : assert(
        _teams.length > 1,
        'There must be at least two teams to start a game',
      ),
      _custom = null,
      _scores = moveHistory.scores..addMissing(_teams),
      _movementManager = MovementManager(
        BoardState(),
        moveHistory ?? [],
        _teams,
      ),
      _currentTeamIndex = _teams.indexed
          .firstWhere(
            (record) => record.$2 == moveHistory?.lastOrNull?.team,
            orElse: () => (0, _teams.first),
          )
          .$1,
      _gameState = GameState.inProgress,
      _halfmoveClock = _calculateHalfmoveClock(moveHistory ?? []) {
    _updateStateAfterMove(moveHistory?.lastOrNull);
  }

  GameController.clear(this._teams)
    : assert(
        _teams.length > 1,
        'There must be at least two teams to start a game',
      ),
      _custom = null,
      _scores = _teams.scores,
      _movementManager = MovementManager(BoardState.empty(), [], _teams),
      _currentTeamIndex = 0,
      _gameState = GameState.inProgress,
      _halfmoveClock = 0;

  GameController.custom(this._teams, Map<Position, Piece> customPieces)
    : assert(
        _teams.length > 1,
        'There must be at least two teams to start a game',
      ),
      _custom = customPieces,
      _scores = _teams.scores,
      _movementManager = MovementManager(
        BoardState.custom(customPieces),
        [],
        _teams,
      ),
      _currentTeamIndex = 0,
      _gameState = GameState.inProgress,
      _halfmoveClock = 0;

  factory GameController.import(Map<String, Map<String, String>> data) {
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

    final controller = GameController.custom(teams, customPieces);

    if (data.containsKey('history')) {
      for (final MapEntry(key: teamName, value: algebraic)
          in data['history']!.entries) {
        final currentTeam = Team(teamName);
        final move = Move.fromAlgebraic(
          algebraic,
          currentTeam,
          enpassant: ({required from, required to}) {
            final position = Position(to.file, from.rank);
            final piece = controller.state[position].piece;
            if (piece is Pawn && piece.team != currentTeam) {
              return piece;
            }
            return null;
          },
          pieceAt: (position) => controller.state[position].piece,
          pieceOrigin: ({required piece, required to, required ambiguous}) {
            final squares = controller.state.squares.where(
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
  final MovementManager _movementManager;

  late int _currentTeamIndex;

  /// Number of half-moves since the last capture or pawn move.
  /// Used for the 50-move rule.
  int _halfmoveClock;
  GameState _gameState;

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
      .expand(_movementManager.possibleMovesWithCheckAndAmbiguous)
      .toList();

  void move(Move move) {
    if (_gameState != GameState.inProgress) {
      throw StateError('Cannot move pieces when the game is not in progress');
    }
    if (move is CaptureMove) {
      final teamScore = _scores.firstWhere((score) => score.team == move.team);
      teamScore.capture(Capture(move));
    }
    move = _movementManager.move(move);
    _updateHalfmoveClock(move);
    _updateStateAfterMove(move);
  }

  void pause() {
    if (_gameState case GameState.inProgress || GameState.paused) {
      throw StateError('Cannot pause when the game is not in progress');
    }
    _gameState = GameState.paused;
  }

  void draw() {
    if (_gameState == GameState.inProgress) {
      _gameState = GameState.draw;
      return;
    }
    throw StateError('Cannot draw when the game is not in progress');
  }

  void resume() {
    if (_gameState case GameState.paused || GameState.inProgress) {
      _gameState = GameState.inProgress;
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
      _gameState = GameState.teamWin;
      return;
    }
    if (_insufficientMaterial) {
      _gameState = GameState.draw;
      return;
    }
    // Fifty-move rule: if no capture or pawn move in the last 50 moves
    if (_halfmoveClock >= (_teams.length * 50)) {
      _gameState = GameState.draw;
      return;
    }
    if (move != null) {
      _nextTeam();
    }
    if (_stalemate) {
      _gameState = GameState.stalemate;
    }
  }

  int _nextTeam() =>
      _currentTeamIndex = (_currentTeamIndex + 1) % _teams.length;

  /// Get the score for a specific team
  int operator [](Team team) =>
      scores.firstWhere((score) => score.team == team).score;

  /// The current halfmove clock count - number of half-moves since last pawn
  /// move or capture
  int get halfmoveClock => _halfmoveClock;
  List<Team> get teams => List.unmodifiable(_teams);
  List<TeamScore> get scores => List.unmodifiable(_scores);
  List<Move> get history => _movementManager.moveHistory;
  BoardState get state => _movementManager.state;
  Team get currentTeam => _teams[_currentTeamIndex];
  List<Move> get nextPossibleMoves => movesFor(team: currentTeam);
  GameState get gameState => _gameState;
  bool get _stalemate => movesFor(team: currentTeam).isEmpty;

  Team? get winner =>
      _gameState == GameState.teamWin ? history.last.moving.team : null;

  Map<String, Map<String, String>> get export => {
    if (_custom case Map(:final entries) when entries.isNotEmpty)
      'custom': {
        for (final MapEntry(key: position, value: piece) in entries)
          position.toAlgebraic(): piece.export,
      },
    if (nextPossibleMoves.isNotEmpty)
      'history': {
        for (final move in nextPossibleMoves)
          move.team.name: move.toAlgebraic(),
      },
    if (teams.isNotEmpty)
      'teams': {for (final team in teams) '${team.index}': team.name},
  };

  /// Checks if the current board position has insufficient material for
  /// checkmate
  ///
  /// According to FIDE rules, the game is drawn if neither side has sufficient
  /// material to deliver checkmate. This includes:
  ///
  /// 1. King vs King
  /// 2. King vs King + Bishop/Knight (lone minor piece)
  /// 3. King + Bishop vs King + Bishop (same color squares)
  ///
  /// Examples:
  /// ```dart
  /// // King vs King - insufficient material
  /// final controller = GameController.custom([Team.white, Team.black], {
  ///   Position.e1: King.white,
  ///   Position.e8: King.black,
  /// });
  /// assert(controller._insufficientMaterial == true);
  ///
  /// // King + Queen vs King - sufficient material
  /// final controller2 = GameController.custom([Team.white, Team.black], {
  ///   Position.e1: King.white,
  ///   Position.d1: Queen.white,
  ///   Position.e8: King.black,
  /// });
  /// assert(controller2._insufficientMaterial == false);
  /// ```
  bool get _insufficientMaterial {
    final pieces = state.occupiedSquares.map((square) => square.piece).toList();

    // Count pieces by type and team
    final whitePieces = pieces
        .where((piece) => piece.team == Team.white)
        .toList();
    final blackPieces = pieces
        .where((piece) => piece.team == Team.black)
        .toList();

    // King vs King
    if (whitePieces.length == 1 && blackPieces.length == 1) {
      return whitePieces.first is King && blackPieces.first is King;
    }

    // King vs King + minor piece (Bishop or Knight)
    if ((whitePieces.length == 1 && blackPieces.length == 2) ||
        (whitePieces.length == 2 && blackPieces.length == 1)) {
      final loneKing = whitePieces.length == 1 ? whitePieces : blackPieces;
      final twoPieces = whitePieces.length == 2 ? whitePieces : blackPieces;
      if (loneKing.first is King) {
        final minorPiece = twoPieces.firstWhere((piece) => piece is! King);
        return minorPiece is Bishop || minorPiece is Knight;
      }
    }

    // King + Bishop vs King + Bishop (same color squares)
    if (whitePieces.length == 2 && blackPieces.length == 2) {
      final whiteBishops = whitePieces.whereType<Bishop>().toList();
      final blackBishops = blackPieces.whereType<Bishop>().toList();
      final whiteKings = whitePieces.whereType<King>().toList();
      final blackKings = blackPieces.whereType<King>().toList();

      if (whiteBishops.length == 1 &&
          blackBishops.length == 1 &&
          whiteKings.length == 1 &&
          blackKings.length == 1) {
        // Find bishop positions to check square colors
        final whiteBishopOnLight = state.occupiedSquares
            .firstWhere((square) => square.piece == whiteBishops.first)
            .lightSquare;
        final blackBishopOnLight = state.occupiedSquares
            .firstWhere((square) => square.piece == blackBishops.first)
            .lightSquare;

        return whiteBishopOnLight == blackBishopOnLight;
      }
    }

    return false;
  }
}
