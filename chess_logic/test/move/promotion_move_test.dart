import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('PromotionMove', () {
    final whitePawn = Pawn(Team.white);
    final from = Position.fromAlgebraic('e7');
    final to = Position.fromAlgebraic('e8');

    test('stores all fields correctly', () {
      final move = PromotionMove(
        from: from,
        to: to,
        moving: whitePawn,
        promotion: PieceSymbol.queen,
      );

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whitePawn));
      expect(move.promotion, equals(PieceSymbol.queen));
    });

    group('invalid', () {
      test('promotion piece', () {
        expect(
          () => PromotionMove(
            from: from,
            to: to,
            moving: whitePawn,
            promotion: PieceSymbol.pawn,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('from position is not the correct pawn position', () {
        expect(
          () => PromotionMove(
            from: Position.fromAlgebraic('e6'),
            to: to,
            moving: whitePawn,
            promotion: PieceSymbol.queen,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('ambiguous movement rank', () {
        expect(
          () => PromotionMove(
            from: from,
            to: to,
            moving: whitePawn,
            promotion: PieceSymbol.queen,
            ambiguous: AmbiguousMovementType.rank,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });
    group('toAlgebraic()', () {
      for (final piece in PieceSymbol.promotionSymbols) {
        test('returns correct notation for $piece', () {
          final move = PromotionMove(
            from: from,
            to: to,
            moving: whitePawn,
            promotion: piece,
          );
          expect(move.toAlgebraic(), equals('e8=${piece.lexeme}'));
        });
      }
      test('returns correct notation', () {
        final move = PromotionMove(
          from: from,
          to: to,
          moving: whitePawn,
          promotion: PieceSymbol.queen,
        );
        expect(move.toAlgebraic(), equals('e8=Q'));
      });

      test('returns correct notation with check', () {
        final move = PromotionMove(
          from: from,
          to: to,
          moving: whitePawn,
          promotion: PieceSymbol.knight,
          check: Check.check,
        );
        expect(move.toAlgebraic(), equals('e8=N+'));
      });

      test('returns correct notation with checkmate', () {
        final move = PromotionMove(
          from: from,
          to: to,
          moving: whitePawn,
          promotion: PieceSymbol.bishop,
          check: Check.checkmate,
        );
        expect(move.toAlgebraic(), equals('e8=B#'));
      });

      test('returns correct notation for ambiguous movement', () {
        final move = PromotionMove(
          from: from,
          to: to,
          moving: whitePawn,
          promotion: PieceSymbol.bishop,
          ambiguous: AmbiguousMovementType.file,
        );
        expect(move.toAlgebraic(), equals('ee8=B'));
      });
    });
  });

  group('PromotionCaptureMove', () {
    final whitePawn = Pawn(Team.white);
    final from = Position.fromAlgebraic('e7');
    final to = Position.fromAlgebraic('d8');
    final captured = Rook(Team.black);

    test('stores all fields correctly', () {
      final move = PromotionCaptureMove(
        from: from,
        to: to,
        moving: whitePawn,
        captured: captured,
        promotion: PieceSymbol.queen,
      );

      expect(move.from, equals(from));
      expect(move.to, equals(to));
      expect(move.moving, equals(whitePawn));
      expect(move.captured, equals(captured));
      expect(move.promotion, equals(PieceSymbol.queen));
    });

    test('throws assertion error for invalid move', () {
      expect(
        () => PromotionCaptureMove(
          from: from,
          to: Position.fromAlgebraic('e8'),
          moving: whitePawn,
          captured: captured,
          promotion: PieceSymbol.queen,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    group('invalid', () {
      test('promotion piece', () {
        expect(
          () => PromotionCaptureMove(
            from: from,
            to: to,
            moving: whitePawn,
            captured: captured,
            promotion: PieceSymbol.pawn,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('toAlgebraic()', () {
      for (final piece in PieceSymbol.promotionSymbols) {
        test('returns correct notation for $piece capture', () {
          final move = PromotionCaptureMove(
            from: from,
            to: to,
            moving: whitePawn,
            captured: captured,
            promotion: piece,
          );
          expect(move.toAlgebraic(), equals('exd8=${piece.lexeme}'));
        });
      }

      test('returns correct notation', () {
        final move = PromotionCaptureMove(
          from: from,
          to: to,
          moving: whitePawn,
          captured: captured,
          promotion: PieceSymbol.queen,
        );

        expect(move.toAlgebraic(), equals('exd8=Q'));
      });

      test('returns correct notation with check', () {
        final move = PromotionCaptureMove(
          from: from,
          to: to,
          moving: whitePawn,
          captured: captured,
          promotion: PieceSymbol.knight,
          check: Check.check,
        );

        expect(move.toAlgebraic(), equals('exd8=N+'));
      });

      test('returns correct notation with checkmate', () {
        final move = PromotionCaptureMove(
          from: from,
          to: to,
          moving: whitePawn,
          captured: captured,
          promotion: PieceSymbol.bishop,
          check: Check.checkmate,
        );

        expect(move.toAlgebraic(), equals('exd8=B#'));
      });

      test('returns correct notation for ambiguous movement by file', () {
        final move = PromotionCaptureMove(
          from: from,
          to: to,
          moving: whitePawn,
          captured: captured,
          promotion: PieceSymbol.queen,
        );

        expect(move.toAlgebraic(), equals('exd8=Q'));
      });
    });
  });
}
