import 'package:chess_logic/src/controller/game_state.dart';
import 'package:test/test.dart';

void main() {
  group('GameState', () {
    group('enum values', () {
      test('should have correct number of values', () {
        expect(GameState.values.length, equals(5));
      });

      test('should contain all expected values', () {
        expect(
          GameState.values,
          containsAll([
            GameState.inProgress,
            GameState.teamWin,
            GameState.stalemate,
            GameState.draw,
            GameState.paused,
          ]),
        );
      });
    });

    group('end property', () {
      test('inProgress should not be an end state', () {
        expect(GameState.inProgress.end, isFalse);
      });

      test('teamWin should be an end state', () {
        expect(GameState.teamWin.end, isTrue);
      });

      test('stalemate should be an end state', () {
        expect(GameState.stalemate.end, isTrue);
      });

      test('draw should be an end state', () {
        expect(GameState.draw.end, isTrue);
      });

      test('paused should not be an end state', () {
        expect(GameState.paused.end, isFalse);
      });
    });

    group('game end states', () {
      test('should correctly identify end states', () {
        final endStates = GameState.values.where((state) => state.end);
        expect(
          endStates,
          containsAll([GameState.teamWin, GameState.stalemate, GameState.draw]),
        );
        expect(endStates.length, equals(3));
      });

      test('should correctly identify non-end states', () {
        final nonEndStates = GameState.values.where((state) => !state.end);
        expect(
          nonEndStates,
          containsAll([GameState.inProgress, GameState.paused]),
        );
        expect(nonEndStates.length, equals(2));
      });
    });
    group('constructor behavior', () {
      test(
        'default constructor should set end to true and active to false',
        () {
          // This tests the default value behavior
          // Since we can't directly test constructor behavior on enums,
          // we verify that states without explicit parameters use defaults
          expect(GameState.teamWin.end, isTrue);
          expect(GameState.teamWin.active, isFalse);
          expect(GameState.stalemate.end, isTrue);
          expect(GameState.stalemate.active, isFalse);
          expect(GameState.draw.end, isTrue);
          expect(GameState.draw.active, isFalse);
        },
      );

      test('explicit parameters should override defaults', () {
        expect(GameState.inProgress.end, isFalse);
        expect(GameState.inProgress.active, isTrue);
        expect(GameState.paused.end, isFalse);
        expect(GameState.paused.active, isFalse);
      });
    });

    group('enum comparison and equality', () {
      test('enum values should be equal to themselves', () {
        expect(GameState.inProgress, equals(GameState.inProgress));
        expect(GameState.teamWin, equals(GameState.teamWin));
        expect(GameState.stalemate, equals(GameState.stalemate));
        expect(GameState.draw, equals(GameState.draw));
        expect(GameState.paused, equals(GameState.paused));
      });

      test('different enum values should not be equal', () {
        expect(GameState.inProgress, isNot(equals(GameState.teamWin)));
        expect(GameState.teamWin, isNot(equals(GameState.stalemate)));
        expect(GameState.stalemate, isNot(equals(GameState.draw)));
        expect(GameState.draw, isNot(equals(GameState.paused)));
        expect(GameState.paused, isNot(equals(GameState.inProgress)));
      });
    });

    group('string representation', () {
      test('should have meaningful string representations', () {
        expect(GameState.inProgress.toString(), contains('inProgress'));
        expect(GameState.teamWin.toString(), contains('teamWin'));
        expect(GameState.stalemate.toString(), contains('stalemate'));
        expect(GameState.draw.toString(), contains('draw'));
        expect(GameState.paused.toString(), contains('paused'));
      });
    });
    group('game flow logic', () {
      test('should distinguish between active and inactive states', () {
        // Only inProgress should be active
        expect(GameState.inProgress.active, isTrue);
        expect(GameState.inProgress.end, isFalse);

        // All other states should be inactive
        final inactiveStates = [
          GameState.teamWin,
          GameState.stalemate,
          GameState.draw,
          GameState.paused,
        ];

        for (final state in inactiveStates) {
          expect(state.active, isFalse, reason: '$state should be inactive');
        }

        // Paused is inactive but not an end state
        expect(GameState.paused.end, isFalse);
        expect(GameState.paused.active, isFalse);

        // End states should be inactive
        final endStates = [
          GameState.teamWin,
          GameState.stalemate,
          GameState.draw,
        ];
        for (final state in endStates) {
          expect(state.end, isTrue, reason: '$state should be an end state');
          expect(state.active, isFalse, reason: '$state should be inactive');
        }
      });

      test('active states should not be end states', () {
        final activeStates = GameState.values.where((state) => state.active);
        for (final state in activeStates) {
          expect(
            state.end,
            isFalse,
            reason: 'Active state $state should not be an end state',
          );
        }
      });

      test('end states should not be active', () {
        final endStates = GameState.values.where((state) => state.end);
        for (final state in endStates) {
          expect(
            state.active,
            isFalse,
            reason: 'End state $state should not be active',
          );
        }
      });
    });

    group('active property', () {
      test('inProgress should be active', () {
        expect(GameState.inProgress.active, isTrue);
      });

      test('teamWin should not be active', () {
        expect(GameState.teamWin.active, isFalse);
      });

      test('stalemate should not be active', () {
        expect(GameState.stalemate.active, isFalse);
      });

      test('draw should not be active', () {
        expect(GameState.draw.active, isFalse);
      });

      test('paused should not be active', () {
        expect(GameState.paused.active, isFalse);
      });
    });

    group('active states', () {
      test('should correctly identify active states', () {
        final activeStates = GameState.values.where((state) => state.active);
        expect(activeStates, containsAll([GameState.inProgress]));
        expect(activeStates.length, equals(1));
      });

      test('should correctly identify inactive states', () {
        final inactiveStates = GameState.values.where((state) => !state.active);
        expect(
          inactiveStates,
          containsAll([
            GameState.teamWin,
            GameState.stalemate,
            GameState.draw,
            GameState.paused,
          ]),
        );
        expect(inactiveStates.length, equals(4));
      });
    });
  });
}
