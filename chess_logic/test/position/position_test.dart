import 'package:chess_logic/src/controller/direction.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/position/rank.dart';
import 'package:test/test.dart';

void main() {
  group('Position', () {
    test('should create position from file and rank', () {
      final pos = Position(File.e, Rank.four);

      expect(pos.file, equals(File.e));
      expect(pos.rank, equals(Rank.four));
    });

    test('should parse from algebraic notation', () {
      final pos = Position.fromAlgebraic('e4');

      expect(pos.file, equals(File.e));
      expect(pos.rank, equals(Rank.four));
    });

    test('should return correct algebraic notation', () {
      final pos = Position(File.e, Rank.four);

      expect(pos.toAlgebraic(), equals('e4'));
    });

    test('should support equality and hashCode', () {
      final pos1 = Position(File.b, Rank.two);
      final pos2 = Position(File.b, Rank.two);
      final pos3 = Position(File.c, Rank.two);

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
      expect(a1.next(Direction.up), isNull);
      expect(a1.next(Direction.left), isNull);
      expect(a1.next(Direction.upLeft), isNull);
      expect(a1.next(Direction.upUpLeft), isNull);

      final h8 = Position.fromAlgebraic('h8');
      expect(h8.next(Direction.down), isNull);
      expect(h8.next(Direction.right), isNull);
      expect(h8.next(Direction.downRight), isNull);
      expect(h8.next(Direction.downDownRight), isNull);
    });
  });
}
