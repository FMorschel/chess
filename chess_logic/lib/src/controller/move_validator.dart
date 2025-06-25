import 'package:collection/collection.dart';

import '../move/ambiguous_movement_type.dart';
import '../move/check.dart';
import '../move/move.dart';
import '../square/piece.dart';
import '../square/square.dart';
import '../team/team.dart';
import 'board_state.dart';
import 'check_detector.dart';
import 'game_rule_engine.dart';

/// Service for validating chess moves and enriching them with additional
/// information.
///
/// This class handles:
/// - Legal move validation (not putting own king in check)
/// - Move enrichment with check status and ambiguity information
/// - Filtering invalid moves from possible move lists
class MoveValidator {
  MoveValidator(
    this.state, {
    required this.checkDetector,
    required List<Move<Piece>> Function(Square<Piece>, {Move<Piece>? untracked})
    moveGenerator,
  }) : _moveGenerator = moveGenerator;

  final BoardState state;

  final CheckDetector checkDetector;

  /// Function that generates all possible moves for a piece without
  /// considering check restrictions.
  final List<Move<Piece>> Function(Square square, {Move<Piece>? untracked})
  _moveGenerator;

  /// Generates and enriches a list of possible moves.
  ///
  /// This method filters out moves that would put the player's own king
  /// in check and enriches each valid [Move] with:
  /// - Check status: whether the move puts the opponent in check
  /// - Ambiguous type: whether multiple pieces can make the same move
  ///
  /// Returns an empty list if the square is not occupied.
  List<Move> createValidMoves(
    Square square,
    List<Move> history,
    GameRuleEngine ruleEngine,
  ) {
    if (square is! OccupiedSquare) {
      return const [];
    }

    final possibleMoves = _moveGenerator(square, untracked: history.lastOrNull);
    final validMoves = <Move>[];

    for (final move in possibleMoves) {
      if (move is CastlingMove) {
        ruleEngine.isCastlingLegal(
          move,
          state,
          history,
          checkDetector.threatDetector.isPositionSafeFor,
        );
      }

      if (!isMoveLegal(move, square.piece.team)) {
        continue; // Skip illegal moves that put own king in check
      }

      final enrichedMove = enrichMoveWithCheckAndAmbiguity(move);
      validMoves.add(enrichedMove);
    }

    return validMoves;
  }

  /// Checks if a move is legal (doesn't put own king in check).
  ///
  /// [move] - The move to validate
  /// [team] - The team making the move
  ///
  /// Returns false if the move would put or leave the team's king in check.
  bool isMoveLegal(Move move, Team team) {
    final checkResults = checkDetector.moveWouldCreateCheck(move);
    final ownCheckStatus = checkResults[team] ?? Check.none;
    return ownCheckStatus == Check.none;
  }

  /// Enriches a move with check status and ambiguity information.
  ///
  /// [move] - The move to enrich
  ///
  /// Returns a new move with updated check and ambiguous fields.
  Move enrichMoveWithCheckAndAmbiguity(Move move) {
    final checkResults = checkDetector.moveWouldCreateCheck(move);
    final checkStatus = checkResults.values.maxOrNull ?? Check.none;
    final ambiguousType = detectAmbiguousMove(move);

    return move.copyWith(check: checkStatus, ambiguous: ambiguousType);
  }

  /// Detects if a move is ambiguous (multiple pieces can make the same move).
  ///
  /// [move] - The move to check for ambiguity
  ///
  /// Returns the type of ambiguity or [AmbiguousMovementType.none] if not
  /// ambiguous.
  AmbiguousMovementType detectAmbiguousMove(Move move) {
    final movingPiece = move.moving;
    final targetPosition = move.to;
    final sourcePosition = move.from;

    // Find all pieces of the same type and team that could move to the same
    // target position
    final candidatePieces = <OccupiedSquare>[];

    for (final square in state.occupiedSquares) {
      final piece = square.piece;
      if (piece.runtimeType == movingPiece.runtimeType &&
          piece.team == movingPiece.team &&
          square.position != sourcePosition) {
        // Check if this piece can also move to the target position
        final pieceMoves = _moveGenerator(square);
        final canMoveToTarget = pieceMoves.any((m) => m.to == targetPosition);

        if (canMoveToTarget) {
          candidatePieces.add(square);
        }
      }
    }
    if (candidatePieces.isEmpty) {
      return AmbiguousMovementType.none;
    }

    // Check if disambiguation by file is sufficient
    final sameFile = candidatePieces.any(
      (square) => square.position.file == sourcePosition.file,
    );
    if (!sameFile) {
      return AmbiguousMovementType.file;
    }

    // Check if disambiguation by rank is sufficient
    final sameRank = candidatePieces.any(
      (square) => square.position.rank == sourcePosition.rank,
    );
    if (!sameRank) {
      return AmbiguousMovementType.rank;
    }

    // If both file and rank have conflicts, use full position
    return AmbiguousMovementType.both;
  }

  /// Checks if a move would be legal if executed.
  ///
  /// This is a more comprehensive check that validates the move without
  /// actually executing it on the board.
  ///
  /// [move] - The move to validate
  ///
  /// Returns true if the move is legal in the current position.
  bool wouldMoveBeLegal(Move move) {
    // Basic validation: check if the piece can make this move
    final fromSquare = state[move.from];
    if (fromSquare is! OccupiedSquare) {
      return false; // No piece at source position
    }

    if (fromSquare.piece != move.moving) {
      return false; // Different piece than expected
    }

    // Check if the move is in the list of possible moves
    final possibleMoves = _moveGenerator(fromSquare);
    final moveExists = possibleMoves.contains(move);

    if (!moveExists) {
      return false; // Move not possible according to piece rules
    }

    // Check if the move is legal (doesn't put own king in check)
    return isMoveLegal(move, move.moving.team);
  }

  /// Validates a capture move specifically.
  ///
  /// [move] - The capture move to validate
  ///
  /// Returns true if the capture is legal.
  bool isCaptureMoveLegal(CaptureMove move) {
    final targetSquare = state[move.to];
    if (targetSquare is! OccupiedSquare) {
      return false; // No piece to capture
    }

    if (targetSquare.piece.team == move.moving.team) {
      return false; // Cannot capture own piece
    }

    if (targetSquare.piece != move.captured) {
      return false; // Different piece than expected
    }

    return wouldMoveBeLegal(move);
  }

  /// Validates all moves in a list and returns only the legal ones.
  ///
  /// [moves] - List of moves to validate
  ///
  /// Returns a filtered list containing only legal moves.
  List<Move> filterLegalMoves(List<Move> moves) {
    return moves.where(wouldMoveBeLegal).toList();
  }
}
