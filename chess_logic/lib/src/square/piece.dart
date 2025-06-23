import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../controller/board_state.dart';
import '../move/move.dart';
import '../position/direction.dart';
import '../position/position.dart';
import '../position/rank.dart';
import '../team/team.dart';
import 'piece_symbol.dart';
import 'piece_value.dart';
import 'square.dart';

/// Base class for pieces that can be promoted to during pawn promotion.
sealed class PromotionPiece extends Piece {}

/// Base class for pieces that slide across the board (Bishop, Rook, Queen).
sealed class SlidingPiece implements PromotionPiece {}

/// Represents a bishop piece that moves diagonally.
final class Bishop extends Piece implements SlidingPiece {
  const Bishop(this.team);

  static const white = Bishop(Team.white);
  static const black = Bishop(Team.black);
  static const _directions = Direction.diagonal;

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.bishop;

  @override
  int get value => PieceValue.bishop.points;

  @override
  List<Direction> get _validDirections => _directions;
}

/// Represents the king piece that moves one square in any direction.
final class King extends Piece {
  const King(this.team);

  static const white = King(Team.white);
  static const black = King(Team.black);
  static const _directions = Direction.orthogonal;

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.king;

  @override
  int get value => PieceValue.king.points;

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
}

/// Represents a knight piece that moves in an L-shape pattern.
final class Knight extends Piece implements PromotionPiece {
  const Knight(this.team);

  static const white = Knight(Team.white);
  static const black = Knight(Team.black);
  static const _directions = Direction.knight;

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.knight;

  @override
  int get value => PieceValue.knight.points;

  @override
  List<Direction> get _validDirections => _directions;

  @override
  bool get _shouldIteratePositions => false;
}

/// Represents a pawn piece with special movement and promotion rules.
final class Pawn extends Piece {
  const Pawn(this.team);

  static const white = Pawn(Team.white);
  static const black = Pawn(Team.black);

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.pawn;

  @override
  int get value => PieceValue.pawn.points;

  @override
  List<Direction> get _validDirections => captureDirections;

  @override
  bool get _shouldIteratePositions => false;

  Direction get forward => switch (team) {
    Team.white => Direction.up,
    Team.black => Direction.down,
  };

  List<Direction> get captureDirections => switch (team) {
    Team.white => [Direction.upLeft, Direction.upRight],
    Team.black => [Direction.downLeft, Direction.downRight],
  };

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
          :final to,
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
}

/// Base mixin class for all chess pieces.
abstract class Piece with EquatableMixin {
  const Piece();

  factory Piece.import(String string) {
    if (string.isEmpty) {
      throw ArgumentError.value(
        string,
        'string',
        'Piece import string cannot be empty',
      );
    }

    final match = _importRegex.firstMatch(string);
    if (match == null) {
      throw ArgumentError.value(
        string,
        'string',
        'Invalid piece import format: "$string". Expected format: "Team - '
            'PieceSymbol" (e.g., "White - K")',
      );
    }

    final teamName = match.group(1)!;
    final symbolLexeme = match.group(2)!;

    try {
      final team = Team(teamName);
      final symbol = PieceSymbol.fromLexeme(symbolLexeme);
      return Piece.fromSymbol(symbol, team);
    } catch (e) {
      throw ArgumentError.value(
        string,
        'string',
        'Failed to create piece from "$string": $e',
      );
    }
  }

  factory Piece.fromSymbol(PieceSymbol symbol, Team team) {
    return switch (symbol) {
      PieceSymbol.king => team.king,
      PieceSymbol.queen => team.queen,
      PieceSymbol.rook => team.rook,
      PieceSymbol.bishop => team.bishop,
      PieceSymbol.knight => team.knight,
      PieceSymbol.pawn => team.pawn,
    };
  }

  static final _importRegex = RegExp('^(White|Black) - ([KQRBNP])\$');
  String toAlgebraic() => this is Pawn ? '' : symbol.lexeme;

  @mustCallSuper
  List<Position> validPositions(BoardState state, Position position) {
    final positions = <Position>[];
    for (final direction in _validDirections) {
      Position? current = position.next(direction);
      if (current == null) continue;
      do {
        final square = state[current!];
        if (square case OccupiedSquare(:final piece)) {
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

  @override
  String toString() => symbol.name;

  Square operator >(Position position) => Square(position, this);

  Team get team;

  PieceSymbol get symbol;

  /// {@macro piece_value}
  int get value;

  String get export => '${team.name} - ${symbol.lexeme}';

  List<Direction> get _validDirections;

  bool get _shouldIteratePositions => true;

  @override
  List<Object?> get props => [team, symbol];
}

/// Represents a queen piece that combines rook and bishop movement.
final class Queen extends Piece implements SlidingPiece {
  const Queen(this.team);

  static const white = Queen(Team.white);
  static const black = Queen(Team.black);
  static const _directions = Direction.orthogonal;

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.queen;

  @override
  int get value => PieceValue.queen.points;

  @override
  List<Direction> get _validDirections => _directions;
}

/// Represents a rook piece that moves horizontally and vertically.
final class Rook extends Piece implements SlidingPiece {
  const Rook(this.team);

  static const white = Rook(Team.white);
  static const black = Rook(Team.black);
  static const _directions = Direction.cross;

  @override
  final Team team;

  @override
  PieceSymbol get symbol => PieceSymbol.rook;

  @override
  int get value => PieceValue.rook.points;

  @override
  List<Direction> get _validDirections => _directions;
}
