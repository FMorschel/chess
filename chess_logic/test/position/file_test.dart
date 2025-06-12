import 'package:chess_logic/src/controller/direction.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:test/test.dart';

void main() {
  group('File', () {
    test('should parse from valid character', () {
      expect(File.fromLetter('a'), File.a);
      expect(File.fromLetter('h'), File.h);
    });

    test('should parse case-insensitively', () {
      expect(File.fromLetter('C'), File.c);
      expect(File.fromLetter('G'), File.g);
    });

    test('should throw for invalid character', () {
      expect(() => File.fromLetter('z'), throwsArgumentError);
      expect(() => File.fromLetter('1'), throwsArgumentError);
      expect(() => File.fromLetter(''), throwsArgumentError);
    });

    test('should return correct letter', () {
      expect(File.e.letter, equals('e'));
      expect(File.a.letter, equals('a'));
    });

    group('distanceTo', () {
      test('should return 0 for same file', () {
        expect(File.a.distanceTo(File.a), equals(0));
        expect(File.h.distanceTo(File.h), equals(0));
      });

      test('should return positive distance for rightward files', () {
        expect(File.a.distanceTo(File.b), equals(1));
        expect(File.c.distanceTo(File.e), equals(2));
        expect(File.f.distanceTo(File.h), equals(2));
      });

      test('should return positive distance for leftward files', () {
        expect(File.b.distanceTo(File.a), equals(1));
        expect(File.e.distanceTo(File.c), equals(2));
        expect(File.h.distanceTo(File.f), equals(2));
      });

      test('should handle non-adjacent files', () {
        expect(File.a.distanceTo(File.d), equals(3));
        expect(File.g.distanceTo(File.c), equals(4));
      });
    });
  });

  group('next', () {
    test('should return null for vertical directions', () {
      expect(File.a.next(Direction.up), isNull);
      expect(File.d.next(Direction.down), isNull);
    });

    test(
      'should return correct file for horizontal and diagonal directions',
      () {
        // Leftward
        expect(File.b.next(Direction.left), File.a);
        expect(File.c.next(Direction.upLeft), File.b);
        expect(File.d.next(Direction.downLeft), File.c);
        expect(File.e.next(Direction.upUpLeft), File.d);
        expect(File.f.next(Direction.downDownLeft), File.e);

        // Rightward
        expect(File.g.next(Direction.right), File.h);
        expect(File.f.next(Direction.upRight), File.g);
        expect(File.e.next(Direction.downRight), File.f);
        expect(File.d.next(Direction.upUpRight), File.e);
        expect(File.c.next(Direction.downDownRight), File.d);

        // Knight L-shape moves
        expect(File.c.next(Direction.upLeftLeft), File.a);
        expect(File.f.next(Direction.downLeftLeft), File.d);
        expect(File.a.next(Direction.upRightRight), File.c);
        expect(File.d.next(Direction.downRightRight), File.f);
      },
    );

    test('should return null at board edges', () {
      // Left edge
      expect(File.a.next(Direction.left), isNull);
      expect(File.a.next(Direction.upLeft), isNull);
      expect(File.a.next(Direction.downLeft), isNull);
      expect(File.a.next(Direction.upUpLeft), isNull);
      expect(File.a.next(Direction.downDownLeft), isNull);
      expect(File.b.next(Direction.upLeftLeft), isNull); // File.b - 2 = null
      expect(File.b.next(Direction.downLeftLeft), isNull); // File.b - 2 = null
      expect(File.a.next(Direction.upLeftLeft), isNull);
      expect(File.a.next(Direction.downLeftLeft), isNull);

      // Right edge
      expect(File.h.next(Direction.right), isNull);
      expect(File.h.next(Direction.upRight), isNull);
      expect(File.h.next(Direction.downRight), isNull);
      expect(File.h.next(Direction.upUpRight), isNull);
      expect(File.h.next(Direction.downDownRight), isNull);
      expect(File.g.next(Direction.upRightRight), isNull); // File.g + 2 = null
      expect(
        File.g.next(Direction.downRightRight),
        isNull,
      ); // File.g + 2 = null
      expect(File.h.next(Direction.upRightRight), isNull);
      expect(File.h.next(Direction.downRightRight), isNull);
    });
  });
}
