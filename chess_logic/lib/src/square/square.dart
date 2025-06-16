import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:equatable/equatable.dart';

/// Represents a square on the chessboard.
/// Holds a Position and optionally a Piece.
sealed class Square<P extends Piece> with EquatableMixin {
  final Position position;
  final P? piece;

  const Square._(this.position, [this.piece]);

  factory Square(Position position, [P? piece]) {
    if (piece == null) {
      return EmptySquare(position);
    }
    return OccupiedSquare(position, piece);
  }

  /// Returns true if there is a piece on this square.
  bool get isOccupied => piece != null;

  /// Returns true if this square is empty.
  bool get isEmpty => piece == null;

  bool get lightSquare =>
      (position.file.index + position.rank.index).isEven;

  OccupiedSquare<O> replacePiece<O extends Piece>(O piece) =>
      OccupiedSquare(position, piece);
  EmptySquare removePiece() => EmptySquare(position);

  @override
  String toString() => '$position, ${piece?.symbol.lexeme ?? 'empty'}';

  @override
  List<Object?> get props => [position, piece];
}

final class EmptySquare<P extends Piece> extends Square<P> {
  const EmptySquare(super.position) : super._();
}

final class OccupiedSquare<P extends Piece> extends Square<P> {
  const OccupiedSquare(super.position, P super.piece) : super._();

  @override
  P get piece => super.piece!;
}
