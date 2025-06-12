import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:test/test.dart';

void main() {
  group('AmbiguousMovementType', () {
    test('file', () {
      expect(AmbiguousMovementType.file.name, 'file');
      expect(AmbiguousMovementType.file.index, 0);
    });

    test('rank', () {
      expect(AmbiguousMovementType.rank.name, 'rank');
      expect(AmbiguousMovementType.rank.index, 1);
    });

    test('both', () {
      expect(AmbiguousMovementType.both.name, 'both');
      expect(AmbiguousMovementType.both.index, 2);
    });
    test('values', () {
      expect(
        AmbiguousMovementType.values,
        unorderedEquals([
          AmbiguousMovementType.file,
          AmbiguousMovementType.rank,
          AmbiguousMovementType.both,
        ]),
      );
    });
  });
}
