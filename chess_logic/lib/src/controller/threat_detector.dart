import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';

/// Service for detecting threats against specific pieces and positions.
///
/// This class provides efficient threat detection functionality that can be
/// used as a foundation for check detection, move validation, and strategic
/// analysis.
class ThreatDetector {
  const ThreatDetector(this.state);

  final BoardState state;

  /// Checks if a specific piece at the given position is threatened by any
  /// opponent piece.
  ///
  /// [square] - The occupied square containing the piece to check
  ///
  /// Returns true if the piece/position is under attack by any opponent piece.
  bool isPieceUnderThreat(Square square) {
    if (square is! OccupiedSquare) {
      return false; // Only check occupied squares
    }
    return isPositionUnderAttackFor(square.position, square.piece.team);
  }

  /// Checks if a position is under attack by any piece from the specified
  /// attacking team.
  ///
  /// [position] - The position to check
  /// [team] - The team whose pieces might be attacking this position
  ///
  /// Returns true if any piece from another team can legally move to this
  /// position.
  bool isPositionUnderAttackFor(Position position, Team team) {
    for (final square in state.occupiedSquares) {
      if (square.piece.team != team) {
        if (canPieceAttackPosition(square, position)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Checks if a specific piece can attack a specific position.
  ///
  /// [square] - The square containing the piece
  /// [targetPosition] - The position to check if it can be attacked
  ///
  /// Returns true if the piece can legally attack the target position.
  bool canPieceAttackPosition(Square square, Position targetPosition) {
    if (square is! OccupiedSquare) {
      return false; // Only check occupied squares
    }
    final validPositions = square.piece.validPositions(state, square.position);
    return validPositions.contains(targetPosition);
  }

  /// Gets all pieces that are threatening a specific square.
  ///
  /// Returns a list of [OccupiedSquare]s representing all threats.
  List<OccupiedSquare> getThreateningPieces(Square square) {
    if (square is! OccupiedSquare) {
      return const []; // Only check occupied squares
    }
    final threatening = <OccupiedSquare>[];

    for (final current in state.occupiedSquares) {
      if (square.piece.team != current.piece.team &&
          canPieceAttackPosition(current, square.position)) {
        threatening.add(current);
      }
    }

    return threatening;
  }

  /// Gets all positions that a specific piece is threatening.
  ///
  /// [piece] - The piece to analyze
  /// [piecePosition] - Current position of the piece
  ///
  /// Returns a list of all positions this piece can attack.
  List<Position> getThreatenedPositions(Piece piece, Position piecePosition) {
    return piece.validPositions(state, piecePosition);
  }

  /// Checks if moving a piece would expose another piece to threat.
  ///
  /// [move] - The move being evaluated
  /// [exposedPosition] - Position of the piece that might be exposed
  ///
  /// Returns true if the move would expose the piece at exposedPosition to
  /// threat.
  bool wouldMoveExposePieceToThreat(Move move, Square exposedPosition) {
    if (isPieceUnderThreat(exposedPosition)) {
      return false; // The piece is already under threat
    }

    // Apply the move temporarily
    state.move(move);

    // Check if the exposed piece is now under threat
    final isExposed = isPieceUnderThreat(exposedPosition);

    // Undo the move to restore the original state
    state.undo(move);

    return isExposed;
  }

  /// Checks if a position would be safe for a piece of the given team.
  ///
  /// [position] - The position to check
  /// [team] - The team of the piece that would occupy this position
  ///
  /// Returns true if a piece from the given team would be safe at this
  /// position.
  bool isPositionSafeFor(Position position, Team team) {
    return !isPositionUnderAttackFor(position, team);
  }

  /// Checks if a specific piece type is threatening a square.
  ///
  /// Returns true if any piece of the specified type from the another team
  /// threatens this position.
  bool isPieceTypeThreateningPosition<T extends Piece>(Square square) {
    if (square is! OccupiedSquare) {
      return false; // Only check occupied squares
    }
    final threatening = getThreateningPieces(square);
    return threatening.any((record) => record.piece is T);
  }

  /// Checks if moving a piece would resolve a currently threatened piece.
  ///
  /// [move] - The move being evaluated
  /// [threatenedPosition] - Position of the piece that is currently threatened
  ///
  /// Returns true if the move would resolve the threat against the piece at
  /// threatenedPosition (i.e., the piece is currently under threat but would
  /// be safe after the move).
  bool wouldMoveResolvePieceThreat(Move move, Square threatenedPosition) {
    if (!isPieceUnderThreat(threatenedPosition)) {
      return false; // The piece is not currently under threat
    }

    // Apply the move temporarily
    try {
      state.move(move);
    } catch (_) {
      return false;
    }

    bool isNowSafe;

    // If the move involves moving the threatened piece itself,
    // check the destination position; otherwise check the original position
    if (move.from == threatenedPosition.position) {
      final destinationSquare = state[move.to];
      isNowSafe = !isPieceUnderThreat(destinationSquare);
    } else {
      // Check if the threatened piece is now safe at its original position
      isNowSafe = !isPieceUnderThreat(threatenedPosition);
    }

    // Undo the move to restore the original state
    state.undo(move);

    return isNowSafe;
  }
}
