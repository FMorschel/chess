import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/controller/check_detector.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';

class MovementManager {
  MovementManager(this.state, this._moveHistory, List<Team> teams) {
    if (teams.isEmpty) {
      throw ArgumentError('At least one team must be provided.');
    }
    for (var team in teams) {
      canCastelling[team] = (queen: true, king: true);
    }
    for (var movement in _moveHistory) {
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
    }
  }

  final BoardState state;
  final List<Move> _moveHistory;
  late final CheckDetector _checkDetector = CheckDetector(state);

  List<Move> get moveHistory => List.unmodifiable(_moveHistory);

  Map<Team, ({bool queen, bool king})> get canCastelling => {};

  /// Returns a list of all possible moves for the given square with check detection.
  List<Move> possibleMovesWithCheck(Square square) {
    final moves = possibleMoves(square);
    final movesWithCheck = <Move>[];

    for (final move in moves) {
      final checkStatus = _checkDetector.detectCheckAfterMove(move);
      final moveWithCheck = move.copyWith(check: checkStatus);
      movesWithCheck.add(moveWithCheck);
    }

    return movesWithCheck;
  }

  /// Detects check status for a given move.
  Check detectCheck(Move move) {
    return _checkDetector.detectCheckAfterMove(move);
  }

  /// Returns a list of all possible moves for the given square.
  List<Move> possibleMoves(Square square) {
    if (square.isEmpty) {
      return [];
    }
    final piece = square.piece!;
    final positions = piece.validPositions(state, square.position);
    final moves = <Move>[];
    switch (piece) {
      case King():
        final (:king, :queen) = canCastelling[square.piece!.team]!;
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
            if (rook is! Rook) {
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
          final capture = state[position].piece;
          if (capture != null) {
            if (capture.team == square.piece!.team) {
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
        for (var direction in piece.captureDirections) {
          var position = square.position.next(direction);
          if (position == null ||
              state[position].isOccupied ||
              !positions.contains(position)) {
            continue;
          }
          positions.remove(position);
          if (moveHistory.lastOrNull case PawnInitialMove(
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
            if (capture.team == square.piece!.team) {
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
          }
          moves.add(
            PawnMove(from: square.position, to: position, moving: piece),
          );
        }
      default:
        for (var position in positions) {
          final capture = state[position].piece;
          if (capture != null) {
            if (capture.team == square.piece!.team) {
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
