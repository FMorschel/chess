import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/controller/check_detector.dart';
import 'package:chess_logic/src/controller/threat_detector.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/direction.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

class MovementManager {
  MovementManager(BoardState state, List<Move> moveHistory, List<Team> teams)
    : _checkDetector = CheckDetector(state),
      _moveHistory = [] {
    _checkDetector.movementManager = this;
    if (teams.isEmpty) {
      throw ArgumentError('At least one team must be provided.');
    }
    for (var team in teams) {
      canCastelling[team] = (queen: true, king: true);
    }
    for (var movement in moveHistory) {
      if (movement.moving case King(:final team)) {
        canCastelling[team] = (queen: false, king: false);
      }
      if (movement.moving case Rook(:final team)) {
        if (movement.from.file == File.a) {
          canCastelling[team] = (queen: false, king: canCastelling[team]!.king);
        } else if (movement.from.file == File.h) {
          canCastelling[team] = (
            queen: canCastelling[team]!.queen,
            king: false,
          );
        }
      }
      _moveHistory.add(move(movement));
    }
  }

  late final List<Move> _moveHistory;
  final CheckDetector _checkDetector;

  Map<Team, ({bool queen, bool king})> canCastelling = {};

  BoardState get state => _checkDetector.state;
  List<Move> get moveHistory => List.unmodifiable(_moveHistory);
  ThreatDetector get threatDetector => _checkDetector.threatDetector;

  @visibleForTesting
  CheckDetector get checkDetector => _checkDetector;

  Move move(Move move) {
    final checkValues = _checkDetector.moveWouldCreateCheck(move);
    var check = checkValues.values.maxOrNull ?? Check.none;
    if (check != Check.none) {
      move = move.copyWith(check: check);
    }
    _moveHistory.add(move);
    state.actOn(move);
    return move;
  }

  bool isTeamInCheck(Team team) => _checkDetector.isTeamInCheck(team);

  /// Returns a list of all possible moves for the given square with check detection.
  List<Move> possibleMovesWithCheck(Square square) {
    if (square is! OccupiedSquare) {
      return const [];
    }
    final moves = possibleMoves(square);
    final movesWithCheck = <Move>[];

    for (final move in [...moves]) {
      final results = _checkDetector.moveWouldCreateCheck(move);
      // Check if this move would put or leave own king in check
      final ownCheckStatus = results[square.piece.team] ?? Check.none;
      if (ownCheckStatus != Check.none) {
        moves.remove(move);
        continue;
      }
      var checkStatus = results.values.maxOrNull ?? Check.none;
      final moveWithCheck = move.copyWith(check: checkStatus);
      movesWithCheck.add(moveWithCheck);
    }

    return movesWithCheck;
  }

  /// Returns a list of all possible moves for the given square.
  ///
  /// If [untracked] is provided, it will be considered as the last move.
  List<Move> possibleMoves(Square square, {Move? untracked}) {
    if (square is! OccupiedSquare) {
      return const [];
    }
    final piece = square.piece;
    final moves = <Move>[];
    switch (piece) {
      case King():
        final positions = piece.validPositions(state, square.position);
        final (:king, :queen) = canCastelling[square.piece.team]!;
        for (var (position, direction) in piece.rookPositions) {
          final rookDestination = square.position.next(direction);
          final destination = rookDestination?.next(direction);
          if (destination == null ||
              rookDestination == null ||
              !positions.contains(destination)) {
            continue;
          }
          positions.remove(destination);
          if (queen && position.file == File.a) {
            final rook = state[position].piece;
            if (rook is! Rook || rook.team != piece.team) {
              continue;
            }
            moves.add(
              QueensideCastling(
                from: square.position,
                to: destination,
                moving: piece,
                rook: RookMove(
                  from: position,
                  to: rookDestination,
                  moving: rook,
                ),
              ),
            );
          } else if (king && position.file == File.h) {
            final rook = state[position].piece;
            if (rook is! Rook) {
              continue;
            }
            moves.add(
              KingsideCastling(
                from: square.position,
                to: destination,
                moving: piece,
                rook: RookMove(
                  from: position,
                  to: rookDestination,
                  moving: rook,
                ),
              ),
            );
          }
        }
        for (var position in positions) {
          var anotherKingSide = false;
          for (final direction in Direction.orthogonal) {
            if (position.next(direction) case final next?
                when state[next].piece != piece &&
                    state[next].piece?.symbol == PieceSymbol.king) {
              anotherKingSide = true;
              break;
            }
          }
          if (anotherKingSide) {
            continue; // Skip positions that would put own king in check
          }
          final capture = state[position].piece;
          if (capture != null) {
            if (capture.team == square.piece.team) {
              continue;
            }
            moves.add(
              KingCaptureMove(
                from: square.position,
                to: position,
                moving: piece,
                captured: capture,
              ),
            );
            continue;
          }
          moves.add(
            KingMove(from: square.position, to: position, moving: piece),
          );
        }
      case Pawn():
        final positions = piece.validPositions(
          state,
          square.position,
          lastMove: untracked ?? moveHistory.lastOrNull,
        );
        for (var direction in piece.captureDirections) {
          var position = square.position.next(direction);
          if (position == null ||
              !positions.contains(position) ||
              (state[position].piece?.team != null &&
                  state[position].piece?.team != piece.team)) {
            continue;
          }
          positions.remove(position);
          if ((untracked ?? moveHistory.lastOrNull) case PawnInitialMove(
            :final to,
            moving: final pawn,
          )) {
            if (to.file == position.file && to.rank == square.position.rank) {
              moves.add(
                EnPassantMove(
                  from: square.position,
                  to: position,
                  moving: piece,
                  captured: pawn,
                ),
              );
            }
          }
        }
        for (var position in positions) {
          final capture = state[position].piece;
          if (capture != null) {
            if (capture.team == square.piece.team) {
              continue;
            }
            moves.add(
              PawnCaptureMove(
                from: square.position,
                to: position,
                moving: piece,
                captured: capture,
              ),
            );
            continue;
          }
          final rankDiff = square.position.rank.distanceTo(position.rank);
          if (rankDiff > 1) {
            moves.add(
              PawnMove.initial(
                pawn: piece,
                from: square.position,
                to: position,
              ),
            );
          } else {
            moves.add(
              PawnMove(from: square.position, to: position, moving: piece),
            );
          }
        }
      default:
        for (var position in piece.validPositions(state, square.position)) {
          final capture = state[position].piece;
          if (capture != null) {
            if (capture.team == square.piece.team) {
              continue;
            }
            moves.add(
              CaptureMove.create(
                from: square.position,
                to: position,
                moving: piece,
                captured: capture,
              ),
            );
            continue;
          }
          moves.add(
            Move.create(from: square.position, to: position, moving: piece),
          );
        }
    }
    return moves;
  }
}
