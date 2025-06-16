import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/position/rank.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/team/team.dart';

/// A utility class for printing a visual representation of the chess board
/// for developers to better understand the current board state.
class BoardPrinter {
  const BoardPrinter._();

  static const instance = BoardPrinter._();

  /// Prints the board state in a 2D representation using letters.
  ///
  /// White pieces are represented by uppercase letters (K, Q, R, B, N, P)
  /// Black pieces are represented by lowercase letters (k, q, r, b, n, p)
  /// Empty squares are represented by dots (.)
  ///
  /// The board is printed from rank 8 (top) to rank 1 (bottom),
  /// with files a-h from left to right, matching standard chess notation.
  void printBoard(BoardState boardState) {
    print(_generateBoardString(boardState));
  }

  /// Returns the board state as a formatted string without printing it.
  String getBoardString(BoardState boardState) {
    return _generateBoardString(boardState);
  }

  String _generateBoardString(BoardState boardState) {
    final buffer = StringBuffer();

    // Add column headers (files a-h)
    buffer.writeln('   a b c d e f g h');
    buffer.writeln('  ┌─────────────────┐');

    // Print board from rank 8 (top) to rank 1 (bottom)
    for (final rank in Rank.values.reversed) {
      buffer.write('${rank.value} │ ');

      for (final file in File.values) {
        final position = Position(file, rank);
        final square = boardState[position];
        final piece = square.piece;

        final symbol = _getPieceSymbol(piece);
        buffer.write('$symbol ');
      }

      buffer.writeln('│ ${rank.value}');
    }

    buffer.writeln('  └─────────────────┘');
    buffer.writeln('   a b c d e f g h');

    return buffer.toString();
  }

  /// Converts a piece to its display symbol.
  /// White pieces: uppercase letters
  /// Black pieces: lowercase letters
  /// Empty squares: dot (.)
  String _getPieceSymbol(Piece? piece) {
    if (piece == null) return '.';

    final symbol = switch (piece.symbol) {
      PieceSymbol.king => 'K',
      PieceSymbol.queen => 'Q',
      PieceSymbol.rook => 'R',
      PieceSymbol.bishop => 'B',
      PieceSymbol.knight => 'N',
      PieceSymbol.pawn => 'P',
    };

    return piece.team == Team.white ? symbol : symbol.toLowerCase();
  }

  /// Prints a compact version of the board without borders and labels.
  /// Useful for quick debugging or when space is limited.
  void printCompactBoard(BoardState boardState) {
    print(_generateCompactBoardString(boardState));
  }

  /// Returns a compact board representation as a string.
  String getCompactBoardString(BoardState boardState) {
    return _generateCompactBoardString(boardState);
  }

  String _generateCompactBoardString(BoardState boardState) {
    final buffer = StringBuffer();
    buffer.writeln();

    // Print board from rank 8 (top) to rank 1 (bottom)
    for (final rank in Rank.values.reversed) {
      for (final file in File.values) {
        final position = Position(file, rank);
        final square = boardState[position];
        final piece = square.piece;

        final symbol = _getPieceSymbol(piece);
        buffer.write(symbol);
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}
