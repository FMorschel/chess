import 'package:meta/meta.dart';

import '../move/move.dart';
import '../position/file.dart';
import '../position/position.dart';
import '../position/rank.dart';
import '../square/piece.dart';
import '../square/piece_symbol.dart';
import '../square/square.dart';
import '../team/team.dart';
import '../utility/board_printer.dart';
import '../utility/extensions.dart';

/// Represents the current state of a chess board with all pieces and squares.
///
/// Manages the placement and movement of pieces on the chess board. Contains
/// 64 squares representing the standard 8x8 chess board layout. Provides
/// methods for moving pieces, undoing moves, and querying board state.
class BoardState {
  /// Creates a new board state with pieces in their starting positions.
  BoardState() : _squares = _emptySquares {
    reset();
  }

  /// Creates a new board state with all squares empty.
  BoardState.empty() : _squares = _emptySquares;

  /// Creates a new board state with custom piece placement.
  ///
  /// The [customPieces] map specifies which pieces should be placed at
  /// which positions. All other squares will be empty.
  BoardState.custom(Map<Position, Piece> customPieces)
    : _squares = _emptySquares {
    clear();
    for (final entry in customPieces.entries) {
      final newSquare = this[entry.key].replacePiece(entry.value);
      _squares.replace(newSquare);
    }
  }

  /// Static printer instance for board visualization.
  static const BoardPrinter _printer = BoardPrinter.instance;

  /// Creates empty squares for all positions on the board.
  static List<Square> get _emptySquares => [
    for (final file in File.values)
      for (final rank in Rank.values) EmptySquare(Position(file, rank)),
  ];

  /// List of all 64 squares on the chess board.
  final List<Square> _squares;

  /// List of all 64 squares on the chess board.
  List<Square> get squares => List.unmodifiable(_squares);

  /// Immutable list of currently occupied squares.
  List<OccupiedSquare> get occupiedSquares =>
      List.unmodifiable(_squares.whereType<OccupiedSquare>());

  @visibleForTesting
  void replace(Square square) => _squares.replace(square);

  /// Executes a move on the board, updating piece positions.
  ///
  /// Validates that the moving piece is at the expected position and handles
  /// special moves like promotion, en passant, and castling. Throws
  /// [ArgumentError] if the move is invalid.
  void move(Move move) {
    if (this[move.from].piece != move.moving) {
      throw ArgumentError(
        'The piece at ${move.from} does not match the moving piece: '
        '${this[move.from].piece?.symbol.lexeme} != '
        '${move.moving.symbol.lexeme}',
      );
    }
    if (this[move.to].isOccupied && move is! CaptureMove) {
      // The destination square is occupied and it's not a capture
      throw ArgumentError('Cannot move to an occupied square: ${move.to}');
    }
    Square newSquare = this[move.from].removePiece();
    _squares.replace(newSquare);

    // Handle promotion moves - create the promoted piece instead of moving the
    // pawn
    if (move is PromotionMove) {
      final promotedPiece = Piece.fromSymbol(move.promotion, move.moving.team);
      newSquare = this[move.to].replacePiece(promotedPiece);
    } else {
      newSquare = this[move.to].replacePiece(move.moving);
    }
    _squares.replace(newSquare);

    if (move is EnPassantMove) {
      // Remove the captured pawn for en passant
      newSquare = this[move.capturedPosition].removePiece();
      _squares.replace(newSquare);
    }

    if (move is CastlingMove) {
      // Handle castling move
      this.move(move.rook);
    }
  }

  /// Undoes a move on the board, restoring the previous state.
  ///
  /// Validates that the board state matches expectations for the move being
  /// undone. Handles special moves like promotion, en passant, and castling.
  /// Throws [ArgumentError] if the undo operation is invalid.
  void undo(Move move) {
    // For promotion moves, check if the promoted piece is at the destination
    if (move is PromotionMove) {
      final currentPiece = this[move.to].piece;
      if (currentPiece == null || currentPiece.symbol != move.promotion) {
        throw ArgumentError(
          'The piece at ${move.to} does not match the promoted piece: '
          '${currentPiece?.symbol.lexeme} != ${move.promotion.lexeme}',
        );
      }
    } else if (move is EnPassantMove) {
      // For en passant, check if any piece is at the captured position
      final capturedSquare = this[move.capturedPosition];
      if (capturedSquare.piece != null) {
        throw ArgumentError(
          'The captured square ${move.capturedPosition} '
          'should be empty for undoing en passant.',
        );
      }
      _squares.replace(move.capturedPosition < move.captured);
    } else if (move is CastlingMove) {
      // For castling, check if the rook is at the destination
      final rookSquare = this[move.rook.to];
      if (rookSquare.piece == null ||
          rookSquare.piece!.symbol != PieceSymbol.rook) {
        throw ArgumentError('No rook at ${move.rook.to} for castling.');
      }
      undo(move.rook);
    }
    if (this[move.to].piece != move.moving) {
      throw ArgumentError(
        'The piece at ${move.to} does not match the moving piece: '
        '${this[move.to].piece?.symbol.lexeme} != ${move.moving.symbol.lexeme}',
      );
    }

    Square newSquare = this[move.to].removePiece();
    _squares.replace(newSquare);
    newSquare = this[move.from].replacePiece(move.moving);
    _squares.replace(newSquare);
    if (move is CaptureMove) {
      newSquare = this[move.capturedPosition].replacePiece(move.captured);
      _squares.replace(newSquare);
    }
  }

  /// Gets the square at the specified position.
  Square operator [](Position position) =>
      _squares.firstWhere((square) => square.position == position);

  /// Map of all pieces and their positions on the board.
  Map<Position, Piece> get export => Map.unmodifiable({
    for (final square in occupiedSquares) square.position: square.piece,
  });

  @override
  String toString({bool complete = false}) => complete
      ? _printer.getBoardString(this)
      : _printer.getCompactBoardString(this);

  /// Resets the board to the standard starting position.
  @visibleForTesting
  void reset() {
    clear();
    for (final file in File.values) {
      for (final rank in Rank.values) {
        final position = Position(file, rank);
        final (team, symbol) = switch (rank) {
          Rank.one => (Team.white, file.defaultSymbol),
          Rank.two => (Team.white, PieceSymbol.pawn),
          Rank.seven => (Team.black, PieceSymbol.pawn),
          Rank.eight => (Team.black, file.defaultSymbol),
          _ => (null, null),
        };
        if (team == null || symbol == null) continue;
        final piece = Piece.fromSymbol(symbol, team);
        final newSquare = this[position].replacePiece(piece);
        _squares.replace(newSquare);
      }
    }
  }

  /// Clears all pieces from the board, leaving all squares empty.
  @visibleForTesting
  void clear() {
    for (final square in _squares) {
      final newSquare = square.removePiece();
      _squares.replace(newSquare);
    }
  }
}
