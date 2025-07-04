import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:test/test.dart';

void main() {
  group('CaptureMove.copyWith()', () {
    group('Basic capture moves', () {
      group('PawnCaptureMove', () {
        test('should modify check parameter', () {
          final original = PawnCaptureMove<Rook>(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn.white,
            captured: Rook.black,
            check: Check.none,
          );

          final modified = original.copyWith(check: Check.check);

          expect(modified.from, equals(original.from));
          expect(modified.to, equals(original.to));
          expect(modified.moving, equals(original.moving));
          expect(modified.captured, equals(original.captured));
          expect(modified.check, equals(Check.check));
        });

        test('should preserve original values when no parameters provided', () {
          final original = PawnCaptureMove<Bishop>(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn.white,
            captured: Bishop.black,
            check: Check.checkmate,
          );

          final copy = original.copyWith();

          expect(copy.from, equals(original.from));
          expect(copy.to, equals(original.to));
          expect(copy.moving, equals(original.moving));
          expect(copy.captured, equals(original.captured));
          expect(copy.check, equals(original.check));
        });

        test('should preserve original when null parameters provided', () {
          final original = PawnCaptureMove<Knight>(
            from: Position.a7,
            to: Position.b8,
            moving: Pawn.white,
            captured: Knight.black,
            check: Check.check,
          );

          final copy = original.copyWith(check: null);

          expect(copy.from, equals(original.from));
          expect(copy.to, equals(original.to));
          expect(copy.moving, equals(original.moving));
          expect(copy.captured, equals(original.captured));
          expect(copy.check, equals(original.check));
        });

        test('should create different instances (immutability)', () {
          final original = PawnCaptureMove<Pawn>(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn.white,
            captured: Pawn.black,
          );

          final copy = original.copyWith();

          expect(identical(original, copy), isFalse);
          expect(original == copy, isTrue); // Equal but not identical
        });

        test('should modify only check parameter', () {
          final original = PawnCaptureMove<Rook>(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn.white,
            captured: Rook.black,
            check: Check.none,
          );

          final modified = original.copyWith(check: Check.checkmate);

          expect(modified.from, equals(original.from));
          expect(modified.to, equals(original.to));
          expect(modified.moving, equals(original.moving));
          expect(modified.captured, equals(original.captured));
          expect(modified.check, equals(Check.checkmate));
        });
      });

      group('QueenCaptureMove', () {
        test('should modify check and ambiguous parameters', () {
          final original = QueenCaptureMove<Bishop>(
            from: Position.d1,
            to: Position.h5,
            moving: Queen.white,
            captured: Bishop.black,
            check: Check.none,
            ambiguous: AmbiguousMovementType.file,
          );

          final modified = original.copyWith(
            check: Check.check,
            ambiguous: AmbiguousMovementType.rank,
          );

          expect(modified.from, equals(original.from));
          expect(modified.to, equals(original.to));
          expect(modified.moving, equals(original.moving));
          expect(modified.captured, equals(original.captured));
          expect(modified.check, equals(Check.check));
          expect(modified.ambiguous, equals(AmbiguousMovementType.rank));
        });

        test('should handle ambiguous movement modification', () {
          final original = QueenCaptureMove<Knight>(
            from: Position.d1,
            to: Position.d4,
            moving: Queen.white,
            captured: Knight.black,
            ambiguous: AmbiguousMovementType.file,
          );

          final modified = original.copyWith(
            ambiguous: AmbiguousMovementType.both,
          );

          expect(modified.ambiguous, equals(AmbiguousMovementType.both));
          expect(modified.from, equals(original.from));
          expect(modified.to, equals(original.to));
          expect(modified.moving, equals(original.moving));
          expect(modified.captured, equals(original.captured));
          expect(modified.check, equals(original.check));
        });
      });

      group('RookCaptureMove', () {
        test('should modify check and ambiguous parameters', () {
          final original = RookCaptureMove<Pawn>(
            from: Position.a1,
            to: Position.a8,
            moving: Rook.black,
            captured: Pawn.white,
            check: Check.none,
          );

          final modified = original.copyWith(
            check: Check.checkmate,
            ambiguous: AmbiguousMovementType.file,
          );

          expect(modified.from, equals(original.from));
          expect(modified.to, equals(original.to));
          expect(modified.moving, equals(original.moving));
          expect(modified.captured, equals(original.captured));
          expect(modified.check, equals(Check.checkmate));
          expect(modified.ambiguous, equals(AmbiguousMovementType.file));
        });
      });

      group('BishopCaptureMove', () {
        test('should modify check and ambiguous parameters', () {
          final original = BishopCaptureMove<Queen>(
            from: Position.c1,
            to: Position.f4,
            moving: Bishop.white,
            captured: Queen.black,
            check: Check.check,
          );

          final modified = original.copyWith(
            check: Check.none,
            ambiguous: AmbiguousMovementType.rank,
          );

          expect(modified.from, equals(original.from));
          expect(modified.to, equals(original.to));
          expect(modified.moving, equals(original.moving));
          expect(modified.captured, equals(original.captured));
          expect(modified.check, equals(Check.none));
          expect(modified.ambiguous, equals(AmbiguousMovementType.rank));
        });
      });

      group('KnightCaptureMove', () {
        test('should modify check and ambiguous parameters', () {
          final original = KnightCaptureMove<Pawn>(
            from: Position.b1,
            to: Position.c3,
            moving: Knight.black,
            captured: Pawn.white,
            check: Check.none,
          );

          final modified = original.copyWith(
            check: Check.check,
            ambiguous: AmbiguousMovementType.both,
          );

          expect(modified.from, equals(original.from));
          expect(modified.to, equals(original.to));
          expect(modified.moving, equals(original.moving));
          expect(modified.captured, equals(original.captured));
          expect(modified.check, equals(Check.check));
          expect(modified.ambiguous, equals(AmbiguousMovementType.both));
        });
      });

      group('KingCaptureMove', () {
        test(
          'should modify only check parameter (ambiguous not supported)',
          () {
            final original = KingCaptureMove<Pawn>(
              from: Position.e1,
              to: Position.e2,
              moving: King.white,
              captured: Pawn.black,
              check: Check.none,
            );

            final modified = original.copyWith(check: Check.check);

            expect(modified.from, equals(original.from));
            expect(modified.to, equals(original.to));
            expect(modified.moving, equals(original.moving));
            expect(modified.captured, equals(original.captured));
            expect(modified.check, equals(Check.check));
            // King moves don't use ambiguous
            expect(modified.ambiguous, AmbiguousMovementType.none);
          },
        );
      });
    });

    group('Special capture moves', () {
      group('EnPassantMove', () {
        test('should modify check parameter', () {
          final original = EnPassantMove(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn.white,
            captured: Pawn.black,
            check: Check.none,
          );

          final modified = original.copyWith(check: Check.check);

          expect(modified.from, equals(original.from));
          expect(modified.to, equals(original.to));
          expect(modified.moving, equals(original.moving));
          expect(modified.captured, equals(original.captured));
          expect(modified.check, equals(Check.check));
          expect(modified, isA<EnPassantMove>());
        });

        test('should preserve ambiguous movement type (always file)', () {
          final original = EnPassantMove(
            from: Position.e5,
            to: Position.d6,
            moving: Pawn.white,
            captured: Pawn.black,
          );

          final modified = original.copyWith(check: Check.check);

          expect(modified.ambiguous, equals(AmbiguousMovementType.file));
          expect(original.ambiguous, equals(AmbiguousMovementType.file));
        });
      });

      group('PromotionCaptureMove', () {
        test('should modify check parameter and preserve promotion', () {
          final original = PromotionCaptureMove<Rook>(
            from: Position.e7,
            to: Position.d8,
            moving: Pawn.white,
            captured: Rook.black,
            promotion: PieceSymbol.queen,
            check: Check.none,
          );

          final modified = original.copyWith(check: Check.checkmate);

          expect(modified.from, equals(original.from));
          expect(modified.to, equals(original.to));
          expect(modified.moving, equals(original.moving));
          expect(modified.captured, equals(original.captured));
          expect(modified.promotion, equals(PieceSymbol.queen));
          expect(modified.check, equals(Check.checkmate));
          expect(modified, isA<PromotionCaptureMove<Rook>>());
        });

        test('should preserve promotion when null check provided', () {
          final original = PromotionCaptureMove<Knight>(
            from: Position.e7,
            to: Position.d8,
            moving: Pawn.white,
            captured: Knight.black,
            promotion: PieceSymbol.bishop,
          );

          final modified = original.copyWith(check: null);

          expect(modified.promotion, equals(PieceSymbol.bishop));
          expect(modified.check, equals(original.check));
        });
      });
    });

    group('Parameter validation', () {
      test('should handle all check types', () {
        final checkTypes = [Check.none, Check.check, Check.checkmate];

        for (final check in checkTypes) {
          final original = RookCaptureMove<Bishop>(
            from: Position.a1,
            to: Position.a8,
            moving: Rook.white,
            captured: Bishop.black,
          );

          final modified = original.copyWith(check: check);

          expect(modified.check, equals(check));
        }
      });

      test('should handle all ambiguous movement types', () {
        for (final ambiguous in AmbiguousMovementType.values) {
          final original = QueenCaptureMove<Rook>(
            from: Position.d1,
            to: Position.d8,
            moving: Queen.white,
            captured: Rook.black,
          );

          final modified = original.copyWith(ambiguous: ambiguous);

          expect(modified.ambiguous, equals(ambiguous));
        }
      });

      test('should handle all promotion piece types', () {
        final promotionTypes = [
          PieceSymbol.queen,
          PieceSymbol.rook,
          PieceSymbol.bishop,
          PieceSymbol.knight,
        ];

        for (final promotion in promotionTypes) {
          final original = PromotionCaptureMove<Pawn>(
            from: Position.e7,
            to: Position.d8,
            moving: Pawn.white,
            captured: Pawn.black,
            promotion: promotion,
          );

          final modified = original.copyWith(check: Check.check);

          expect(modified.promotion, equals(promotion));
          expect(modified.check, equals(Check.check));
        }
      });
    });

    group('Complex modification scenarios', () {
      test('should handle multiple parameter modifications', () {
        final original = BishopCaptureMove<Queen>(
          from: Position.c1,
          to: Position.f4,
          moving: Bishop.white,
          captured: Queen.black,
          check: Check.none,
          ambiguous: AmbiguousMovementType.none,
        );

        final modified = original.copyWith(
          check: Check.checkmate,
          ambiguous: AmbiguousMovementType.both,
        );

        expect(modified.from, equals(original.from));
        expect(modified.to, equals(original.to));
        expect(modified.moving, equals(original.moving));
        expect(modified.captured, equals(original.captured));
        expect(modified.check, equals(Check.checkmate));
        expect(modified.ambiguous, equals(AmbiguousMovementType.both));
      });

      test('should chain copyWith calls correctly', () {
        final original = KnightCaptureMove<Rook>(
          from: Position.b1,
          to: Position.c3,
          moving: Knight.white,
          captured: Rook.black,
          check: Check.none,
        );

        final step1 = original.copyWith(check: Check.check);
        final step2 = step1.copyWith(ambiguous: AmbiguousMovementType.file);
        final finalResult = step2.copyWith(check: Check.checkmate);

        expect(finalResult.from, equals(original.from));
        expect(finalResult.to, equals(original.to));
        expect(finalResult.moving, equals(original.moving));
        expect(finalResult.captured, equals(original.captured));
        expect(finalResult.check, equals(Check.checkmate));
        expect(finalResult.ambiguous, equals(AmbiguousMovementType.file));
      });
    });

    group('Immutability verification', () {
      test('should not modify original instance', () {
        final original = PawnCaptureMove<Bishop>(
          from: Position.e5,
          to: Position.d6,
          moving: Pawn.white,
          captured: Bishop.black,
          check: Check.none,
        );

        final originalFrom = original.from;
        final originalTo = original.to;
        final originalMoving = original.moving;
        final originalCaptured = original.captured;
        final originalCheck = original.check;

        original.copyWith(check: Check.checkmate);

        expect(original.from, equals(originalFrom));
        expect(original.to, equals(originalTo));
        expect(original.moving, equals(originalMoving));
        expect(original.captured, equals(originalCaptured));
        expect(original.check, equals(originalCheck));
      });

      test('should create independent instances', () {
        final original = RookCaptureMove<Knight>(
          from: Position.a1,
          to: Position.a8,
          moving: Rook.white,
          captured: Knight.black,
          check: Check.check,
        );

        final copy1 = original.copyWith(check: Check.none);
        final copy2 = original.copyWith(check: Check.checkmate);

        expect(copy1.check, equals(Check.none));
        expect(copy2.check, equals(Check.checkmate));
        expect(original.check, equals(Check.check));
        expect(copy1.check != copy2.check, isTrue);
      });
    });

    group('Algebraic notation consistency', () {
      test('should maintain correct algebraic notation after copyWith', () {
        final original = QueenCaptureMove<Rook>(
          from: Position.d1,
          to: Position.d8,
          moving: Queen.white,
          captured: Rook.black,
          check: Check.none,
        );

        final withCheck = original.copyWith(check: Check.check);
        final withCheckmate = original.copyWith(check: Check.checkmate);
        final withAmbiguous = original.copyWith(
          ambiguous: AmbiguousMovementType.file,
        );

        expect(original.toAlgebraic(), equals('Qxd8'));
        expect(withCheck.toAlgebraic(), equals('Qxd8+'));
        expect(withCheckmate.toAlgebraic(), equals('Qxd8#'));
        expect(withAmbiguous.toAlgebraic(), equals('Qdxd8'));
      });

      test('should maintain promotion notation after copyWith', () {
        final original = PromotionCaptureMove<Bishop>(
          from: Position.e7,
          to: Position.d8,
          moving: Pawn.white,
          captured: Bishop.black,
          promotion: PieceSymbol.queen,
        );

        final withCheck = original.copyWith(check: Check.check);
        final withCheckmate = original.copyWith(check: Check.checkmate);

        expect(original.toAlgebraic(), equals('exd8=Q'));
        expect(withCheck.toAlgebraic(), equals('exd8=Q+'));
        expect(withCheckmate.toAlgebraic(), equals('exd8=Q#'));
      });
    });

    group('Edge cases', () {
      test('should handle copyWith with no parameters', () {
        final original = PawnCaptureMove<Queen>(
          from: Position.e5,
          to: Position.d6,
          moving: Pawn.white,
          captured: Queen.black,
          check: Check.check,
        );

        final copy = original.copyWith();

        expect(copy.from, equals(original.from));
        expect(copy.to, equals(original.to));
        expect(copy.moving, equals(original.moving));
        expect(copy.captured, equals(original.captured));
        expect(copy.check, equals(original.check));
        expect(identical(original, copy), isFalse);
        expect(original == copy, isTrue);
      });

      test('should handle copyWith with all null parameters', () {
        final original = QueenCaptureMove<Knight>(
          from: Position.d1,
          to: Position.h5,
          moving: Queen.white,
          captured: Knight.black,
          check: Check.check,
          ambiguous: AmbiguousMovementType.file,
        );

        final copy = original.copyWith(check: null, ambiguous: null);

        expect(copy.from, equals(original.from));
        expect(copy.to, equals(original.to));
        expect(copy.moving, equals(original.moving));
        expect(copy.captured, equals(original.captured));
        expect(copy.check, equals(original.check));
        expect(copy.ambiguous, equals(original.ambiguous));
      });
    });
  });
}
