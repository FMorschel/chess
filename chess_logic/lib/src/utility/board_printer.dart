import '../controller/board_state.dart';
import '../position/file.dart';
import '../position/position.dart';
import '../position/rank.dart';
import '../square/piece.dart';
import '../square/piece_symbol.dart';
import '../team/team.dart';

/// A utility class for printing a visual representation of the chess board
/// for developers to better understand the current board state.
class BoardPrinter {
  const BoardPrinter._();

  static const instance = BoardPrinter._();

  /// Board state as a formatted string without printing it
  String getBoardString(BoardState boardState) {
    return _generateBoardString(boardState);
  }

  /// Compact board representation as a string
  String getCompactBoardString(BoardState boardState) {
    return _generateCompactBoardString(boardState);
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

  /// Piece display symbol (White pieces: uppercase, Black pieces: lowercase,
  /// Empty squares: dot)
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
}
