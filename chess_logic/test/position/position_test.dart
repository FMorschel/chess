import 'package:chess_logic/src/position/direction.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/position/rank.dart';
import 'package:test/test.dart';

void main() {
  group('Position', () {
    test('should create position from file and rank', () {
      final pos = Position._(File.e, Rank.four);

      expect(pos.file, equals(File.e));
      expect(pos.rank, equals(Rank.four));
    });

    test('should parse from algebraic notation', () {
      final pos = Position.fromAlgebraic('e4');

      expect(pos.file, equals(File.e));
      expect(pos.rank, equals(Rank.four));
    });

    test('should return correct algebraic notation', () {
      final pos = Position._(File.e, Rank.four);

      expect(pos.toAlgebraic(), equals('e4'));
    });

    test('should support equality and hashCode', () {
      final pos1 = Position._(File.b, Rank.two);
      final pos2 = Position._(File.b, Rank.two);
      final pos3 = Position._(File.c, Rank.two);

      expect(pos1, equals(pos2));
      expect(pos1.hashCode, equals(pos2.hashCode));
      expect(pos1, isNot(equals(pos3)));
    });

    test('should throw when given invalid algebraic notation', () {
      expect(() => Position.fromAlgebraic('z9'), throwsArgumentError);
      expect(() => Position.fromAlgebraic('44'), throwsArgumentError);
      expect(() => Position.fromAlgebraic('e'), throwsArgumentError);
      expect(() => Position.fromAlgebraic('3e'), throwsArgumentError);
      expect(() => Position.fromAlgebraic(''), throwsArgumentError);
    });
  });

  group('next', () {
    test('should return correct position for all directions', () {
      final c4 = Position.fromAlgebraic('c4');

      // Cardinal
      expect(c4.next(Direction.up), Position.fromAlgebraic('c5'));
      expect(c4.next(Direction.down), Position.fromAlgebraic('c3'));
      expect(c4.next(Direction.left), Position.fromAlgebraic('b4'));
      expect(c4.next(Direction.right), Position.fromAlgebraic('d4'));

      // Diagonal
      expect(c4.next(Direction.upLeft), Position.fromAlgebraic('b5'));
      expect(c4.next(Direction.upRight), Position.fromAlgebraic('d5'));
      expect(c4.next(Direction.downLeft), Position.fromAlgebraic('b3'));
      expect(c4.next(Direction.downRight), Position.fromAlgebraic('d3'));

      // Knight moves (L-shapes)
      expect(c4.next(Direction.upUpLeft), Position.fromAlgebraic('b6'));
      expect(c4.next(Direction.upLeftLeft), Position.fromAlgebraic('a5'));
      expect(c4.next(Direction.upUpRight), Position.fromAlgebraic('d6'));
      expect(c4.next(Direction.upRightRight), Position.fromAlgebraic('e5'));
      expect(c4.next(Direction.downDownLeft), Position.fromAlgebraic('b2'));
      expect(c4.next(Direction.downLeftLeft), Position.fromAlgebraic('a3'));
      expect(c4.next(Direction.downDownRight), Position.fromAlgebraic('d2'));
      expect(c4.next(Direction.downRightRight), Position.fromAlgebraic('e3'));
    });

    test('should return null when moving off board', () {
      final a1 = Position.fromAlgebraic('a1');
      expect(a1.next(Direction.down), isNull);
      expect(a1.next(Direction.left), isNull);
      expect(a1.next(Direction.downLeft), isNull);
      expect(a1.next(Direction.downDownLeft), isNull);

      final h8 = Position.fromAlgebraic('h8');
      expect(h8.next(Direction.up), isNull);
      expect(h8.next(Direction.right), isNull);
      expect(h8.next(Direction.upRight), isNull);
      expect(h8.next(Direction.upUpRight), isNull);
    });
  });

  group('compareTo', () {
    test('should compare files first', () {
      final a1 = Position.fromAlgebraic('a1');
      final b1 = Position.fromAlgebraic('b1');
      final h1 = Position.fromAlgebraic('h1');

      expect(a1.compareTo(b1), lessThan(0));
      expect(b1.compareTo(a1), greaterThan(0));
      expect(a1.compareTo(h1), lessThan(0));
      expect(h1.compareTo(a1), greaterThan(0));
    });

    test('should compare ranks when files are equal', () {
      final e1 = Position.fromAlgebraic('e1');
      final e4 = Position.fromAlgebraic('e4');
      final e8 = Position.fromAlgebraic('e8');

      expect(e1.compareTo(e4), lessThan(0));
      expect(e4.compareTo(e1), greaterThan(0));
      expect(e1.compareTo(e8), lessThan(0));
      expect(e8.compareTo(e1), greaterThan(0));
      expect(e4.compareTo(e8), lessThan(0));
      expect(e8.compareTo(e4), greaterThan(0));
    });

    test('should return 0 for equal positions', () {
      final pos1 = Position.fromAlgebraic('d4');
      final pos2 = Position.fromAlgebraic('d4');

      expect(pos1.compareTo(pos2), equals(0));
      expect(pos2.compareTo(pos1), equals(0));
    });

    test('should prioritize file comparison over rank', () {
      final a8 = Position.fromAlgebraic('a8');
      final h1 = Position.fromAlgebraic('h1');

      // Even though a8 has higher rank than h1,
      // file 'a' comes before file 'h'
      expect(a8.compareTo(h1), lessThan(0));
      expect(h1.compareTo(a8), greaterThan(0));
    });

    test('should be consistent with list sorting', () {
      final positions = [
        Position.fromAlgebraic('h8'),
        Position.fromAlgebraic('a1'),
        Position.fromAlgebraic('d4'),
        Position.fromAlgebraic('a8'),
        Position.fromAlgebraic('h1'),
        Position.fromAlgebraic('d1'),
      ];

      final sorted = [...positions]..sort();

      expect(
        sorted.map((p) => p.toAlgebraic()).toList(),
        containsAllInOrder(['a1', 'a8', 'd1', 'd4', 'h1', 'h8']),
      );
    });

    test('should satisfy compareTo contract - antisymmetric', () {
      final pos1 = Position.fromAlgebraic('c3');
      final pos2 = Position.fromAlgebraic('f6');

      final result1 = pos1.compareTo(pos2);
      final result2 = pos2.compareTo(pos1);

      expect(result1, equals(-result2));
    });

    test('should satisfy compareTo contract - transitive', () {
      final pos1 = Position.fromAlgebraic('a1');
      final pos2 = Position.fromAlgebraic('d4');
      final pos3 = Position.fromAlgebraic('h8');

      expect(pos1.compareTo(pos2), lessThan(0));
      expect(pos2.compareTo(pos3), lessThan(0));
      expect(pos1.compareTo(pos3), lessThan(0));
    });

    test('should handle all corner positions correctly', () {
      final a1 = Position.fromAlgebraic('a1');
      final a8 = Position.fromAlgebraic('a8');
      final h1 = Position.fromAlgebraic('h1');
      final h8 = Position.fromAlgebraic('h8');

      // a1 should be smallest
      expect(a1.compareTo(a8), lessThan(0));
      expect(a1.compareTo(h1), lessThan(0));
      expect(a1.compareTo(h8), lessThan(0));

      // h8 should be largest
      expect(h8.compareTo(a1), greaterThan(0));
      expect(h8.compareTo(a8), greaterThan(0));
      expect(h8.compareTo(h1), greaterThan(0));

      // Same file comparisons
      expect(a1.compareTo(a8), lessThan(0));
      expect(h1.compareTo(h8), lessThan(0));

      // Same rank comparisons
      expect(a1.compareTo(h1), lessThan(0));
      expect(a8.compareTo(h8), lessThan(0));
    });

    test('should be consistent with equality', () {
      final pos1 = Position.fromAlgebraic('e4');
      final pos2 = Position.fromAlgebraic('e4');
      final pos3 = Position.fromAlgebraic('e5');

      // Equal positions should have compareTo result of 0
      expect(pos1.compareTo(pos2), equals(0));
      expect(pos1 == pos2, isTrue);

      // Unequal positions should have non-zero compareTo result
      expect(pos1.compareTo(pos3), isNot(equals(0)));
      expect(pos1 == pos3, isFalse);
    });

    test('list contains should use equality', () {
      final pos1 = Position.fromAlgebraic('c3');
      final pos2 = Position.fromAlgebraic('c3');
      final pos3 = Position.fromAlgebraic('d4');

      final positions = [pos1, pos3];

      // Should find pos1 using equality
      expect(positions.contains(pos2), isTrue);

      // Should not find pos2 if it has different file/rank
      expect(positions.contains(Position.fromAlgebraic('c4')), isFalse);
    });
  });
}
