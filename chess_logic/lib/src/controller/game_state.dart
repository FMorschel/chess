/// Represents the current state of the game
enum GameState {
  /// Game is in progress, waiting for a move
  inProgress,

  /// Game ends with a winner
  teamWin,

  /// Game ends in stalemate
  stalemate,

  /// Game ends in draw (by agreement, repetition, etc.)
  draw,

  /// Game is paused
  paused,
}
