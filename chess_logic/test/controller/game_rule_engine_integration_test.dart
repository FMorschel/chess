import 'package:chess_logic/src/controller/game_controller.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('GameController with GameRuleEngine Integration', () {
    late List<Team> teams;

    setUp(() {
      teams = [Team.white, Team.black];
    });

    test('should use GameRuleEngine for insufficient material detection', () {
      // Create a game with only kings - insufficient material
      final controller = GameController.custom(teams, {
        Position.e1: King.white,
        Position.e8: King.black,
      });

      // The rule engine should detect insufficient material
      expect(
        controller.ruleEngine.hasInsufficientMaterial(controller.state),
        isTrue,
      );
    });

    test('should use GameRuleEngine for fifty-move rule detection', () {
      final controller = GameController(teams);

      // Test the fifty-move rule through the rule engine
      expect(controller.ruleEngine.isFiftyMoveRule(99, teams), isFalse);
      expect(controller.ruleEngine.isFiftyMoveRule(100, teams), isTrue);
    });

    test('should expose ruleEngine for external validation', () {
      final controller = GameController(teams);

      // Should be able to access the rule engine
      expect(controller.ruleEngine, isNotNull);

      // Test en passant validation
      const capturingPawn = Pawn.white;
      const capturePosition = Position.d6;
      final lastMove = PawnMove.initial(
        pawn: Pawn.black,
        from: Position.d7,
        to: Position.d5,
      );
      final boardState = controller.state;

      // Should be able to validate en passant through the exposed rule engine
      expect(
        () => controller.ruleEngine.isEnPassantLegal(
          capturingPawn,
          capturePosition,
          lastMove,
          boardState,
        ),
        returnsNormally,
      );
    });

    test('should validate pawn promotion requirements', () {
      final controller = GameController(teams);

      // Test promotion validation
      expect(
        controller.ruleEngine.isPawnPromotionRequired(Pawn.white, Position.e8),
        isTrue,
      );
      expect(
        controller.ruleEngine.isPawnPromotionRequired(Pawn.black, Position.e1),
        isTrue,
      );
      expect(
        controller.ruleEngine.isPawnPromotionRequired(Pawn.white, Position.e7),
        isFalse,
      );

      // Test promotion piece validation
      expect(
        controller.ruleEngine.isPromotionPieceLegal(Queen.white, Team.white),
        isTrue,
      );
      expect(
        controller.ruleEngine.isPromotionPieceLegal(King.white, Team.white),
        isFalse,
      );
    });

    test('should validate checkmate and stalemate conditions', () {
      final controller = GameController(teams);

      // Test with no moves available and not in check (stalemate)
      expect(controller.ruleEngine.isStalemate([], isInCheck: false), isTrue);

      // Test with no moves available and in check (checkmate)
      expect(controller.ruleEngine.isCheckmate([], isInCheck: true), isTrue);

      // Test with moves available
      final moves = [
        Move.create(from: Position.e2, to: Position.e3, moving: Pawn.white),
      ];
      expect(
        controller.ruleEngine.isStalemate(moves, isInCheck: false),
        isFalse,
      );
      expect(
        controller.ruleEngine.isCheckmate(moves, isInCheck: true),
        isFalse,
      );
    });

    test('should validate castling rules', () {
      final controller = GameController.custom(teams, {
        Position.e1: King.white,
        Position.h1: Rook.white,
      });

      // Mock function for checking if square is attacked
      bool isSquareAttacked(Position position, Team byTeam) => false;

      // Test castling validation
      expect(
        controller.ruleEngine.isCastlingLegal(
          King.white,
          Rook.white,
          Position.e1,
          Position.g1,
          Position.h1,
          controller.state,
          controller.history,
          isSquareAttacked,
        ),
        isTrue,
      );

      // Test with king and rook on different teams
      expect(
        controller.ruleEngine.isCastlingLegal(
          King.white,
          Rook.black,
          Position.e1,
          Position.g1,
          Position.h1,
          controller.state,
          controller.history,
          isSquareAttacked,
        ),
        isFalse,
      );
    });
  });
}
