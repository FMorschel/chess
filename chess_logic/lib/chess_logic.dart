/// A comprehensive chess logic library for Dart and Flutter.
///
/// This library provides all the necessary classes and utilities to implement
/// chess game logic, including move validation, game state management,
/// and algebraic notation support.
library;

// Core game controller
export 'src/controller/game_controller.dart';
export 'src/controller/board_state.dart';

// Moves and movement
export 'src/move/move.dart';
export 'src/move/check.dart';

// Board representation
export 'src/position/position.dart';
export 'src/position/file.dart';
export 'src/position/rank.dart';
export 'src/position/direction.dart';

// Pieces and squares
export 'src/square/piece.dart';
export 'src/square/piece_symbol.dart';
export 'src/square/piece_value.dart';
export 'src/square/square.dart';

// Teams
export 'src/team/team.dart';

// Utilities
export 'src/utility/board_printer.dart';
export 'src/utility/extensions.dart';
