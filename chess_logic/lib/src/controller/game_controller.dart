import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/controller/capture.dart';
import 'package:chess_logic/src/controller/game_state.dart';
import 'package:chess_logic/src/controller/movement_manager.dart';
import 'package:chess_logic/src/controller/team_score.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:chess_logic/src/utility/extensions.dart';
import 'package:collection/collection.dart';

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
        BoardState(history: moveHistory),
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
            final position = Position._(to.file, from.rank);
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
  GameState _gameState;

  /// Number of half-moves since the last capture or pawn move.
  /// Used for the 50-move rule.
  int _halfmoveClock;

  List<Team> get teams => List.unmodifiable(_teams);
  List<TeamScore> get scores => List.unmodifiable(_scores);
  List<Move> get history => _movementManager.moveHistory;
  BoardState get state => _movementManager.state;
  Team get currentTeam => _teams[_currentTeamIndex];
  List<Move> get nextPossibleMoves => movesFor(team: currentTeam);
  GameState get gameState => _gameState;
  Team? get winner =>
      _gameState == GameState.teamWin ? history.last.moving.team : null;

  /// The current halfmove clock count - number of half-moves since last pawn
  /// move or capture
  int get halfmoveClock => _halfmoveClock;

  List<Move> movesFor({Team? team, Position? position}) => state.occupiedSquares
      .where(
        (square) =>
            (team == null || square.piece.team == team) &&
            (position == null || square.position == position),
      )
      .expand((square) => _movementManager.possibleMovesWithCheck(square))
      .toList();

  void move(Move move) {
    if (_gameState != GameState.inProgress) {
      throw StateError('Cannot move pieces when the game is not in progress');
    }
    if (move is CaptureMove) {
      var teamScore = _scores.firstWhere((score) => score.team == move.team);
      teamScore.capture(Capture(move));
    }
    move = _movementManager.move(move);
    _updateHalfmoveClock(move);
    _updateStateAfterMove(move);
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
    if (move != null && move.check == Check.checkmate) {
      _gameState = GameState.teamWin;
    }
    if (_insufficientMaterial) {
      _gameState = GameState.draw;
    }
    // Fifty-move rule: if no capture or pawn move in the last 50 moves
    if (_halfmoveClock >= (_teams.length * 50)) {
      _gameState = GameState.draw;
    }
    if (move != null) _nextTeam();
    if (_stalemate) {
      _gameState = GameState.stalemate;
    }
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

  int _nextTeam() =>
      _currentTeamIndex = (_currentTeamIndex + 1) % _teams.length;

  /// Get the score for a specific team
  int operator [](Team team) =>
      scores.firstWhere((score) => score.team == team).score;

  Map<String, Map<String, String>> get export => {
    if (_custom case Map(:var entries) when entries.isNotEmpty)
      'custom': {
        for (var MapEntry(key: position, value: piece) in entries)
          position.toAlgebraic(): piece.export,
      },
    if (nextPossibleMoves.isNotEmpty)
      'history': {
        for (var move in nextPossibleMoves) move.team.name: move.toAlgebraic(),
      },
    if (teams.isNotEmpty)
      'teams': {for (var team in teams) '${team.index}': team.name},
  };

  bool get _stalemate => movesFor(team: currentTeam).isEmpty;

  /// Checks if the current board position has insufficient material for checkmate
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

  /// Calculate the halfmove clock based on the move history.
  static int _calculateHalfmoveClock(List<Move> moveHistory) {
    if (moveHistory.isEmpty) return 0;
    var halfmoveClock = 0;
    var lastMoveIndex = moveHistory.length - 1;
    do {
      var lastMove = moveHistory[lastMoveIndex];
      if (lastMove is CaptureMove || lastMove.moving is Pawn) {
        return halfmoveClock;
      }
      halfmoveClock++;
      lastMoveIndex--;
    } while (lastMoveIndex >= 0 && halfmoveClock < 100);
    return halfmoveClock;
  }
}
