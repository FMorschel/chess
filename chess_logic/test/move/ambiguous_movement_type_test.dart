import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:test/test.dart';

void main() {
  group('AmbiguousMovementType', () {
    test('none', () {
      expect(AmbiguousMovementType.none.name, 'none');
      expect(AmbiguousMovementType.none.index, 0);
    });
    test('file', () {
      expect(AmbiguousMovementType.file.name, 'file');
      expect(AmbiguousMovementType.file.index, 1);
    });

    test('rank', () {
      expect(AmbiguousMovementType.rank.name, 'rank');
      expect(AmbiguousMovementType.rank.index, 2);
    });

    test('both', () {
      expect(AmbiguousMovementType.both.name, 'both');
      expect(AmbiguousMovementType.both.index, 3);
    });
    test('values', () {
      expect(
        AmbiguousMovementType.values,
        unorderedEquals([
          AmbiguousMovementType.file,
          AmbiguousMovementType.rank,
          AmbiguousMovementType.both,
          AmbiguousMovementType.none,
        ]),
      );
    });
  });
}
