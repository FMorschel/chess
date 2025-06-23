import '../move/move.dart';
import '../position/position.dart';
import '../square/piece.dart';
import '../team/team.dart';

/// Represents a capture in chess, encapsulating the move that resulted in the
/// capture and providing access to the relevant information.
///
/// Wraps a [CaptureMove] to provide convenient access to capture-specific
/// properties like the captured piece, capturing piece, and capture position.
extension type Capture<P extends Piece, C extends Piece>(
  CaptureMove<P, C> _move
) {
  /// The piece that was captured in this move.
  C get piece => _move.captured;

  /// The piece that performed the capture.
  P get captor => _move.moving;

  /// The position where the capture occurred.
  Position get position => _move.to;

  /// The team that performed the capture.
  Team get team => _move.team;

  /// {@macro piece_value}
  int get value => piece.value;

  /// Converts this capture to algebraic notation.
  String toAlgebraic() => _move.toAlgebraic();
}
