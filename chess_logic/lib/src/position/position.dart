import 'package:chess_logic/src/position/direction.dart';
import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/position/rank.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:equatable/equatable.dart';

final class AmbiguousPosition with EquatableMixin {
  const AmbiguousPosition({this.file, this.rank})
    : assert(
        file != null || rank != null,
        'At least one of file or rank must be provided.',
      );

  factory AmbiguousPosition.fromAlgebraic(String notation) {
    if (!_regex.hasMatch(notation)) {
      throw ArgumentError.value(
        notation,
        'notation',
        'Invalid algebraic notation format.',
      );
    }
    final match = _regex.firstMatch(notation)!;
    File? file;
    if (match[1] case final fileChar?) {
      file = File.fromLetter(fileChar);
    }
    Rank? rank;
    if (match[2] case final rankChar?) {
      rank = Rank.fromValue(int.tryParse(rankChar) ?? 0);
    }
    return AmbiguousPosition(file: file, rank: rank);
  }

  static final _regex = RegExp(r'^([a-h])?([1-8])?$');

  final File? file;
  final Rank? rank;

  @override
  List<Object?> get props => [file, rank];

  AmbiguousMovementType? get ambiguousMovementType => switch ((file, rank)) {
    (null, null) => null,
    (File(), null) => AmbiguousMovementType.file,
    (null, Rank()) => AmbiguousMovementType.rank,
    (File(), Rank()) => AmbiguousMovementType.both,
  };

  bool couldBe(Position position) {
    if (file != null && position.file != file) return false;
    if (rank != null && position.rank != rank) return false;
    return true;
  }

  String toAlgebraic() {
    final filePart = file?.letter ?? '?';
    final rankPart = rank?.value.toString() ?? '?';
    return '$filePart$rankPart';
  }
}

enum Position implements AmbiguousPosition, Comparable<Position> {
  a1._(File.a, Rank.one),
  a2._(File.a, Rank.two),
  a3._(File.a, Rank.three),
  a4._(File.a, Rank.four),
  a5._(File.a, Rank.five),
  a6._(File.a, Rank.six),
  a7._(File.a, Rank.seven),
  a8._(File.a, Rank.eight),
  b1._(File.b, Rank.one),
  b2._(File.b, Rank.two),
  b3._(File.b, Rank.three),
  b4._(File.b, Rank.four),
  b5._(File.b, Rank.five),
  b6._(File.b, Rank.six),
  b7._(File.b, Rank.seven),
  b8._(File.b, Rank.eight),
  c1._(File.c, Rank.one),
  c2._(File.c, Rank.two),
  c3._(File.c, Rank.three),
  c4._(File.c, Rank.four),
  c5._(File.c, Rank.five),
  c6._(File.c, Rank.six),
  c7._(File.c, Rank.seven),
  c8._(File.c, Rank.eight),
  d1._(File.d, Rank.one),
  d2._(File.d, Rank.two),
  d3._(File.d, Rank.three),
  d4._(File.d, Rank.four),
  d5._(File.d, Rank.five),
  d6._(File.d, Rank.six),
  d7._(File.d, Rank.seven),
  d8._(File.d, Rank.eight),
  e1._(File.e, Rank.one),
  e2._(File.e, Rank.two),
  e3._(File.e, Rank.three),
  e4._(File.e, Rank.four),
  e5._(File.e, Rank.five),
  e6._(File.e, Rank.six),
  e7._(File.e, Rank.seven),
  e8._(File.e, Rank.eight),
  f1._(File.f, Rank.one),
  f2._(File.f, Rank.two),
  f3._(File.f, Rank.three),
  f4._(File.f, Rank.four),
  f5._(File.f, Rank.five),
  f6._(File.f, Rank.six),
  f7._(File.f, Rank.seven),
  f8._(File.f, Rank.eight),
  g1._(File.g, Rank.one),
  g2._(File.g, Rank.two),
  g3._(File.g, Rank.three),
  g4._(File.g, Rank.four),
  g5._(File.g, Rank.five),
  g6._(File.g, Rank.six),
  g7._(File.g, Rank.seven),
  g8._(File.g, Rank.eight),
  h1._(File.h, Rank.one),
  h2._(File.h, Rank.two),
  h3._(File.h, Rank.three),
  h4._(File.h, Rank.four),
  h5._(File.h, Rank.five),
  h6._(File.h, Rank.six),
  h7._(File.h, Rank.seven),
  h8._(File.h, Rank.eight);

  const Position._(this.file, this.rank);

  factory Position(File file, Rank rank) =>
      Position.values.firstWhere((p) => p.file == file && p.rank == rank);

  @override
  final File file;

  @override
  final Rank rank;

  factory Position.fromAlgebraic(String notation) {
    if (notation.length != 2) {
      throw ArgumentError.value(
        notation,
        'notation',
        'Invalid algebraic notation length',
      );
    }
    final file = File.fromLetter(notation[0]);
    final rankValue = int.tryParse(notation[1]);
    if (rankValue == null) {
      throw ArgumentError.value(
        notation[1],
        'rank',
        'Invalid rank character: ${notation[1]}',
      );
    }
    final rank = Rank.fromValue(rankValue);
    return Position(file, rank);
  }

  Square operator <(Piece? piece) => Square(this, piece);

  @override
  String toAlgebraic() => '${file.letter}${rank.value}';

  Position? next(Direction direction) {
    File? newFile;
    Rank? newRank;

    // Determine new file coordinate
    if (direction.ignoreFile) {
      newFile = file; // Keep current file for vertical movements
    } else {
      newFile = file.next(direction);
      if (newFile == null) return null; // Out of bounds
    }

    // Determine new rank coordinate
    if (direction.ignoreRank) {
      newRank = rank; // Keep current rank for horizontal movements
    } else {
      newRank = rank.next(direction);
      if (newRank == null) return null; // Out of bounds
    }

    return Position(newFile, newRank);
  }

  @override
  String toString() => toAlgebraic();

  @override
  int compareTo(Position other) {
    final fileComparison = file.compareTo(other.file);
    if (fileComparison != 0) return fileComparison;
    return rank.compareTo(other.rank);
  }

  @override
  final ambiguousMovementType = AmbiguousMovementType.both;

  @override
  bool couldBe(Position position) => position == this;

  @override
  List<Object?> get props => [file, rank];

  @override
  bool? get stringify => null;
}
