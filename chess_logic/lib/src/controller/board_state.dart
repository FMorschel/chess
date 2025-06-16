import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/position/rank.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:chess_logic/src/utility/board_printer.dart';
import 'package:chess_logic/src/utility/extensions.dart';

class BoardState {
  BoardState({List<Move>? history}) : squares = _emptySquares {
    reset();
    if (history != null) {
      for (var move in history) {
        actOn(move);
      }
    }
  }

  BoardState.empty() : squares = _emptySquares;

  BoardState.custom(Map<Position, Piece> customPieces)
    : squares = _emptySquares {
    clear();
    for (var entry in customPieces.entries) {
      final newSquare = this[entry.key].replacePiece(entry.value);
      squares.replace(newSquare);
    }
  }

  /// Private constructor for copying an existing board state
  BoardState._copy(BoardState other) : squares = _emptySquares {
    // Copy all squares from the other board state
    for (var square in other.squares) {
      final newSquare = square.piece != null
          ? this[square.position].replacePiece(square.piece!)
          : this[square.position].removePiece();
      squares.replace(newSquare);
    }
  }

  static List<Square> get _emptySquares => [
    for (var file in File.values)
      for (var rank in Rank.values) EmptySquare(Position(file, rank)),
  ];

  static final BoardPrinter _printer = BoardPrinter.instance;

  final List<Square> squares;

  List<OccupiedSquare> get occupiedSquares =>
      squares.whereType<OccupiedSquare>().toList();

  /// Creates a new BoardState with the given move applied, without modifying the current state.
  /// This allows you to preview what the board would look like after a move.
  BoardState move(Move move) {
    final newState = BoardState._copy(this);
    newState.actOn(move);
    return newState;
  }

  void actOn(Move move) {
    if (this[move.from].piece != move.moving) {
      throw ArgumentError(
        'The piece at ${move.from} does not match the moving piece: '
        '${this[move.from].piece?.symbol.lexeme} != ${move.moving.symbol.lexeme}',
      );
    }
    if (this[move.to].isOccupied && move is! CaptureMove) {
      // The destination square is occupied and it's not a capture
      throw ArgumentError('Cannot move to an occupied square: ${move.to}');
    }
    Square newSquare = this[move.from].removePiece();
    squares.replace(newSquare);

    // Handle promotion moves - create the promoted piece instead of moving the pawn
    if (move is PromotionMove) {
      final promotedPiece = Piece.fromSymbol(move.promotion, move.moving.team);
      newSquare = this[move.to].replacePiece(promotedPiece);
    } else {
      newSquare = this[move.to].replacePiece(move.moving);
    }
    squares.replace(newSquare);

    if (move is EnPassantMove) {
      // Remove the captured pawn for en passant
      newSquare = this[move.capturedPosition].removePiece();
      squares.replace(newSquare);
    }

    if (move is CastlingMove) {
      // Handle castling move
      final rookPosition = move.rook.from;
      final rookSquare = this[rookPosition];
      final rookPiece = rookSquare.piece;
      if (rookPiece == null || rookPiece.symbol != PieceSymbol.rook) {
        throw ArgumentError('No rook at $rookPosition for castling.');
      }
      // Move the rook to the new position
      final newRookSquare = this[move.rook.to].replacePiece(rookPiece);
      squares.replace(newRookSquare);
      // Remove the rook from its original position
      final clearedRookSquare = rookSquare.removePiece();
      squares.replace(clearedRookSquare);
    }
  }

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
      squares.replace(move.capturedPosition < move.captured);
    } else if (move is CastlingMove) {
      // For castling, check if the rook is at the destination
      final rookSquare = this[move.rook.to];
      if (rookSquare.piece == null ||
          rookSquare.piece!.symbol != PieceSymbol.rook) {
        throw ArgumentError('No rook at ${move.rook.to} for castling.');
      }
    }
    if (this[move.to].piece != move.moving) {
      throw ArgumentError(
        'The piece at ${move.to} does not match the moving piece: '
        '${this[move.to].piece?.symbol.lexeme} != ${move.moving.symbol.lexeme}',
      );
    }

    Square newSquare = this[move.to].removePiece();
    squares.replace(newSquare);
    newSquare = this[move.from].replacePiece(move.moving);
    squares.replace(newSquare);
    if (move is CaptureMove) {
      newSquare = this[move.capturedPosition].replacePiece(move.captured);
      squares.replace(newSquare);
    }
  }

  Square operator [](Position position) =>
      squares.firstWhere((square) => square.position == position);

  void reset() {
    clear();
    for (var file in File.values) {
      for (var rank in Rank.values) {
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
        squares.replace(newSquare);
      }
    }
  }

  void clear() {
    for (var square in squares) {
      final newSquare = square.removePiece();
      squares.replace(newSquare);
    }
  }

  @override
  String toString({bool complete = false}) => complete
      ? _printer.getBoardString(this)
      : _printer.getCompactBoardString(this);
}

extension on File {
  PieceSymbol get defaultSymbol {
    switch (this) {
      case File.a:
      case File.h:
        return PieceSymbol.rook;
      case File.b:
      case File.g:
        return PieceSymbol.knight;
      case File.c:
      case File.f:
        return PieceSymbol.bishop;
      case File.d:
        return PieceSymbol.queen;
      case File.e:
        return PieceSymbol.king;
    }
  }
}
