import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';

/// Service for detecting check and checkmate states in chess.
class CheckDetector {
  const CheckDetector(this.state);

  final BoardState state;

  /// Detects if making the given move results in check or checkmate.
  ///
  /// This method:
  /// 1. Temporarily applies the move to the board
  /// 2. Checks if the opponent's king is in check
  /// 3. If in check, determines if it's checkmate by testing all possible escape moves
  /// 4. Restores the original board state
  ///
  /// Returns [Check.none] if no check, [Check.check] if check, or [Check.checkmate] if checkmate.
  Check detectCheckAfterMove(Move move) {
    // Apply the move temporarily
    state.actOn(move);

    try {
      // Determine the opponent's team
      final opponentTeam = move.moving.team == Team.white
          ? Team.black
          : Team.white;

      // Check if the opponent's king is in check
      final kingPosition = _findKingPosition(opponentTeam);
      if (kingPosition == null) {
        // No king found (shouldn't happen in a valid game)
        return Check.none;
      }

      final isInCheck = _isPositionUnderAttack(kingPosition, move.moving.team);

      if (!isInCheck) {
        return Check.none;
      }

      // King is in check, now determine if it's checkmate
      final isCheckmate = _isCheckmate(opponentTeam);

      return isCheckmate ? Check.checkmate : Check.check;
    } finally {
      // Always restore the original board state
      state.undo(move);
    }
  }

  /// Finds the position of the king for the given team.
  Position? _findKingPosition(Team team) {
    for (final square in state.squares) {
      if (square.piece case King(
        team: final pieceTeam,
      ) when pieceTeam == team) {
        return square.position;
      }
    }
    return null;
  }

  /// Checks if a position is under attack by any piece from the attacking team.
  bool _isPositionUnderAttack(Position position, Team attackingTeam) {
    for (final square in state.squares) {
      if (square.piece?.team == attackingTeam) {
        final piece = square.piece!;
        final attackPositions = piece.validPositions(state, square.position);
        if (attackPositions.contains(position)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Determines if the given team is in checkmate.
  ///
  /// A team is in checkmate if:
  /// 1. Their king is in check
  /// 2. No legal move can get the king out of check
  bool _isCheckmate(Team team) {
    // Get all pieces of the team
    final teamSquares = state.squares.where((sq) => sq.piece?.team == team);

    for (final square in teamSquares) {
      final piece = square.piece!;
      final possiblePositions = piece.validPositions(state, square.position);

      for (final position in possiblePositions) {
        // Create a test move
        final testMove = _createTestMove(piece, square.position, position);

        if (testMove != null && _wouldMoveEscapeCheck(testMove, team)) {
          return false; // Found a legal move that escapes check
        }
      }
    }

    return true; // No legal moves found that escape check
  }

  /// Creates a test move for checking if it would escape check.
  Move? _createTestMove(Piece piece, Position from, Position to) {
    final capturedPiece = state[to].piece;

    try {
      if (capturedPiece != null) {
        // This is a capture move
        return CaptureMove.create(
          from: from,
          to: to,
          moving: piece,
          captured: capturedPiece,
        );
      } else {
        // This is a regular move
        return Move.create(from: from, to: to, moving: piece);
      }
    } catch (e) {
      // If move creation fails (e.g., invalid move), return null
      return null;
    }
  }

  /// Tests if making the given move would get the team out of check.
  bool _wouldMoveEscapeCheck(Move move, Team team) {
    try {
      // Apply the test move
      state.actOn(move);

      // Find the king position after the move
      final kingPosition = _findKingPosition(team);
      if (kingPosition == null) {
        return false;
      }

      // Check if the king is still under attack
      final opponentTeam = team == Team.white ? Team.black : Team.white;
      final stillInCheck = _isPositionUnderAttack(kingPosition, opponentTeam);

      return !stillInCheck;
    } catch (e) {
      // If the move is invalid, it doesn't escape check
      return false;
    } finally {
      // Restore the board state
      state.undo(move);
    }
  }
}
