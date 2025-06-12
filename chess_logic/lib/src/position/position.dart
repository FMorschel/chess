import 'package:chess_logic/src/controller/direction.dart';
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

final class Position extends AmbiguousPosition {
  const Position(File file, Rank rank) : super(file: file, rank: rank);

  @override
  File get file => super.file!;

  @override
  Rank get rank => super.rank!;

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
    final newFile = file.next(direction) ?? file;
    final newRank = rank.next(direction) ?? rank;
    if (newFile == file && newRank == rank) {
      return null;
    }
    return Position(newFile, newRank);
  }

  @override
  String toString() => toAlgebraic();
}
