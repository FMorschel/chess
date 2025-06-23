import '../position/rank.dart';

import '../square/piece.dart';

enum Team {
  white._('White', Rank.one),
  black._('Black', Rank.eight);

  factory Team(String name) => Team.values.firstWhere(
    (team) => team.name.toLowerCase() == name.toLowerCase(),
    orElse: () =>
        throw ArgumentError.value(name, 'name', 'Invalid team name: "$name"'),
  );

  const Team._(this.name, this.homeRank);

  final String name;
  final Rank homeRank;

  /// Immutable list of all piece types for this team
  List<Piece> get pieces =>
      List.unmodifiable([pawn, rook, knight, bishop, queen, king]);

  /// Pawn piece for this team
  Pawn get pawn => switch (this) {
    Team.white => Pawn.white,
    Team.black => Pawn.black,
  };

  /// Rook piece for this team
  Rook get rook => switch (this) {
    Team.white => Rook.white,
    Team.black => Rook.black,
  };

  /// Knight piece for this team
  Knight get knight => switch (this) {
    Team.white => Knight.white,
    Team.black => Knight.black,
  };

  /// Bishop piece for this team
  Bishop get bishop => switch (this) {
    Team.white => Bishop.white,
    Team.black => Bishop.black,
  };

  /// Queen piece for this team
  Queen get queen => switch (this) {
    Team.white => Queen.white,
    Team.black => Queen.black,
  };

  /// King piece for this team
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
