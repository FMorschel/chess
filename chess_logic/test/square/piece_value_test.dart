import 'package:chess_logic/src/square/piece_value.dart';
import 'package:test/test.dart';

void main() {
  group('PieceValue', () {
    test('should have correct point values', () {
      expect(PieceValue.king.points, equals(0));
      expect(PieceValue.queen.points, equals(9));
      expect(PieceValue.rook.points, equals(5));
      expect(PieceValue.bishop.points, equals(3));
      expect(PieceValue.knight.points, equals(3));
      expect(PieceValue.pawn.points, equals(1));
    });

    test('should have all piece values defined', () {
      expect(PieceValue.values.length, equals(6));
      expect(
        PieceValue.values,
        unorderedEquals([
          PieceValue.king,
          PieceValue.rook,
          PieceValue.queen,
          PieceValue.bishop,
          PieceValue.knight,
          PieceValue.pawn,
        ]),
      );
    });

    test('queen should be the most valuable piece (excluding king)', () {
      final nonKingPieces = PieceValue.values.where(
        (p) => p != PieceValue.king,
      );
      final maxValue = nonKingPieces
          .map((p) => p.points)
          .reduce((a, b) => a > b ? a : b);
      expect(PieceValue.queen.points, equals(maxValue));
    });

    test('pawn should be the least valuable piece (excluding king)', () {
      final nonKingPieces = PieceValue.values.where(
        (p) => p != PieceValue.king,
      );
      final minValue = nonKingPieces
          .map((p) => p.points)
          .reduce((a, b) => a < b ? a : b);
      expect(PieceValue.pawn.points, equals(minValue));
    });

    test('king should have zero points (invaluable)', () {
      expect(PieceValue.king.points, equals(0));
    });

    group('relative values', () {
      test('queen should be worth more than rook', () {
        expect(PieceValue.queen.points, greaterThan(PieceValue.rook.points));
      });

      test('rook should be worth more than minor pieces', () {
        expect(PieceValue.rook.points, greaterThan(PieceValue.bishop.points));
        expect(PieceValue.rook.points, greaterThan(PieceValue.knight.points));
      });

      test('minor pieces should be worth more than pawn', () {
        expect(PieceValue.bishop.points, greaterThan(PieceValue.pawn.points));
        expect(PieceValue.knight.points, greaterThan(PieceValue.pawn.points));
      });

      test('bishop and knight should have equal value', () {
        expect(PieceValue.bishop.points, equals(PieceValue.knight.points));
      });
    });

    group('point calculations', () {
      test('should allow summing piece values', () {
        final totalValue = PieceValue.queen.points + PieceValue.rook.points;
        expect(totalValue, equals(14));
      });

      test('should handle material calculations', () {
        final minorPiecePair =
            PieceValue.bishop.points + PieceValue.knight.points;
        expect(minorPiecePair, equals(6));
        expect(minorPiecePair, greaterThan(PieceValue.rook.points));
      });
    });
  });
}
