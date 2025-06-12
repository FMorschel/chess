import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';

/// Represents a capture in chess, encapsulating the move that resulted in the
/// capture and providing access to the relevant information.
extension type Capture<P extends Piece, C extends Piece>(
  CaptureMove<P, C> _move
) {
  /// The captured piece.
  C get piece => _move.captured;

  /// The piece that performed the capture.
  P get captor => _move.moving;

  /// The position where the capture occurred.
  Position get position => _move.to;

  /// The team that performed the capture.
  Team get team => _move.team;

  /// {@macro piece_value}
  int get value => piece.value;

  String toAlgebraic() => _move.toAlgebraic();
}
