import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:chess_logic/src/utility/board_printer.dart';
import 'package:test/test.dart';

void main() {
  group('BoardPrinter', () {
    late BoardPrinter boardPrinter;

    setUpAll(() {
      boardPrinter = BoardPrinter.instance;
    });
    group('getBoardString', () {
      test('should display starting position correctly', () {
        final boardState = BoardState();
        final result = boardPrinter.getBoardString(boardState);

        // Check that the result contains the expected headers and borders
        expect(result, contains('   a b c d e f g h'));
        expect(result, contains('  ┌─────────────────┐'));
        expect(result, contains('  └─────────────────┘'));

        // Check that rank numbers appear
        for (int i = 1; i <= 8; i++) {
          expect(result, contains('$i │'));
          expect(result, contains('│ $i'));
        }

        // Check starting position pieces
        // Black pieces on rank 8
        expect(result, contains('8 │ r n b q k b n r │ 8'));
        // Black pawns on rank 7
        expect(result, contains('7 │ p p p p p p p p │ 7'));
        // Empty ranks 6-3
        expect(result, contains('6 │ . . . . . . . . │ 6'));
        expect(result, contains('5 │ . . . . . . . . │ 5'));
        expect(result, contains('4 │ . . . . . . . . │ 4'));
        expect(result, contains('3 │ . . . . . . . . │ 3'));
        // White pawns on rank 2
        expect(result, contains('2 │ P P P P P P P P │ 2'));
        // White pieces on rank 1
        expect(result, contains('1 │ R N B Q K B N R │ 1'));
      });

      test('should display empty board correctly', () {
        final boardState = BoardState.empty();
        final result = boardPrinter.getBoardString(boardState);

        // Check that all squares are empty
        for (int rank = 1; rank <= 8; rank++) {
          expect(result, contains('$rank │ . . . . . . . . │ $rank'));
        }
      });
      test('should display custom board position correctly', () {
        final boardState = BoardState.custom({
          Position.e1: Piece.fromSymbol(PieceSymbol.king, Team.white),
          Position.e8: Piece.fromSymbol(PieceSymbol.king, Team.black),
          Position.d1: Piece.fromSymbol(PieceSymbol.queen, Team.white),
          Position.d8: Piece.fromSymbol(PieceSymbol.queen, Team.black),
        });
        final result = boardPrinter.getBoardString(boardState);

        // Check specific pieces
        expect(result, contains('8 │ . . . q k . . . │ 8'));
        expect(result, contains('1 │ . . . Q K . . . │ 1'));

        // Check that other ranks are empty
        for (int rank = 2; rank <= 7; rank++) {
          expect(result, contains('$rank │ . . . . . . . . │ $rank'));
        }
      });
    });

    group('getCompactBoardString', () {
      test('should display starting position without borders', () {
        final boardState = BoardState();
        final result = boardPrinter.getCompactBoardString(boardState);

        final expectedLines = [
          '',
          'rnbqkbnr',
          'pppppppp',
          '........',
          '........',
          '........',
          '........',
          'PPPPPPPP',
          'RNBQKBNR',
          '',
        ];

        expect(result, equals(expectedLines.join('\n')));
      });

      test('should display empty board without borders', () {
        final boardState = BoardState.empty();
        final result = boardPrinter.getCompactBoardString(boardState);

        final expectedLines = [
          '',
          '........',
          '........',
          '........',
          '........',
          '........',
          '........',
          '........',
          '........',
          '',
        ];

        expect(result, equals(expectedLines.join('\n')));
      });
      test('should display custom position correctly', () {
        final boardState = BoardState.custom({
          Position.a1: Piece.fromSymbol(PieceSymbol.rook, Team.white),
          Position.h8: Piece.fromSymbol(PieceSymbol.rook, Team.black),
          Position.e4: Piece.fromSymbol(PieceSymbol.king, Team.white),
          Position.d5: Piece.fromSymbol(PieceSymbol.queen, Team.black),
        });
        final result = boardPrinter.getCompactBoardString(boardState);

        final lines = result.split('\n');
        expect(lines[0], equals(''));
        expect(lines[1], equals('.......r')); // rank 8
        expect(lines[2], equals('........')); // rank 7
        expect(lines[3], equals('........')); // rank 6
        expect(lines[4], equals('...q....')); // rank 5
        expect(lines[5], equals('....K...')); // rank 4
        expect(lines[6], equals('........')); // rank 3
        expect(lines[7], equals('........')); // rank 2
        expect(lines[8], equals('R.......')); // rank 1
      });
    });

    group('piece symbol mapping', () {
      test('should map white pieces to uppercase letters', () {
        final whitePieces = <PieceSymbol, String>{
          PieceSymbol.king: 'K',
          PieceSymbol.queen: 'Q',
          PieceSymbol.rook: 'R',
          PieceSymbol.bishop: 'B',
          PieceSymbol.knight: 'N',
          PieceSymbol.pawn: 'P',
        };
        for (final entry in whitePieces.entries) {
          final boardState = BoardState.custom({
            Position.a1: Piece.fromSymbol(entry.key, Team.white),
          });
          final result = boardPrinter.getCompactBoardString(boardState);

          expect(result, contains(entry.value));
        }
      });

      test('should map black pieces to lowercase letters', () {
        final blackPieces = <PieceSymbol, String>{
          PieceSymbol.king: 'k',
          PieceSymbol.queen: 'q',
          PieceSymbol.rook: 'r',
          PieceSymbol.bishop: 'b',
          PieceSymbol.knight: 'n',
          PieceSymbol.pawn: 'p',
        };
        for (final entry in blackPieces.entries) {
          final boardState = BoardState.custom({
            Position.a8: Piece.fromSymbol(entry.key, Team.black),
          });
          final result = boardPrinter.getCompactBoardString(boardState);

          expect(result, contains(entry.value));
        }
      });

      test('should use dots for empty squares', () {
        final boardState = BoardState.empty();
        final result = boardPrinter.getCompactBoardString(boardState);

        // All squares should be dots
        final lines = result.split('\n').where((line) => line.isNotEmpty);
        for (final line in lines) {
          expect(line, equals('........'));
        }
      });
    });

    group('board layout', () {
      test('should display ranks from 8 to 1 (top to bottom)', () {
        final boardState = BoardState();
        final result = boardPrinter.getBoardString(boardState);

        // Find the positions of rank indicators in the string
        final lines = result.split('\n');
        final rankLines = lines.where((line) => line.contains('│')).toList();

        // Should have 8 rank lines
        expect(rankLines.length, equals(8));

        // Check that ranks appear in descending order
        for (int i = 0; i < 8; i++) {
          final expectedRank = 8 - i;
          expect(rankLines[i], startsWith('$expectedRank │'));
          expect(rankLines[i], endsWith('│ $expectedRank'));
        }
      });

      test('should display files from a to h (left to right)', () {
        final boardState = BoardState();
        final result = boardPrinter.getBoardString(boardState);

        // Check that file headers appear correctly
        expect(
          result,
          contains('   a b c d e f g h'),
        ); // For compact board, check that positions correspond to correct files
        final customBoard = BoardState.custom({
          Position.a1: Piece.fromSymbol(PieceSymbol.rook, Team.white),
          Position.h1: Piece.fromSymbol(PieceSymbol.rook, Team.black),
        });
        final compactResult = boardPrinter.getCompactBoardString(customBoard);

        final lines = compactResult.split('\n');
        final rank1Line = lines[8]; // rank 1 is the last line
        expect(rank1Line[0], equals('R')); // file a
        expect(rank1Line[7], equals('r')); // file h
      });
    });
  });
}
