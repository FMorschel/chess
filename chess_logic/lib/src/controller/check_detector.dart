import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/controller/movement_manager.dart';
import 'package:chess_logic/src/controller/threat_detector.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/position/rank.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';

/// Service for detecting check and checkmate states in chess.
///
/// This is typically used inside a [MovementManager] to evaluate moves
/// and determine if they would result in check or checkmate for any team.
class CheckDetector {
  CheckDetector(BoardState state) : threatDetector = ThreatDetector(state);

  final ThreatDetector threatDetector;

  late MovementManager _movementManager;

  /// The movement manager used to evaluate possible moves.
  ///
  /// Must operate on the same [BoardState] as [state].
  ///
  /// This is intended to be set after the [CheckDetector] is created,
  /// typically by the [MovementManager] itself.
  set movementManager(MovementManager manager) {
    if (manager.state != state) {
      throw ArgumentError(
        'MovementManager must operate on the same BoardState as ThreatDetector',
      );
    }
    _movementManager = manager;
  }

  BoardState get state => threatDetector.state;

  /// Evaluates if a move would create check or checkmate for any team.
  ///
  /// [move] - The move to evaluate
  ///
  /// Returns a map with teams as keys and their check status as values.
  /// Only includes teams that would be in check or checkmate.
  Map<Team, Check> moveWouldCreateCheck(Move<Piece> move) {
    final result = <Team, Check>{};

    // Apply the move temporarily
    state.actOn(move);

    // Check all teams for check/checkmate
    for (final team in Team.values) {
      final checkStatus = _evaluateCheckStatusForTeam(team, move);
      if (checkStatus != Check.none) {
        result[team] = checkStatus;
      }
    }

    // Undo the move to restore the original state
    state.undo(move);

    return result;
  }

  bool isTeamInCheck(Team team) {
    final kingSquare = _findKing(team);
    if (kingSquare == null) {
      return false; // No king found (shouldn't happen in normal chess)
    }
    return threatDetector.isPieceUnderThreat(kingSquare);
  }

  /// Evaluates the check status for a specific team.
  ///
  /// [team] - The team to evaluate
  /// [move] - The move that has been made
  ///
  /// Returns the check status (none, check, or checkmate).
  Check _evaluateCheckStatusForTeam(Team team, Move move) {
    final kingSquare = _findKing(team);
    if (kingSquare == null) {
      return Check.none; // No king found (shouldn't happen in normal chess)
    }

    final isInCheck = threatDetector.isPieceUnderThreat(kingSquare);
    if (!isInCheck) {
      return Check.none;
    }

    // King is in check, determine if it's checkmate
    final isCheckmate = _isCheckmate(team, kingSquare, move);
    return isCheckmate ? Check.checkmate : Check.check;
  }

  /// Finds the king for the specified team.
  ///
  /// [team] - The team whose king to find
  ///
  /// Returns the occupied square containing the king, or null if not found.
  OccupiedSquare? _findKing(Team team) {
    for (final square in state.occupiedSquares) {
      if (square.piece is King && square.piece.team == team) {
        return square;
      }
    }
    return null;
  }

  /// Determines if a team is in checkmate.
  ///
  /// [team] - The team to check for checkmate
  /// [kingSquare] - The square containing the king (must be in check)
  /// [move] - The last move that has put the king in check
  ///
  /// Returns true if the team is in checkmate, false if they can escape check.
  bool _isCheckmate(Team team, OccupiedSquare kingSquare, Move move) {
    // Check if the king can move to safety
    if (_canKingEscapeCheck(kingSquare)) {
      return false;
    }

    // Check if any piece can block the check or capture the attacking piece
    if (_canBlockOrCaptureCheck(team, kingSquare, move)) {
      return false;
    }

    return true; // No escape possible - checkmate
  }

  /// Checks if the king can move to a safe square.
  ///
  /// [kingSquare] - The square containing the king
  ///
  /// Returns true if the king has at least one safe move.
  bool _canKingEscapeCheck(OccupiedSquare kingSquare) {
    final king = kingSquare.piece;
    if (king is! King) {
      throw ArgumentError('Square does not contain a king piece');
    }

    // Get all possible king moves using the movement manager
    final possibleMoves = _movementManager.possibleMoves(kingSquare);

    for (final testMove in possibleMoves) {
      // Apply the move temporarily
      state.actOn(testMove);

      // Check if the king is safe at the new position
      final newKingSquare = state[testMove.to];
      final isSafe = !threatDetector.isPieceUnderThreat(newKingSquare);

      // Undo the test move
      state.undo(testMove);

      if (isSafe) {
        return true; // Found a safe escape
      }
    }

    return false; // No safe moves available
  }

