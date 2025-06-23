import 'package:chess_logic/src/position/direction.dart';
import 'package:test/test.dart';

void main() {
  group('Direction', () {
    group('static collections', () {
      test('all should contain all direction values', () {
        expect(Direction.all, hasLength(16));
        expect(Direction.all, equals(Direction.values));
      });

      test('cross should contain orthogonal directions', () {
        expect(Direction.cross, hasLength(4));
        expect(
          Direction.cross,
          containsAll([
            Direction.up,
            Direction.down,
            Direction.left,
            Direction.right,
          ]),
        );
      });

      test('diagonal should contain diagonal directions', () {
        expect(Direction.diagonal, hasLength(4));
        expect(
          Direction.diagonal,
          containsAll([
            Direction.upLeft,
            Direction.upRight,
            Direction.downLeft,
            Direction.downRight,
          ]),
        );
      });

      test('knight should contain knight move directions', () {
        expect(Direction.knight, hasLength(8));
        expect(
          Direction.knight,
          containsAll([
            Direction.upUpLeft,
            Direction.upLeftLeft,
            Direction.upUpRight,
            Direction.upRightRight,
            Direction.downDownLeft,
            Direction.downLeftLeft,
            Direction.downDownRight,
            Direction.downRightRight,
          ]),
        );
      });

      test('orthogonal should contain cross and diagonal directions', () {
        expect(Direction.orthogonal, hasLength(8));
        expect(
          Direction.orthogonal,
          containsAll([
            // Cross directions
            Direction.up,
            Direction.down,
            Direction.left,
            Direction.right,
            // Diagonal directions
            Direction.upLeft,
            Direction.upRight,
            Direction.downLeft,
            Direction.downRight,
          ]),
        );
      });

      test('orthogonal should be combination of cross and diagonal', () {
        final expectedOrthogonal = [...Direction.cross, ...Direction.diagonal];
        expect(Direction.orthogonal, equals(expectedOrthogonal));
        expect(
          Direction.orthogonal.toSet(),
          equals({...Direction.cross, ...Direction.diagonal}),
        );
      });

      test('orthogonal should not contain knight moves', () {
        final orthogonalSet = Direction.orthogonal.toSet();
        final knightSet = Direction.knight.toSet();

        expect(orthogonalSet.intersection(knightSet), isEmpty);

        for (final knightDirection in Direction.knight) {
          expect(Direction.orthogonal, isNot(contains(knightDirection)));
        }
      });

      test(
        'orthogonal should contain exactly cross and diagonal directions',
        () {
          final orthogonalSet = Direction.orthogonal.toSet();
          final crossAndDiagonalSet = {
            ...Direction.cross,
            ...Direction.diagonal,
          };

          expect(orthogonalSet, equals(crossAndDiagonalSet));
          expect(orthogonalSet.length, equals(8));
        },
      );
      test(
        'all directions should be covered by orthogonal and knight collections',
        () {
          final covered = <Direction>{
            ...Direction.orthogonal,
            ...Direction.knight,
          };
          expect(covered, hasLength(Direction.all.length));
          expect(covered, containsAll(Direction.all));
        },
      );

      test(
        'all directions should be covered by cross, diagonal and knight '
        'collections',
        () {
          final covered = <Direction>{
            ...Direction.cross,
            ...Direction.diagonal,
            ...Direction.knight,
          };
          expect(covered, hasLength(Direction.all.length));
          expect(covered, containsAll(Direction.all));
        },
      );
    });

    group('opposite getter', () {
      test('should return correct opposite for cross directions', () {
        expect(Direction.up.opposite, equals(Direction.down));
        expect(Direction.down.opposite, equals(Direction.up));
        expect(Direction.left.opposite, equals(Direction.right));
        expect(Direction.right.opposite, equals(Direction.left));
      });

      test('should return correct opposite for diagonal directions', () {
        expect(Direction.upLeft.opposite, equals(Direction.downRight));
        expect(Direction.upRight.opposite, equals(Direction.downLeft));
        expect(Direction.downLeft.opposite, equals(Direction.upRight));
        expect(Direction.downRight.opposite, equals(Direction.upLeft));
      });

      test('should return correct opposite for knight directions', () {
        expect(Direction.upUpLeft.opposite, equals(Direction.downDownRight));
        expect(Direction.upLeftLeft.opposite, equals(Direction.downRightRight));
        expect(Direction.upUpRight.opposite, equals(Direction.downDownLeft));
        expect(Direction.upRightRight.opposite, equals(Direction.downLeftLeft));
        expect(Direction.downDownLeft.opposite, equals(Direction.upUpRight));
        expect(Direction.downLeftLeft.opposite, equals(Direction.upRightRight));
        expect(Direction.downDownRight.opposite, equals(Direction.upUpLeft));
        expect(Direction.downRightRight.opposite, equals(Direction.upLeftLeft));
      });

      test('opposite relationship should be symmetric', () {
        for (final direction in Direction.all) {
          expect(
            direction.opposite.opposite,
            equals(direction),
            reason:
                'Direction $direction should be the opposite of its opposite',
          );
        }
      });

      test('no direction should be its own opposite', () {
        for (final direction in Direction.all) {
          expect(
            direction.opposite,
            isNot(equals(direction)),
            reason: 'Direction $direction should not be its own opposite',
          );
        }
      });
    });

    group('enum values', () {
      test('should have correct number of directions', () {
        expect(Direction.values, hasLength(16));
      });

      test('should contain all expected direction values', () {
        final expectedDirections = [
          Direction.up,
          Direction.down,
          Direction.left,
          Direction.right,
          Direction.upLeft,
          Direction.upRight,
          Direction.downLeft,
          Direction.downRight,
          Direction.upUpLeft,
          Direction.upLeftLeft,
          Direction.upUpRight,
          Direction.upRightRight,
          Direction.downDownLeft,
          Direction.downLeftLeft,
          Direction.downDownRight,
          Direction.downRightRight,
        ];

        expect(Direction.values, containsAll(expectedDirections));
      });
    });

    group('coordinate ignore properties', () {
      test('cross directions should have correct ignore properties', () {
        expect(Direction.up.ignoreFile, isTrue);
        expect(Direction.up.ignoreRank, isFalse);

        expect(Direction.down.ignoreFile, isTrue);
        expect(Direction.down.ignoreRank, isFalse);

        expect(Direction.left.ignoreFile, isFalse);
        expect(Direction.left.ignoreRank, isTrue);

        expect(Direction.right.ignoreFile, isFalse);
        expect(Direction.right.ignoreRank, isTrue);
      });

      test('diagonal directions should not ignore any coordinates', () {
        for (final direction in Direction.diagonal) {
          expect(
            direction.ignoreFile,
            isFalse,
            reason: 'Diagonal direction $direction should not ignore file',
          );
          expect(
            direction.ignoreRank,
            isFalse,
            reason: 'Diagonal direction $direction should not ignore rank',
          );
        }
      });

      test('knight directions should not ignore any coordinates', () {
        for (final direction in Direction.knight) {
          expect(
            direction.ignoreFile,
            isFalse,
            reason: 'Knight direction $direction should not ignore file',
          );
          expect(
            direction.ignoreRank,
            isFalse,
            reason: 'Knight direction $direction should not ignore rank',
          );
        }
      });

      test('only cross directions should ignore coordinates', () {
        final nonCrossDirections = Direction.all
            .where((d) => !Direction.cross.contains(d))
            .toList();

        for (final direction in nonCrossDirections) {
          expect(
            direction.ignoreFile,
            isFalse,
            reason: 'Non-cross direction $direction should not ignore file',
          );
          expect(
            direction.ignoreRank,
            isFalse,
            reason: 'Non-cross direction $direction should not ignore rank',
          );
        }
      });

      test('vertical directions should ignore file coordinate', () {
        const verticalDirections = [Direction.up, Direction.down];

        for (final direction in verticalDirections) {
          expect(
            direction.ignoreFile,
            isTrue,
            reason: 'Vertical direction $direction should ignore file',
          );
          expect(
            direction.ignoreRank,
            isFalse,
            reason: 'Vertical direction $direction should not ignore rank',
          );
        }
      });

      test('horizontal directions should ignore rank coordinate', () {
        const horizontalDirections = [Direction.left, Direction.right];

        for (final direction in horizontalDirections) {
          expect(
            direction.ignoreFile,
            isFalse,
            reason: 'Horizontal direction $direction should not ignore file',
          );
          expect(
            direction.ignoreRank,
            isTrue,
            reason: 'Horizontal direction $direction should ignore rank',
          );
        }
      });

      test('no direction should ignore both coordinates', () {
        for (final direction in Direction.all) {
          expect(
            direction.ignoreFile && direction.ignoreRank,
            isFalse,
            reason: 'Direction $direction should not ignore both coordinates',
          );
        }
      });
    });
  });
}
