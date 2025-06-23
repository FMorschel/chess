import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../move/ambiguous_movement_type.dart';
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
import 'threat_detector.dart';

class MovementManager {
  MovementManager(BoardState state, List<Move> moveHistory, List<Team> teams)
    : _checkDetector = CheckDetector(state),
      _moveHistory = [] {
    _checkDetector.movementManager = this;
    if (teams.isEmpty) {
      throw ArgumentError('At least one team must be provided.');
    }
    for (final team in teams) {
      _canCastelling[team] = (queen: true, king: true);
    }
    for (final movement in moveHistory) {
      if (movement.moving case King(:final team)) {
        _canCastelling[team] = (queen: false, king: false);
      }
      if (movement.moving case Rook(:final team)) {
        if (movement.from.file == File.a) {
          _canCastelling[team] = (
            queen: false,
            king: _canCastelling[team]!.king,
          );
        } else if (movement.from.file == File.h) {
          _canCastelling[team] = (
            queen: _canCastelling[team]!.queen,
            king: false,
          );
        }
      }
      move(movement);
    }
  }

  final CheckDetector _checkDetector;
  final Map<Team, ({bool queen, bool king})> _canCastelling = {};

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
  List<Move> possibleMovesWithCheckAndAmbiguous(Square square) {
    if (square is! OccupiedSquare) {
      return const [];
    }
    final moves = possibleMoves(square);
    final movesWithCheckAndAmbiguous = <Move>[];

    for (final move in [...moves]) {
      final results = _checkDetector.moveWouldCreateCheck(move);
      // Check if this move would put or leave own king in check
      final ownCheckStatus = results[square.piece.team] ?? Check.none;
      if (ownCheckStatus != Check.none) {
        moves.remove(move);
        continue;
      }
      final checkStatus = results.values.maxOrNull ?? Check.none;
      final ambiguousType = _detectAmbiguousMove(move);
      final moveWithUpdatedFields = move.copyWith(
        check: checkStatus,
        ambiguous: ambiguousType,
      );
      movesWithCheckAndAmbiguous.add(moveWithUpdatedFields);
    }

    return movesWithCheckAndAmbiguous;
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
        final kingIsInCheck = _checkDetector.isTeamInCheck(piece.team);
        final (:king, :queen) = _canCastelling[square.piece.team]!;
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

  /// Detects if a move is ambiguous (multiple pieces of the same type
  /// can move to the same destination).
  ///
  /// Returns the [AmbiguousMovementType] if the move is ambiguous,
  /// or null if it's not ambiguous.
  AmbiguousMovementType? _detectAmbiguousMove(Move move) {
    final piece = move.moving;
    final destination = move.to;

    // Find all pieces of the same type and team that can move to the same
    // destination
    final samePieceSquares = <OccupiedSquare>[];
    for (final square in state.occupiedSquares) {
      if (square.piece.symbol == piece.symbol &&
          square.piece.team == piece.team &&
          square.position != move.from) {
        final squareMoves = possibleMoves(square);
        if (squareMoves.any((m) => m.to == destination)) {
          samePieceSquares.add(square);
        }
      }
    }

    // If no other pieces can move to the same destination, not ambiguous
    if (samePieceSquares.isEmpty) {
      return null;
    }

    // Check if disambiguation is needed by file, rank, or both
    final currentFile = move.from.file;
    final currentRank = move.from.rank;

    bool needsRankDisambiguation = false;
    bool needsFileDisambiguation = false;

    for (final square in samePieceSquares) {
      if (square.position.file == currentFile) {
        needsRankDisambiguation = true;
      }
      if (square.position.rank == currentRank) {
        needsFileDisambiguation = true;
      }
      // If pieces are not aligned but two of the same type can get to the same
      // destination, we are handling diagonals and such we need file
      // disambiguation
      if (!needsRankDisambiguation && !needsFileDisambiguation) {
        needsFileDisambiguation = true;
      }
    }

    // Determine the type of disambiguation needed
    if (needsRankDisambiguation && needsFileDisambiguation) {
      return AmbiguousMovementType.both;
    }
    if (needsFileDisambiguation) {
      return AmbiguousMovementType.file;
    }
    if (needsRankDisambiguation) {
      return AmbiguousMovementType.rank;
    }
    return null; // Default to file if unclear
  }

  @visibleForTesting
  Map<Team, ({bool queen, bool king})> get canCastelling => _canCastelling;

  BoardState get state => _checkDetector.state;
  List<Move> get moveHistory => List.unmodifiable(_moveHistory);
  ThreatDetector get threatDetector => _checkDetector.threatDetector;

  @visibleForTesting
  CheckDetector get checkDetector => _checkDetector;
}
