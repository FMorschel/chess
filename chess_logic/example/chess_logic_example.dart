import 'package:chess_logic/chess_logic.dart';

/// Demonstrates the Scholar's Mate - the fastest possible checkmate in chess.
///
/// Scholar's Mate is a four-move checkmate pattern where White targets
/// the weak f7 square in Black's position. This example shows how to use
/// the chess_logic library to create and execute moves programmatically.
void main() {
  print('🔥 Scholar\'s Mate Example 🔥\n');

  // Initialize a new chess game with standard teams
  final game = GameController([Team.white, Team.black]);

  print('Initial board position:');
  print(game.state.toString(complete: true));

  final moves = <Move>[
    PawnInitialMove(
      from: Position(File.e, Rank.two),
      to: Position(File.e, Rank.four),
      moving: Pawn.white,
    ),
    PawnInitialMove(
      from: Position(File.e, Rank.seven),
      to: Position(File.e, Rank.five),
      moving: Pawn.black,
    ),
    BishopMove(
      from: Position(File.f, Rank.one),
      to: Position(File.c, Rank.four),
      moving: Bishop.white,
    ),
    KnightMove(
      from: Position(File.b, Rank.eight),
      to: Position(File.c, Rank.six),
      moving: Knight.black,
    ),
    QueenMove(
      from: Position(File.d, Rank.one),
      to: Position(File.h, Rank.five),
      moving: Queen.white,
    ),
    KnightMove(
      from: Position(File.g, Rank.eight),
      to: Position(File.f, Rank.six),
      moving: Knight.black,
    ),
    QueenCaptureMove(
      from: Position(File.h, Rank.five),
      to: Position(File.f, Rank.seven),
      moving: Queen.white,
      captured: Pawn.black,
    ),
  ];

  for (final move in moves) {
    print('\nExecuting move: ${move.toString()}');
    game.move(move);
    print(game.state.toString(complete: true));
  }

  print(game.gameState.name);

  print('\n📚 What is Scholar\'s Mate?');
  print(
    'Scholar\'s Mate is a chess opening trap that leads to checkmate in 4 '
    'moves.',
  );
  print('It targets the weak f7 square in Black\'s starting position.');
  print(
    'While effective against beginners, experienced players can easily defend '
    'against it.',
  );
  print('\n🛡️  How to defend:');
  print('- Develop knights before bishops');
  print('- Don\'t move the same piece twice in the opening');
  print('- Castle early to protect your king');
  print('- Be aware of early queen attacks');
}
