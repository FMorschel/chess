import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/direction.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/position/rank.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/square/piece_value.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:meta/meta.dart';

sealed class PromotionPiece with Piece {}

sealed class SlidingPiece implements PromotionPiece {}

enum Bishop with Piece implements SlidingPiece {
  white._(Team.white),
  black._(Team.black);

  const Bishop._(this.team);

  factory Bishop(Team team) => switch (team) {
    Team.white => Bishop.white,
    Team.black => Bishop.black,
  };

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.bishop;

  @override
  int get value => PieceValue.bishop.points;

  static const _directions = Direction.diagonal;

  @override
  List<Direction> get _validDirections => _directions;
}

enum King with Piece {
  white._(Team.white),
  black._(Team.black);

  const King._(this.team);

  factory King(Team team) => switch (team) {
    Team.white => King.white,
    Team.black => King.black,
  };

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.king;

  static const _directions = Direction.orthogonal;

  @override
  List<Direction> get _validDirections => _directions;

  @override
  bool get _shouldIteratePositions => false;

  Position get _startPosition => switch (team) {
    Team.white => Position.e1,
    Team.black => Position.e8,
  };

  List<(Position, Direction)> get rookPositions => switch (team) {
    Team.white => [
      (Position.a1, Direction.left),
      (Position.h1, Direction.right),
    ],
    Team.black => [
      (Position.a8, Direction.left),
      (Position.h8, Direction.right),
    ],
  };

  @override
  List<Position> validPositions(BoardState state, Position position) {
    final list = super.validPositions(state, position);
    for (final position in [...list]) {
      if (state[position] case OccupiedSquare(piece: King _)) {
        list.remove(position); // Remove positions occupied by kings
      }
    }
    if (position == _startPosition) {
      for (final (rookPosition, direction) in rookPositions) {
        final rookSquare = state[rookPosition];
        if (rookSquare is! OccupiedSquare ||
            rookSquare.piece.symbol != PieceSymbol.rook) {
          continue;
        }

        var next = position.next(direction);
        if (next == null || state[next].isOccupied) {
          continue;
        }

        if (next.next(direction) case final castelling?
            when state[castelling] is EmptySquare) {
          next = castelling.next(direction);
          if (next == rookPosition) {
            // king-side castling
            list.add(castelling);
          } else if (next != null &&
              state[next].isEmpty &&
              next.next(direction) == rookPosition) {
            // queen-side castling
            list.add(castelling);
          }
        }
      }
    }
    return list;
  }

  @override
  int get value => PieceValue.king.points;
}

enum Knight with Piece implements PromotionPiece {
  white._(Team.white),
  black._(Team.black);

  const Knight._(this.team);

  factory Knight(Team team) => switch (team) {
    Team.white => Knight.white,
    Team.black => Knight.black,
  };

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.knight;

  static const _directions = Direction.knight;

  @override
  List<Direction> get _validDirections => _directions;

  @override
  bool get _shouldIteratePositions => false;

  @override
  int get value => PieceValue.knight.points;
}

enum Pawn with Piece {
  white._(Team.white),
  black._(Team.black);

  const Pawn._(this.team);

  factory Pawn(Team team) => switch (team) {
    Team.white => Pawn.white,
    Team.black => Pawn.black,
  };

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.pawn;

  Direction get forward => switch (team) {
    Team.white => Direction.up,
    Team.black => Direction.down,
  };

  @override
  List<Direction> get _validDirections => captureDirections;

  List<Direction> get captureDirections => switch (team) {
    Team.white => [Direction.upLeft, Direction.upRight],
    Team.black => [Direction.downLeft, Direction.downRight],
  };

  @override
  bool get _shouldIteratePositions => false;

  Rank get initialRank => switch (team) {
    Team.white => Rank.two,
    Team.black => Rank.seven,
  };

  @override
  List<Position> validPositions(
    BoardState state,
    Position position, {
    Move? lastMove,
  }) {
    final list = super.validPositions(state, position);
    for (final direction in captureDirections) {
      final nextPosition = position.next(direction);
      if (nextPosition == null || !list.contains(nextPosition)) continue;
      final nextSquare = state[nextPosition];
      if (nextSquare is EmptySquare) {
        if (lastMove case PawnInitialMove(
          :var to,
        ) when to == Position(nextPosition.file, position.rank)) {
          continue; // Skip if the last move was a pawn initial move
        }
        list.remove(nextPosition);
      }
    }
    if (position.next(forward) case final nextPosition?) {
      final nextSquare = state[nextPosition];
      if (nextSquare.isEmpty) {
        list.add(nextPosition);
        if (nextPosition.next(forward) case final initial?
            when position.rank == initialRank) {
          final initialSquare = state[initial];
          if (initialSquare.isEmpty) {
            list.add(initial);
          }
        }
      }
    }

    return list;
  }

  @override
  int get value => PieceValue.pawn.points;
}

abstract mixin class Piece implements Enum {
  factory Piece.import(String string) {
    final match = _importRegex.firstMatch(string);
    if (match == null) {
      throw ArgumentError('Invalid piece import format: "$string"');
    }

    final team = Team(match.group(1)!);
    final symbol = PieceSymbol.fromLexeme(match.group(2)!);

    return Piece.fromSymbol(symbol, team);
  }

  factory Piece.fromSymbol(PieceSymbol symbol, Team team) {
    return switch (symbol) {
      PieceSymbol.king => King(team),
      PieceSymbol.queen => Queen(team),
      PieceSymbol.rook => Rook(team),
      PieceSymbol.bishop => Bishop(team),
      PieceSymbol.knight => Knight(team),
      PieceSymbol.pawn => Pawn(team),
    };
  }

  static final _importRegex = RegExp('^(White|Black) - ([KQRBNP])\$');

  Team get team;

  PieceSymbol get symbol;

  /// {@macro piece_value}
  int get value;

  String get export => '${team.name} - ${symbol.lexeme}';

  String toAlgebraic() => this is Pawn ? '' : symbol.lexeme;

  List<Direction> get _validDirections;

  bool get _shouldIteratePositions => true;

  @mustCallSuper
  List<Position> validPositions(BoardState state, Position position) {
    final positions = <Position>[];
    for (final direction in _validDirections) {
      Position? current = position.next(direction);
      if (current == null) continue;
      do {
        final square = state[current!];
        if (square case OccupiedSquare(:var piece)) {
          if (piece.team != team) {
            positions.add(current); // Allow capture
          }
          break; // Stop at the first occupied square
        }
        positions.add(current);
        current = current.next(direction);
      } while (current != null && _shouldIteratePositions);
    }
    return positions;
  }

  Square operator >(Position position) => Square(position, this);

  @override
  String toString() => symbol.name;
}

enum Queen with Piece implements SlidingPiece {
  white._(Team.white),
  black._(Team.black);

  const Queen._(this.team);

  factory Queen(Team team) => switch (team) {
    Team.white => Queen.white,
    Team.black => Queen.black,
  };

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.queen;

  static const _directions = Direction.orthogonal;

  @override
  List<Direction> get _validDirections => _directions;

  @override
  int get value => PieceValue.queen.points;
}

enum Rook with Piece implements SlidingPiece {
  white._(Team.white),
  black._(Team.black);

  const Rook._(this.team);

  factory Rook(Team team) => switch (team) {
    Team.white => Rook.white,
    Team.black => Rook.black,
  };

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.rook;

  static const _directions = Direction.cross;

  @override
  List<Direction> get _validDirections => _directions;

  @override
  int get value => PieceValue.rook.points;
}
