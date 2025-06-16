import 'package:chess_logic/src/position/direction.dart';
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

  group('compareTo', () {
    test('should return 0 for same file', () {
      expect(File.a.compareTo(File.a), equals(0));
      expect(File.d.compareTo(File.d), equals(0));
      expect(File.h.compareTo(File.h), equals(0));
    });

    test('should return negative for files to the left', () {
      expect(File.a.compareTo(File.b), lessThan(0));
      expect(File.a.compareTo(File.h), lessThan(0));
      expect(File.c.compareTo(File.f), lessThan(0));
      expect(File.d.compareTo(File.e), lessThan(0));
    });

    test('should return positive for files to the right', () {
      expect(File.b.compareTo(File.a), greaterThan(0));
      expect(File.h.compareTo(File.a), greaterThan(0));
      expect(File.f.compareTo(File.c), greaterThan(0));
      expect(File.e.compareTo(File.d), greaterThan(0));
    });

    test('should be consistent with alphabetical order', () {
      final files = [
        File.h,
        File.a,
        File.e,
        File.c,
        File.b,
        File.g,
        File.f,
        File.d,
      ];
      final sorted = [...files]..sort();

      expect(
        sorted,
        containsAllInOrder([
          File.a,
          File.b,
          File.c,
          File.d,
          File.e,
          File.f,
          File.g,
          File.h,
        ]),
      );
    });

    test('should satisfy compareTo contract - antisymmetric', () {
      expect(File.a.compareTo(File.h), equals(-File.h.compareTo(File.a)));
      expect(File.c.compareTo(File.f), equals(-File.f.compareTo(File.c)));
    });

    test('should satisfy compareTo contract - transitive', () {
      // a < d < h
      expect(File.a.compareTo(File.d), lessThan(0));
      expect(File.d.compareTo(File.h), lessThan(0));
      expect(File.a.compareTo(File.h), lessThan(0));
    });

    test('should handle all adjacent comparisons', () {
      expect(File.a.compareTo(File.b), lessThan(0));
      expect(File.b.compareTo(File.c), lessThan(0));
      expect(File.c.compareTo(File.d), lessThan(0));
      expect(File.d.compareTo(File.e), lessThan(0));
      expect(File.e.compareTo(File.f), lessThan(0));
      expect(File.f.compareTo(File.g), lessThan(0));
      expect(File.g.compareTo(File.h), lessThan(0));
    });

    test('should be consistent with index ordering', () {
      for (int i = 0; i < File.values.length; i++) {
        for (int j = 0; j < File.values.length; j++) {
          final file1 = File.values[i];
          final file2 = File.values[j];
          final comparison = file1.compareTo(file2);

          if (i < j) {
            expect(
              comparison,
              lessThan(0),
              reason: '$file1 should be less than $file2',
            );
          } else if (i > j) {
            expect(
              comparison,
              greaterThan(0),
              reason: '$file1 should be greater than $file2',
            );
          } else {
            expect(comparison, equals(0), reason: '$file1 should equal $file2');
          }
        }
      }
    });
  });
}
