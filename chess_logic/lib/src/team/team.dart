import 'package:chess_logic/src/position/rank.dart';

import '../square/piece.dart';

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

  List<Piece> get pieces => [
    pawn,
    rook,
    knight,
    bishop,
    queen,
    king,
  ];

  Pawn get pawn => switch (this) {
    Team.white => Pawn.white,
    Team.black => Pawn.black,
  };

  Rook get rook => switch (this) {
    Team.white => Rook.white,
    Team.black => Rook.black,
  };

  Knight get knight => switch (this) {
    Team.white => Knight.white,
    Team.black => Knight.black,
  };

  Bishop get bishop => switch (this) {
    Team.white => Bishop.white,
    Team.black => Bishop.black,
  };

  Queen get queen => switch (this) {
    Team.white => Queen.white,
    Team.black => Queen.black,
  };

  King get king => switch (this) {
    Team.white => King.white,
    Team.black => King.black,
  };
}

extension type BlackTeam._(Team _team) implements Team {
  const BlackTeam() : _team = Team.black;
}

extension type WhiteTeam._(Team _team) implements Team {
  const WhiteTeam() : _team = Team.white;
}
