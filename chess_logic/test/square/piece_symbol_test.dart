import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:test/test.dart';

void main() {
  group('PieceSymbol', () {
    test('should have correct lexemes', () {
      expect(PieceSymbol.king.lexeme, equals('K'));
      expect(PieceSymbol.queen.lexeme, equals('Q'));
      expect(PieceSymbol.rook.lexeme, equals('R'));
      expect(PieceSymbol.bishop.lexeme, equals('B'));
      expect(PieceSymbol.knight.lexeme, equals('N'));
      expect(PieceSymbol.pawn.lexeme, equals('P'));
    });

    test('should parse from valid lexeme', () {
      expect(PieceSymbol.fromLexeme('K'), PieceSymbol.king);
      expect(PieceSymbol.fromLexeme('Q'), PieceSymbol.queen);
      expect(PieceSymbol.fromLexeme('R'), PieceSymbol.rook);
      expect(PieceSymbol.fromLexeme('B'), PieceSymbol.bishop);
      expect(PieceSymbol.fromLexeme('N'), PieceSymbol.knight);
      expect(PieceSymbol.fromLexeme('P'), PieceSymbol.pawn);
    });

    test('should throw for invalid lexeme', () {
      expect(() => PieceSymbol.fromLexeme('X'), throwsArgumentError);
      expect(() => PieceSymbol.fromLexeme('1'), throwsArgumentError);
      expect(() => PieceSymbol.fromLexeme(''), throwsArgumentError);
      expect(() => PieceSymbol.fromLexeme('k'), throwsArgumentError);
    });

    group('canPromoteTo', () {
      test('should return false for king and pawn', () {
        expect(PieceSymbol.king.canPromoteTo, equals(false));
        expect(PieceSymbol.pawn.canPromoteTo, equals(false));
      });

      test('should return true for other pieces', () {
        expect(PieceSymbol.queen.canPromoteTo, equals(true));
        expect(PieceSymbol.rook.canPromoteTo, equals(true));
        expect(PieceSymbol.bishop.canPromoteTo, equals(true));
        expect(PieceSymbol.knight.canPromoteTo, equals(true));
      });
    });

    group('promotionSymbols', () {
      test('should return only pieces that can be promoted to', () {
        final promotionSymbols = PieceSymbol.promotionSymbols;

        expect(promotionSymbols, contains(PieceSymbol.queen));
        expect(promotionSymbols, contains(PieceSymbol.rook));
        expect(promotionSymbols, contains(PieceSymbol.bishop));
        expect(promotionSymbols, contains(PieceSymbol.knight));

        expect(promotionSymbols, isNot(contains(PieceSymbol.king)));
        expect(promotionSymbols, isNot(contains(PieceSymbol.pawn)));
      });

      test('should return exactly 4 promotion symbols', () {
        expect(PieceSymbol.promotionSymbols.length, equals(4));
      });
    });
  });
}
