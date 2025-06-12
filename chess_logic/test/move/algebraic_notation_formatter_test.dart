import 'package:chess_logic/src/move/algebraic_notation_formatter.dart';
import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('AlgebraicNotationFormatter', () {
    late AlgebraicNotationFormatter formatter;

    setUp(() {
      formatter = AlgebraicNotationFormatter();
    });
    test('should format regular move', () {
      final move = PawnInitialMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('e2'),
        to: Position.fromAlgebraic('e4'),
        check: Check.none,
      );
      expect(formatter.visit(move), 'e4');
    });

    test('should format regular capture move', () {
      final move = PawnCaptureMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('e4'),
        to: Position.fromAlgebraic('d5'),
        captured: Pawn(Team.black),
        check: Check.none,
      );
      expect(formatter.visit(move), 'exd5');
    });

    test('should format kingside castling', () {
      final move = KingsideCastling(
        from: Position.fromAlgebraic('e1'),
        to: Position.fromAlgebraic('g1'),
        moving: King(Team.white),
        rook: RookMove(
          from: Position.fromAlgebraic('h1'),
          to: Position.fromAlgebraic('f1'),
          moving: Rook(Team.white),
        ),
        check: Check.none,
      );
      expect(formatter.visit(move), 'O-O');
    });

    test('should format queenside castling', () {
      final move = QueensideCastling(
        from: Position.fromAlgebraic('e1'),
        to: Position.fromAlgebraic('c1'),
        moving: King(Team.white),
        rook: RookMove(
          from: Position.fromAlgebraic('a1'),
          to: Position.fromAlgebraic('d1'),
          moving: Rook(Team.white),
        ),
        check: Check.none,
      );
      expect(formatter.visit(move), 'O-O-O');
    });

    test('should format en passant move', () {
      final move = EnPassantMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('e5'),
        to: Position.fromAlgebraic('d6'),
        captured: Pawn(Team.black),
        check: Check.none,
      );
      expect(formatter.visit(move), 'exd6');
    });

    test('should format promotion move', () {
      final move = PromotionMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('e7'),
        to: Position.fromAlgebraic('e8'),
        promotion: PieceSymbol.queen,
        check: Check.none,
      );
      expect(formatter.visit(move), 'e8=Q');
    });

    test('should format promotion capture move', () {
      final move = PromotionCaptureMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('d7'),
        to: Position.fromAlgebraic('e8'),
        captured: Rook(Team.black),
        promotion: PieceSymbol.queen,
        check: Check.none,
      );
      expect(formatter.visit(move), 'dxe8=Q');
    });

    test('should format move with check', () {
      final move = QueenMove(
        moving: Queen(Team.white),
        from: Position.fromAlgebraic('d1'),
        to: Position.fromAlgebraic('h5'),
        check: Check.check,
      );
      expect(formatter.visit(move), 'Qh5+');
    });

    test('should format move with checkmate', () {
      final move = QueenMove(
        moving: Queen(Team.white),
        from: Position.fromAlgebraic('h5'),
        to: Position.fromAlgebraic('f7'),
        check: Check.checkmate,
      );
      expect(formatter.visit(move), 'Qf7#');
    });

    test('should format ambiguous move (file)', () {
      final move = RookMove(
        moving: Rook(Team.white),
        from: Position.fromAlgebraic('a1'),
        to: Position.fromAlgebraic('d1'),
        ambiguous: AmbiguousMovementType.file,
        check: Check.none,
      );
      expect(formatter.visit(move), 'Rad1');
    });

    test('should format ambiguous move (rank)', () {
      final move = RookMove(
        moving: Rook(Team.white),
        from: Position.fromAlgebraic('a1'),
        to: Position.fromAlgebraic('a4'),
        ambiguous: AmbiguousMovementType.rank,
        check: Check.none,
      );
      expect(formatter.visit(move), 'R1a4');
    });

    test('should format ambiguous move (both)', () {
      final move = QueenMove(
        moving: Queen(Team.white),
        from: Position.fromAlgebraic('a1'),
        to: Position.fromAlgebraic('d4'),
        ambiguous: AmbiguousMovementType.both,
        check: Check.none,
      );
      expect(formatter.visit(move), 'Qa1d4');
    });

    test('should format pawn move with check', () {
      final move = PawnMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('e6'),
        to: Position.fromAlgebraic('e7'),
        check: Check.check,
      );
      expect(formatter.visit(move), 'e7+');
    });

    test('should format pawn capture with checkmate', () {
      final move = PawnCaptureMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('f6'),
        to: Position.fromAlgebraic('g7'),
        captured: Pawn(Team.black),
        check: Check.checkmate,
      );
      expect(formatter.visit(move), 'fxg7#');
    });

    test('should format rook move with check', () {
      final move = RookMove(
        moving: Rook(Team.white),
        from: Position.fromAlgebraic('a1'),
        to: Position.fromAlgebraic('a8'),
        check: Check.check,
      );
      expect(formatter.visit(move), 'Ra8+');
    });

    test('should format rook capture with checkmate', () {
      final move = RookCaptureMove(
        moving: Rook(Team.white),
        from: Position.fromAlgebraic('h1'),
        to: Position.fromAlgebraic('h8'),
        captured: Queen(Team.black),
        check: Check.checkmate,
      );
      expect(formatter.visit(move), 'Rxh8#');
    });

    test('should format bishop move with check', () {
      final move = BishopMove(
        moving: Bishop(Team.white),
        from: Position.fromAlgebraic('c1'),
        to: Position.fromAlgebraic('h6'),
        check: Check.check,
      );
      expect(formatter.visit(move), 'Bh6+');
    });

    test('should format bishop capture with checkmate', () {
      final move = BishopCaptureMove(
        moving: Bishop(Team.white),
        from: Position.fromAlgebraic('f1'),
        to: Position.fromAlgebraic('b5'),
        captured: Knight(Team.black),
        check: Check.checkmate,
      );
      expect(formatter.visit(move), 'Bxb5#');
    });

    test('should format knight move with check', () {
      final move = KnightMove(
        moving: Knight(Team.white),
        from: Position.fromAlgebraic('g1'),
        to: Position.fromAlgebraic('f3'),
        check: Check.check,
      );
      expect(formatter.visit(move), 'Nf3+');
    });

    test('should format knight capture with checkmate', () {
      final move = KnightCaptureMove(
        moving: Knight(Team.white),
        from: Position.fromAlgebraic('c3'),
        to: Position.fromAlgebraic('d5'),
        captured: Bishop(Team.black),
        check: Check.checkmate,
      );
      expect(formatter.visit(move), 'Nxd5#');
    });

    test('should format king move with check', () {
      final move = KingMove(
        moving: King(Team.white),
        from: Position.fromAlgebraic('e1'),
        to: Position.fromAlgebraic('f1'),
        check: Check.check,
      );
      expect(formatter.visit(move), 'Kf1+');
    });

    test('should format king capture with checkmate', () {
      final move = KingCaptureMove(
        moving: King(Team.white),
        from: Position.fromAlgebraic('e6'),
        to: Position.fromAlgebraic('d7'),
        captured: Pawn(Team.black),
        check: Check.checkmate,
      );
      expect(formatter.visit(move), 'Kxd7#');
    });

    test('should format kingside castling with check', () {
      final move = KingsideCastling(
        from: Position.fromAlgebraic('e1'),
        to: Position.fromAlgebraic('g1'),
        moving: King(Team.white),
        rook: RookMove(
          from: Position.fromAlgebraic('h1'),
          to: Position.fromAlgebraic('f1'),
          moving: Rook(Team.white),
          check: Check.check,
        ),
        check: Check.check,
      );
      expect(formatter.visit(move), 'O-O+');
    });

    test('should format queenside castling with checkmate', () {
      final move = QueensideCastling(
        from: Position.fromAlgebraic('e8'),
        to: Position.fromAlgebraic('c8'),
        moving: King(Team.black),
        rook: RookMove(
          from: Position.fromAlgebraic('a8'),
          to: Position.fromAlgebraic('d8'),
          moving: Rook(Team.black),
          check: Check.checkmate,
        ),
        check: Check.checkmate,
      );
      expect(formatter.visit(move), 'O-O-O#');
    });

    test('should format en passant with check', () {
      final move = EnPassantMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('e5'),
        to: Position.fromAlgebraic('f6'),
        captured: Pawn(Team.black),
        check: Check.check,
      );
      expect(formatter.visit(move), 'exf6+');
    });

    test('should format promotion with check', () {
      final move = PromotionMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('a7'),
        to: Position.fromAlgebraic('a8'),
        promotion: PieceSymbol.knight,
        check: Check.check,
      );
      expect(formatter.visit(move), 'a8=N+');
    });

    test('should format promotion capture with checkmate', () {
      final move = PromotionCaptureMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('g7'),
        to: Position.fromAlgebraic('h8'),
        captured: Rook(Team.black),
        promotion: PieceSymbol.queen,
        check: Check.checkmate,
      );
      expect(formatter.visit(move), 'gxh8=Q#');
    });

    test('should format ambiguous rook move with check', () {
      final move = RookMove(
        moving: Rook(Team.white),
        from: Position.fromAlgebraic('a1'),
        to: Position.fromAlgebraic('a7'),
        ambiguous: AmbiguousMovementType.file,
        check: Check.check,
      );
      expect(formatter.visit(move), 'Raa7+');
    });

    test('should format ambiguous queen capture with checkmate', () {
      final move = QueenCaptureMove(
        moving: Queen(Team.white),
        from: Position.fromAlgebraic('d1'),
        to: Position.fromAlgebraic('d8'),
        captured: Queen(Team.black),
        ambiguous: AmbiguousMovementType.both,
        check: Check.checkmate,
      );
      expect(formatter.visit(move), 'Qd1xd8#');
    });

    // Additional comprehensive test coverage for missing scenarios
    test('should format pawn initial move with checkmate', () {
      final move = PawnInitialMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('e2'),
        to: Position.fromAlgebraic('e4'),
        check: Check.checkmate,
      );
      expect(formatter.visit(move), 'e4#');
    });

    test('should format pawn move with ambiguous file', () {
      final move = PawnMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('e6'),
        to: Position.fromAlgebraic('e7'),
        ambiguous: AmbiguousMovementType.file,
        check: Check.none,
      );
      expect(formatter.visit(move), 'ee7');
    });

    test('should format promotion with ambiguous file', () {
      final move = PromotionMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('e7'),
        to: Position.fromAlgebraic('e8'),
        promotion: PieceSymbol.rook,
        ambiguous: AmbiguousMovementType.file,
        check: Check.none,
      );
      expect(formatter.visit(move), 'ee8=R');
    });

    test('should format promotion capture with ambiguous file', () {
      final move = PromotionCaptureMove(
        moving: Pawn(Team.white),
        from: Position.fromAlgebraic('e7'),
        to: Position.fromAlgebraic('d8'),
        captured: Rook(Team.black),
        promotion: PieceSymbol.bishop,
        check: Check.none,
      );
      expect(formatter.visit(move), 'exd8=B');
    });

    test('should format different promotion pieces', () {
      final promotionPieces = [
        (PieceSymbol.rook, 'R'),
        (PieceSymbol.bishop, 'B'),
        (PieceSymbol.knight, 'N'),
        (PieceSymbol.queen, 'Q'),
      ];

      for (final (piece, symbol) in promotionPieces) {
        final move = PromotionMove(
          moving: Pawn(Team.white),
          from: Position.fromAlgebraic('a7'),
          to: Position.fromAlgebraic('a8'),
          promotion: piece,
          check: Check.none,
        );
        expect(formatter.visit(move), 'a8=$symbol');
      }
    });

    test('should format ambiguous capture moves for different pieces', () {
      // Test ambiguous rook capture by rank
      final rookMove = RookCaptureMove(
        moving: Rook(Team.white),
        from: Position.fromAlgebraic('a1'),
        to: Position.fromAlgebraic('a4'),
        captured: Pawn(Team.black),
        ambiguous: AmbiguousMovementType.rank,
        check: Check.none,
      );
      expect(formatter.visit(rookMove), 'R1xa4');

      // Test ambiguous bishop capture by both
      final bishopMove = BishopCaptureMove(
        moving: Bishop(Team.white),
        from: Position.fromAlgebraic('c1'),
        to: Position.fromAlgebraic('f4'),
        captured: Knight(Team.black),
        ambiguous: AmbiguousMovementType.both,
        check: Check.none,
      );
      expect(formatter.visit(bishopMove), 'Bc1xf4');

      // Test ambiguous knight capture by file
      final knightMove = KnightCaptureMove(
        moving: Knight(Team.white),
        from: Position.fromAlgebraic('b1'),
        to: Position.fromAlgebraic('c3'),
        captured: Pawn(Team.black),
        ambiguous: AmbiguousMovementType.file,
        check: Check.none,
      );
      expect(formatter.visit(knightMove), 'Nbxc3');
    });

    test('should format complex scenarios with promotion captures and different pieces', () {
      final promotionCaptures = [
        (PieceSymbol.rook, 'R'),
        (PieceSymbol.bishop, 'B'), 
        (PieceSymbol.knight, 'N'),
        (PieceSymbol.queen, 'Q'),
      ];

      for (final (piece, symbol) in promotionCaptures) {
        final move = PromotionCaptureMove(
          moving: Pawn(Team.white),
          from: Position.fromAlgebraic('f7'),
          to: Position.fromAlgebraic('g8'),
          captured: Bishop(Team.black),
          promotion: piece,
          check: Check.check,
        );
        expect(formatter.visit(move), 'fxg8=$symbol+');
      }
    });
  });
}
