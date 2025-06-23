import 'package:chess_logic/src/position/rank.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('Team', () {
    test('white team', () {
      expect(Team.white.name, 'White');
      expect(Team.white.homeRank, Rank.one);
    });

    test('black team', () {
      expect(Team.black.name, 'Black');
      expect(Team.black.homeRank, Rank.eight);
    });

    test('team equality', () {
      expect(Team.white == Team.black, isFalse);
      expect(Team.white == Team.white, isTrue);
      expect(Team.black == Team.black, isTrue);
    });

    test('factory constructor - valid names', () {
      expect(Team('White'), Team.white);
      expect(Team('Black'), Team.black);
      expect(Team('white'), Team.white);
      expect(Team('black'), Team.black);
      expect(Team('WhItE'), Team.white);
      expect(Team('bLaCk'), Team.black);
    });

    test('factory constructor - invalid name', () {
      expect(() => Team('Invalid'), throwsArgumentError);
    });
  });
  group('BlackTeam', () {
    test('black team name', () {
      expect(const BlackTeam().name, 'Black');
    });

    test('black team homeRank', () {
      expect(const BlackTeam().homeRank, Rank.eight);
    });

    test('black team is Team.black', () {
      expect(const BlackTeam(), Team.black);
    });
  });
  group('WhiteTeam', () {
    test('white team name', () {
      expect(const WhiteTeam().name, 'White');
    });

    test('white team homeRank', () {
      expect(const WhiteTeam().homeRank, Rank.one);
    });

    test('white team is Team.white', () {
      expect(const WhiteTeam(), Team.white);
    });
  });
}