  /// Checks if any piece can block the check or capture the attacking piece.
  ///
  /// [team] - The team in check
  /// [kingSquare] - The square containing the king in check
  /// [move] - The last move that has put the king in check
  ///
  /// Returns true if check can be blocked or the attacking piece captured.
  bool _canBlockOrCaptureCheck(
    Team team,
    OccupiedSquare kingSquare,
    Move move,
  ) {
    final threateningPieces = threatDetector.getThreateningPieces(kingSquare);

    // If multiple pieces are checking the king, only king moves can save
    if (threateningPieces.length > 1) {
      return false;
    }

    final threateningPieceSquare = threateningPieces.first;
    final threateningPosition = threateningPieceSquare.position;

    // Try all pieces of the defending team
    for (final defenderSquare in state.occupiedSquares) {
      if (defenderSquare.piece.team != team || defenderSquare.piece is King) {
        continue; // Skip opponent pieces and the king (already checked)
      }

      // Check if this piece can capture the threatening piece
      if (_canPieceSolveCheck(
        defenderSquare,
        threateningPosition,
        kingSquare,
        move,
      )) {
        return true;
      }

      // Check if this piece can block the attack (for sliding pieces)
      // Find the threatening piece square to pass to the blocking method
      final threateningSquare = state[threateningPosition];
      if (threateningSquare is OccupiedSquare) {
        if (_canPieceBlockCheck(
          defenderSquare,
          threateningSquare,
          kingSquare,
        )) {
          return true;
        }
      }
    }

    return false;
  }

  /// Checks if a piece can solve check by capturing the threatening piece.
  ///
  /// [defenderSquare] - The defending piece
  /// [threateningPosition] - Position of the piece creating check
  /// [kingSquare] - The square containing the king in check
  /// [move] - The last move that has put the king in check
  ///
  /// Returns true if the defender can capture the threatening piece safely.
  bool _canPieceSolveCheck(
    OccupiedSquare defenderSquare,
    Position threateningPosition,
    OccupiedSquare kingSquare,
    Move move,
  ) {
    // Get all possible moves for the defending piece
    final possibleMoves = _movementManager.possibleMoves(
      defenderSquare,
      untracked: move,
    );

    // Check if any of these moves captures the threatening piece
    for (final move in possibleMoves) {
      if (move case CaptureMove(
        :var capturedPosition,
      ) when capturedPosition == threateningPosition) {
        // Test if this move resolves the check
        if (threatDetector.wouldMoveResolvePieceThreat(move, kingSquare)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Checks if a piece can block the check.
  ///
  /// [defenderSquare] - The defending piece
  /// [threateningPiece] - The piece creating check
  /// [kingSquare] - The square containing the king in check
  ///
  /// Returns true if the defender can block the attacking line.
  bool _canPieceBlockCheck(
    OccupiedSquare defenderSquare,
    OccupiedSquare threateningPiece,
    OccupiedSquare kingSquare,
  ) {
    // Only sliding pieces (Queen, Rook, Bishop) can be blocked
    final piece = threateningPiece.piece;
    if (piece is! SlidingPiece) {
      return false; // Knights, pawns, and kings can't be blocked
    }

    // Get the path between the threatening piece and the king
    final blockingPositions = _getBlockingPositions(
      threateningPiece.position,
      kingSquare.position,
    );

    // Get all possible moves for the defending piece
    final possibleMoves = _movementManager.possibleMoves(defenderSquare);

    // Check if any move can block the attack
    for (final move in possibleMoves) {
      if (blockingPositions.contains(move.to)) {
        // Test if this move resolves the check
        if (threatDetector.wouldMoveResolvePieceThreat(move, kingSquare)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Gets the positions between an attacking piece and the king that could
  /// block the attack.
  ///
  /// [attackerPosition] - Position of the attacking piece
  /// [kingPosition] - Position of the king
  ///
  /// Returns list of positions that would block the attack if occupied.
  List<Position> _getBlockingPositions(
    Position attackerPosition,
    Position kingPosition,
  ) {
    final blockingPositions = <Position>[];

    final fileDirection =
        (kingPosition.file.index - attackerPosition.file.index).sign;
    final rankDirection =
        (kingPosition.rank.index - attackerPosition.rank.index).sign;

    var currentFileIndex = attackerPosition.file.index + fileDirection;
    var currentRankIndex = attackerPosition.rank.index + rankDirection;

    // Walk from attacker towards king, collecting intermediate positions
    while (currentFileIndex != kingPosition.file.index ||
        currentRankIndex != kingPosition.rank.index) {
      final currentFile = File.values[currentFileIndex];
      final currentRank = Rank.values[currentRankIndex];
      blockingPositions.add(Position._(currentFile, currentRank));

      currentFileIndex += fileDirection;
      currentRankIndex += rankDirection;
    }

    return blockingPositions;
  }
}
