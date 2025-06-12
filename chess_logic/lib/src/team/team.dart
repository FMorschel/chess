import 'package:chess_logic/src/position/rank.dart';

enum Team {
  white._('White', Rank.one),
  black._('Black', Rank.eight);

  const Team._(this.name, this.homeRank);

  factory Team(String name) => Team.values.firstWhere(
    (team) => team.name.toLowerCase() == name.toLowerCase(),
    orElse: () =>
        throw ArgumentError.value(name, 'name', 'Invalid team name: "$name"'),
  );

  final String name;

  final Rank homeRank;
}

extension type BlackTeam._(Team _team) implements Team {
  const BlackTeam() : _team = Team.black;
}

extension type WhiteTeam._(Team _team) implements Team {
  const WhiteTeam() : _team = Team.white;
}
