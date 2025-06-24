import '../move/move.dart';
import '../position/direction.dart';
import '../position/file.dart';
import '../position/position.dart';
import '../square/piece.dart';
import '../team/team.dart';
import 'board_state.dart';

/// Handles special chess rules and game termination conditions.
///
/// This class is responsible for:
/// - Draw conditions (50-move rule, insufficient material, stalemate)
/// - Game termination detection (checkmate, resignation, timeout)
/// - Special move rules (en passant, castling, pawn promotion)
class GameRuleEngine {
  const GameRuleEngine();

  /// Gets the opponent team for a given team.
  Team _getOpponentTeam(Team team) {
    return team == Team.white ? Team.black : Team.white;
  }

  /// Checks if the game should be drawn based on the 50-move rule.
  ///
  /// According to FIDE rules, the game is drawn if 50 moves have been made
  /// by each player without a pawn move or capture.
  ///
  /// [halfmoveClock] - Number of half-moves since last pawn move or capture
  /// [teams] - List of teams in the game
  ///
  /// Returns true if the 50-move rule applies
  bool isFiftyMoveRule(int halfmoveClock, List<Team> teams) {
    return halfmoveClock >= (teams.length * 50);
  }

  /// Checks if the current board position has insufficient material for
  /// checkmate.
  ///
  /// According to FIDE rules, the game is drawn if neither side has sufficient
  /// material to deliver checkmate. This includes:
  ///
  /// 1. King vs King
  /// 2. King vs King + Bishop/Knight (lone minor piece)
  /// 3. King + Bishop vs King + Bishop (same color squares)
  ///
  /// [boardState] - Current board state
  ///
  /// Returns true if there is insufficient material to continue
  bool hasInsufficientMaterial(BoardState boardState) {
    final pieces = boardState.occupiedSquares
        .map((square) => square.piece)
        .toList();

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
        final whiteBishopSquare = boardState.occupiedSquares.firstWhere(
          (square) => square.piece == whiteBishops.first,
        );
        final blackBishopSquare = boardState.occupiedSquares.firstWhere(
          (square) => square.piece == blackBishops.first,
        );

        return whiteBishopSquare.lightSquare == blackBishopSquare.lightSquare;
      }
    }

    return false;
  }

  /// Checks if the current position is stalemate.
  ///
  /// Stalemate occurs when the current player has no legal moves
  /// but is not in check.
  ///
  /// [possibleMoves] - List of all possible moves for the current team
  /// [isInCheck] - Whether the current team's king is in check
  ///
  /// Returns true if the position is stalemate
  bool isStalemate(List<Move> possibleMoves, {required bool isInCheck}) {
    return possibleMoves.isEmpty && !isInCheck;
  }

  /// Checks if the current position is checkmate.
  ///
  /// Checkmate occurs when the current player has no legal moves
  /// and their king is in check.
  ///
  /// [possibleMoves] - List of all possible moves for the current team
  /// [isInCheck] - Whether the current team's king is in check
  ///
  /// Returns true if the position is checkmate
  bool isCheckmate(List<Move> possibleMoves, {required bool isInCheck}) {
    return possibleMoves.isEmpty && isInCheck;
  }

  /// Validates if en passant capture is legal.
  ///
  /// En passant is only legal if:
  /// 1. The last move was a double pawn move
  /// 2. The double pawn move was made by the opponent
  /// 3. The capturing pawn is on the correct rank (5th for white, 4th for
  /// black)
  /// 4. The capturing pawn is adjacent to the double-moved pawn
  ///
  /// [capturingPawn] - The pawn attempting to capture en passant
  /// [capturePosition] - The position where the en passant capture would occur
  /// [lastMove] - The last move made in the game
  /// [boardState] - Current board state
  ///
  /// Returns true if the en passant capture is legal
  bool isEnPassantLegal(
    Pawn capturingPawn,
    Position capturePosition,
    Move? lastMove,
    BoardState boardState,
  ) {
    if (lastMove == null || lastMove is! PawnMove) {
      return false;
    }

    final lastPawnMove = lastMove;

    // Check if last move was a double pawn move
    final rankDifference =
        (lastPawnMove.to.rank.index - lastPawnMove.from.rank.index).abs();
    if (rankDifference != 2) {
      return false;
    }

    // Check if the last moved pawn is adjacent to the capturing pawn
    final capturingPawnPosition = boardState.occupiedSquares
        .firstWhere((square) => square.piece == capturingPawn)
        .position;
    // The en passant target should be behind the double-moved pawn
    final expectedCaptureFile = lastPawnMove.to.file;
    final expectedCaptureRank = capturingPawn.team == Team.white
        ? lastPawnMove.to.rank.next(Direction.up)
        : lastPawnMove.to.rank.next(Direction.down);

    if (expectedCaptureRank == null) {
      return false;
    }

    final expectedCapturePosition = Position(
      expectedCaptureFile,
      expectedCaptureRank,
    );

    // Check if capture position matches expected position
    if (capturePosition != expectedCapturePosition) {
      return false;
    }

    // Check if capturing pawn is on the correct rank and adjacent file
    final correctRank = capturingPawn.team == Team.white
        ? capturingPawnPosition.rank.index ==
              4 // 5th rank (0-indexed)
        : capturingPawnPosition.rank.index == 3; // 4th rank (0-indexed)

    final adjacentFile =
        (capturingPawnPosition.file.index - lastPawnMove.to.file.index).abs() ==
        1;

    return correctRank &&
        adjacentFile &&
        lastPawnMove.moving.team != capturingPawn.team;
  }

  /// Validates if castling is legal.
  ///
  /// Castling is legal if:
  /// 1. King and rook are in their initial positions
  /// 2. King and rook haven't moved
  /// 3. No pieces between king and rook
  /// 4. King is not in check
  /// 5. King doesn't pass through or land on a square attacked by opponent
  /// 6. King and rook are on the same rank
  ///
  /// [king] - The king attempting to castle
  /// [rook] - The rook involved in castling
  /// [kingFrom] - King's current position
  /// [kingTo] - King's target position
  /// [rookFrom] - Rook's current position
  /// [boardState] - Current board state
  /// [moveHistory] - List of all moves made in the game
  /// [isSquareAttacked] - Function to check if a square is under attack
  ///
  /// Returns true if castling is legal
  bool isCastlingLegal(
    King king,
    Rook rook,
    Position kingFrom,
    Position kingTo,
    Position rookFrom,
    BoardState boardState,
    List<Move> moveHistory,
    bool Function(Position position, Team byTeam) isSquareAttacked,
  ) {
    // Check if king and rook are the same team
    if (king.team != rook.team) {
      return false;
    }

    // Check if king and rook are on the same rank
    if (kingFrom.rank != rookFrom.rank) {
      return false;
    }

    // Check if king and rook are in their initial positions
    final homeRank = king.team.homeRank;
    const kingHomeFile = File.e;
    final isKingInInitialPosition =
        kingFrom == Position(kingHomeFile, homeRank);
    final isRookInInitialPosition = king.rookPositions
        .map((r) => r.$1)
        .contains(rookFrom);

    if (!isKingInInitialPosition || !isRookInInitialPosition) {
      return false;
    }

    // Check if king or rook have moved
    final kingHasMoved = moveHistory.any(
      (move) =>
          move.moving == king ||
          (move.from == kingFrom &&
              move.moving is King &&
              move.moving.team == king.team),
    );
    final rookHasMoved = moveHistory.any(
      (move) =>
          move.moving == rook ||
          (move.from == rookFrom &&
              move.moving is Rook &&
              move.moving.team == rook.team),
    );

    if (kingHasMoved || rookHasMoved) {
      return false;
    }
    // Check if king is currently in check
    if (isSquareAttacked(kingFrom, _getOpponentTeam(king.team))) {
      return false;
    }

    // Check if there are pieces between king and rook
    final minFile = kingFrom.file.index < rookFrom.file.index
        ? kingFrom.file
        : rookFrom.file;
    final maxFile = kingFrom.file.index > rookFrom.file.index
        ? kingFrom.file
        : rookFrom.file;

    for (int i = minFile.index + 1; i < maxFile.index; i++) {
      final intermediatePosition = Position(File.values[i], kingFrom.rank);
      if (boardState[intermediatePosition].piece != null) {
        return false;
      }
    }

    // Check if king passes through or lands on an attacked square
    final direction = kingTo.file.index > kingFrom.file.index ? 1 : -1;
    var currentFile = kingFrom.file;

    while (currentFile != kingTo.file) {
      currentFile = File.values[currentFile.index + direction];
      final checkPosition = Position(currentFile, kingFrom.rank);
      if (isSquareAttacked(checkPosition, _getOpponentTeam(king.team))) {
        return false;
      }
    }

    return true;
  }

  /// Validates if pawn promotion is required and legal.
  ///
  /// Pawn promotion is required when a pawn reaches the opposite end of the
  /// board (8th rank for white, 1st rank for black).
  ///
  /// [pawn] - The pawn to check for promotion
  /// [targetPosition] - The position the pawn is moving to
  ///
  /// Returns true if pawn promotion is required
  bool isPawnPromotionRequired(Pawn pawn, Position targetPosition) {
    return (pawn.team == Team.white && targetPosition.rank.index == 7) ||
        (pawn.team == Team.black && targetPosition.rank.index == 0);
  }

  /// Validates if the promoted piece is legal.
  ///
  /// According to FIDE rules, a pawn can only be promoted to:
  /// Queen, Rook, Bishop, or Knight of the same team.
  ///
  /// [promotedPiece] - The piece the pawn is being promoted to
  /// [pawnTeam] - The team of the promoting pawn
  ///
  /// Returns true if the promotion is legal
  bool isPromotionPieceLegal(Piece promotedPiece, Team pawnTeam) {
    if (promotedPiece.team != pawnTeam) {
      return false;
    }

    return promotedPiece is Queen ||
        promotedPiece is Rook ||
        promotedPiece is Bishop ||
        promotedPiece is Knight;
  }
}
