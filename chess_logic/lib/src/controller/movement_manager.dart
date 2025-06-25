import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../move/check.dart';
import '../move/move.dart';
import '../position/direction.dart';
import '../position/file.dart';
import '../position/position.dart';
import '../square/piece.dart';
import '../square/piece_symbol.dart';
import '../square/square.dart';
import '../team/team.dart';
import 'board_state.dart';
import 'check_detector.dart';
import 'game_rule_engine.dart';
import 'move_validator.dart';
import 'threat_detector.dart';

class MovementManager {
  MovementManager(BoardState state, List<Move> moveHistory, List<Team> teams)
    : _moveHistory = [] {
    _checkDetector = CheckDetector(
      state,
      moveGenerator: possibleMovesNoValidation,
    );
    _moveValidator = MoveValidator(
      state,
      checkDetector: _checkDetector,
      moveGenerator: possibleMovesNoValidation,
    );
    if (teams.isEmpty) {
      throw ArgumentError('At least one team must be provided.');
    }
    for (final movement in moveHistory) {
      move(movement);
    }
  }

  late final CheckDetector _checkDetector;
  late final MoveValidator _moveValidator;
  late final List<Move> _moveHistory;

  Move move(Move move) {
    final checkValues = _checkDetector.moveWouldCreateCheck(move);
    final check = checkValues.values.maxOrNull ?? Check.none;
    if (check != Check.none) {
      move = move.copyWith(check: check);
    }
    state.move(move);
    _moveHistory.add(move);
    return move;
  }

  bool isTeamInCheck(Team team) => _checkDetector.isTeamInCheck(team);

  /// Returns a list of all legal moves for the given square with check
  /// and ambiguous move detection.
  ///
  /// This method filters out moves that would put the player's own king
  /// in check and enriches each valid [Move] with:
  /// - Check status: whether the move puts the opponent in check
  /// - Ambiguous type: whether multiple pieces can make the same move
  ///
  /// Returns an empty list if the square is not occupied.
  List<Move> possibleMoves(Square square, GameRuleEngine ruleEngine) =>
      _moveValidator.createValidMoves(square, moveHistory, ruleEngine);

  /// Returns a list of all possible moves for the given square.
  ///
  /// If [untracked] is provided, it will be considered as the last move.
  @visibleForTesting
  List<Move> possibleMovesNoValidation(Square square, {Move? untracked}) {
    if (square is! OccupiedSquare) {
      return const [];
    }
    final piece = square.piece;
    final moves = <Move>[];
    switch (piece) {
      case King():
        final positions = piece.validPositions(state, square.position);
        final kingIsInCheck = _checkDetector.isTeamInCheck(piece.team);
        for (final (position, direction) in piece.rookPositions) {
          final rookDestination = square.position.next(direction);
          final destination = rookDestination?.next(direction);
          if (destination == null ||
              rookDestination == null ||
              !positions.contains(destination)) {
            continue;
          }
          positions.remove(destination);
          if (!kingIsInCheck) {
            final rook = state[position].piece;
            if (rook is! Rook || rook.team != piece.team) {
              continue;
            }
            if (position.file == File.a) {
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
            } else if (position.file == File.h) {
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
        }
        for (final position in positions) {
          var anotherKingSide = false;
          for (final direction in Direction.octagonal) {
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
          Position? _;
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
        for (final direction in piece.captureDirections) {
          final position = square.position.next(direction);
          if (position == null ||
              !positions.contains(position) ||
              (state[position].piece?.team != null &&
                  state[position].piece?.team != piece.team)) {
            continue;
          }
          positions.remove(position);
          if (untracked ?? moveHistory.lastOrNull case PawnInitialMove(
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
        for (final position in positions) {
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
        for (final position in piece.validPositions(state, square.position)) {
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

  BoardState get state => _checkDetector.state;
  List<Move> get moveHistory => List.unmodifiable(_moveHistory);
  ThreatDetector get threatDetector => _checkDetector.threatDetector;

  @visibleForTesting
  CheckDetector get checkDetector => _checkDetector;

  @visibleForTesting
  MoveValidator get moveValidator => _moveValidator;
}
