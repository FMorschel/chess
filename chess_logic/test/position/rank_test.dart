import 'package:chess_logic/src/controller/direction.dart';
import 'package:chess_logic/src/position/rank.dart';
import 'package:test/test.dart';

void main() {
  group('Rank', () {
    test('should parse from valid digit', () {
      expect(Rank.fromValue(1), Rank.one);
      expect(Rank.fromValue(8), Rank.eight);
    });

    test('should throw for invalid digit', () {
      expect(() => Rank.fromValue(9), throwsArgumentError);
      expect(() => Rank.fromValue(0), throwsArgumentError);
    });

    test('should return correct value', () {
      expect(Rank.one.value, equals(1));
      expect(Rank.eight.value, equals(8));
    });

    group('distanceTo', () {
      test('should return 0 for same file', () {
        expect(Rank.one.distanceTo(Rank.one), equals(0));
        expect(Rank.eight.distanceTo(Rank.eight), equals(0));
      });

      test('should return positive distance for rightward files', () {
        expect(Rank.one.distanceTo(Rank.two), equals(1));
        expect(Rank.three.distanceTo(Rank.five), equals(2));
        expect(Rank.six.distanceTo(Rank.eight), equals(2));
      });

      test('should return positive distance for leftward files', () {
        expect(Rank.two.distanceTo(Rank.one), equals(1));
        expect(Rank.five.distanceTo(Rank.three), equals(2));
        expect(Rank.eight.distanceTo(Rank.six), equals(2));
      });

      test('should handle non-adjacent files', () {
        expect(Rank.one.distanceTo(Rank.four), equals(3));
        expect(Rank.seven.distanceTo(Rank.three), equals(4));
      });
    });
  });

  group('next', () {
    test('should return null for horizontal directions', () {
      expect(Rank.one.next(Direction.left), isNull);
      expect(Rank.four.next(Direction.right), isNull);
    });

    test(
      'should return correct rank for vertical, diagonal and L-shape directions',
      () {
        // Upward (towards Rank.eight)
        expect(Rank.one.next(Direction.up), Rank.two);
        expect(Rank.two.next(Direction.upLeft), Rank.three);
        expect(Rank.three.next(Direction.upRight), Rank.four);
        expect(Rank.four.next(Direction.upLeftLeft), Rank.five);
        expect(Rank.five.next(Direction.upRightRight), Rank.six);
        expect(Rank.one.next(Direction.upUpLeft), Rank.three);
        expect(Rank.two.next(Direction.upUpRight), Rank.four);

        // Downward (towards Rank.one)
        expect(Rank.eight.next(Direction.down), Rank.seven);
        expect(Rank.seven.next(Direction.downLeft), Rank.six);
        expect(Rank.six.next(Direction.downRight), Rank.five);
        expect(Rank.five.next(Direction.downLeftLeft), Rank.four);
        expect(Rank.four.next(Direction.downRightRight), Rank.three);
        expect(Rank.eight.next(Direction.downDownLeft), Rank.six);
        expect(Rank.seven.next(Direction.downDownRight), Rank.five);
      },
    );

    test('should return null at board edges', () {
      // Top edge (Rank.eight) - Attempting to move further "up"
      expect(Rank.eight.next(Direction.up), isNull);
      expect(Rank.eight.next(Direction.upLeft), isNull);
      expect(Rank.eight.next(Direction.upRight), isNull);
      expect(Rank.eight.next(Direction.upLeftLeft), isNull);
      expect(Rank.eight.next(Direction.upRightRight), isNull);
      expect(
        Rank.seven.next(Direction.upUpLeft),
        isNull,
      ); // Rank.seven + 2 = null (off board)
      expect(
        Rank.seven.next(Direction.upUpRight),
        isNull,
      ); // Rank.seven + 2 = null (off board)
      expect(Rank.eight.next(Direction.upUpLeft), isNull);
      expect(Rank.eight.next(Direction.upUpRight), isNull);

      // Bottom edge (Rank.one) - Attempting to move further "down"
      expect(Rank.one.next(Direction.down), isNull);
      expect(Rank.one.next(Direction.downLeft), isNull);
      expect(Rank.one.next(Direction.downRight), isNull);
      expect(Rank.one.next(Direction.downLeftLeft), isNull);
      expect(Rank.one.next(Direction.downRightRight), isNull);
      expect(
        Rank.two.next(Direction.downDownLeft),
        isNull,
      ); // Rank.two - 2 = null (off board)
      expect(
        Rank.two.next(Direction.downDownRight),
        isNull,
      ); // Rank.two - 2 = null (off board)
      expect(Rank.one.next(Direction.downDownLeft), isNull);
      expect(Rank.one.next(Direction.downDownRight), isNull);
    });
  });
}
