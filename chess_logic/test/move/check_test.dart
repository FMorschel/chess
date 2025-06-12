import 'package:chess_logic/src/move/check.dart';
import 'package:test/test.dart';

void main() {
  group('Check', () {
    test('none', () {
      expect(Check.none.algebraic, '');
    });
    test('check', () {
      expect(Check.check.algebraic, '+');
    });
    test('checkmate', () {
      expect(Check.checkmate.algebraic, '#');
    });
  });
}
