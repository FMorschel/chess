import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/controller/direction.dart';
import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/position/rank.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/square/piece_value.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

sealed class PromotionPiece extends Piece {
  const PromotionPiece(super.team);
}

final class Bishop extends PromotionPiece {
  const Bishop(super.team);

  @override
  PieceSymbol get symbol => PieceSymbol.bishop;

  @override
  int get value => PieceValue.bishop.points;

  static const _directions = Direction.diagonal;

  @override
  List<Direction> get _validDirections => _directions;
}

final class King extends Piece {
  const King(super.team);

  @override
  PieceSymbol get symbol => PieceSymbol.king;

  static const _directions = Direction.all;

  @override
  List<Direction> get _validDirections => _directions;

  @override
  bool get _shouldIteratePositions => false;

  Position get _startPosition => switch (team) {
    Team.white => Position(File.e, Rank.one),
    Team.black => Position(File.e, Rank.eight),
  };

  List<(Position, Direction)> get rookPositions => switch (team) {
    Team.white => [
      (Position(File.a, Rank.one), Direction.left),
      (Position(File.h, Rank.one), Direction.right),
    ],
    Team.black => [
      (Position(File.a, Rank.eight), Direction.left),
      (Position(File.h, Rank.eight), Direction.right),
    ],
  };

  @override
  List<Position> validPositions(BoardState state, Position position) {
    final list = super.validPositions(state, position);
    if (position == _startPosition) {
      for (final (position, direction) in rookPositions) {
        final rookSquare = state[position];
        if (rookSquare.isEmpty ||
            rookSquare.piece!.symbol != PieceSymbol.rook) {
          continue;
        }

        var next = position.next(direction);
        if (next == null || state[next].isOccupied) {
          continue;
        }

        if (next.next(direction) case final castelling?) {
          if (state[castelling].isEmpty) {
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

final class Knight extends PromotionPiece {
  const Knight(super.team);

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

final class Pawn extends Piece {
  const Pawn(super.team);

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
  List<Position> validPositions(BoardState state, Position position) {
    final list = super.validPositions(state, position);
    if (position.next(forward) case final nextPosition?) {
      final nextSquare = state[nextPosition];
      if (nextSquare.isEmpty) {
        list.add(nextPosition);
      }
      if (nextPosition.next(forward) case final initial?
          when position.rank != initialRank) {
        final initialSquare = state[initial];
        if (initialSquare.isEmpty) {
          list.add(initial);
        }
      }
    }

    return list;
  }

  @override
  int get value => PieceValue.pawn.points;
}

sealed class Piece extends Equatable {
  const Piece(this.team);

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

  static final _importRegex = RegExp('^(w+|b+) - ([KQRBNP])\$');

  final Team team;

  PieceSymbol get symbol;

  /// {@macro piece_value}
  int get value;

  String get export => '${team.name} - ${symbol.lexeme}';

  String toAlgebraic() => this is Pawn ? '' : symbol.lexeme;

  List<Direction> get _validDirections;
  bool get _shouldIteratePositions => true;

  @override
  List<Object?> get props => [symbol, team];

  @mustCallSuper
  List<Position> validPositions(BoardState state, Position position) {
    final positions = <Position>[];
    for (final direction in _validDirections) {
      Position? current = position.next(direction);
      if (current == null) continue;
      do {
        final square = state[current!];
        if (square.isOccupied) {
          // Allow capture
          if (square.piece!.team == team) {
            break; // Stop at the first occupied square
          }
        }
        positions.add(position);
        current = current.next(direction);
      } while (current != null && _shouldIteratePositions);
    }
    return positions;
  }

  Square operator >(Position position) => Square(position, this);

  @override
  String toString() => symbol.name;
}

final class Queen extends PromotionPiece {
  const Queen(super.team);

  @override
  PieceSymbol get symbol => PieceSymbol.queen;

  static const _directions = Direction.all;

  @override
  List<Direction> get _validDirections => _directions;

  @override
  int get value => PieceValue.queen.points;
}

final class Rook extends PromotionPiece {
  const Rook(super.team);

  @override
  PieceSymbol get symbol => PieceSymbol.rook;

  static const _directions = Direction.cross;

  @override
  List<Direction> get _validDirections => _directions;

  @override
  int get value => PieceValue.rook.points;
}
