import 'package:chess_logic/src/controller/board_state.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/square/piece_value.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('Piece', () {
    group('factory constructor', () {
      test('should create King from symbol', () {
        final piece = Piece.fromSymbol(PieceSymbol.king, Team.white);
        expect(piece, isA<King>());
        expect(piece.team, equals(Team.white));
        expect(piece.symbol, equals(PieceSymbol.king));
      });

      test('should create Queen from symbol', () {
        final piece = Piece.fromSymbol(PieceSymbol.queen, Team.black);
        expect(piece, isA<Queen>());
        expect(piece.team, equals(Team.black));
        expect(piece.symbol, equals(PieceSymbol.queen));
      });

      test('should create Rook from symbol', () {
        final piece = Piece.fromSymbol(PieceSymbol.rook, Team.white);
        expect(piece, isA<Rook>());
        expect(piece.team, equals(Team.white));
        expect(piece.symbol, equals(PieceSymbol.rook));
      });

      test('should create Bishop from symbol', () {
        final piece = Piece.fromSymbol(PieceSymbol.bishop, Team.black);
        expect(piece, isA<Bishop>());
        expect(piece.team, equals(Team.black));
        expect(piece.symbol, equals(PieceSymbol.bishop));
      });

      test('should create Knight from symbol', () {
        final piece = Piece.fromSymbol(PieceSymbol.knight, Team.white);
        expect(piece, isA<Knight>());
        expect(piece.team, equals(Team.white));
        expect(piece.symbol, equals(PieceSymbol.knight));
      });

      test('should create Pawn from symbol', () {
        final piece = Piece.fromSymbol(PieceSymbol.pawn, Team.black);
        expect(piece, isA<Pawn>());
        expect(piece.team, equals(Team.black));
        expect(piece.symbol, equals(PieceSymbol.pawn));
      });
    });
  });

  group('King', () {
    test('should have correct symbol and value', () {
      const king = King.white;
      expect(king.symbol, equals(PieceSymbol.king));
      expect(king.value, equals(PieceValue.king.points));
      expect(king.value, equals(0));
    });

    test('should have correct algebraic notation', () {
      const king = King.white;
      expect(king.toAlgebraic(), equals('K'));
    });

    test('should have correct string representation', () {
      const king = King.black;
      expect(king.toString(), equals('king'));
    });

    test('should preserve team', () {
      const whiteKing = King.white;
      const blackKing = King.black;
      expect(whiteKing.team, equals(Team.white));
      expect(blackKing.team, equals(Team.black));
    });

    test('should not be a promotion piece', () {
      const king = King.white;
      expect(king, isNot(isA<PromotionPiece>()));
    });
  });

  group('Queen', () {
    test('should have correct symbol and value', () {
      const queen = Queen.white;
      expect(queen.symbol, equals(PieceSymbol.queen));
      expect(queen.value, equals(PieceValue.queen.points));
      expect(queen.value, equals(9));
    });

    test('should have correct algebraic notation', () {
      const queen = Queen.white;
      expect(queen.toAlgebraic(), equals('Q'));
    });

    test('should have correct string representation', () {
      const queen = Queen.black;
      expect(queen.toString(), equals('queen'));
    });

    test('should be a promotion piece', () {
      const queen = Queen.white;
      expect(queen, isA<PromotionPiece>());
    });
  });

  group('Rook', () {
    test('should have correct symbol and value', () {
      const rook = Rook.white;
      expect(rook.symbol, equals(PieceSymbol.rook));
      expect(rook.value, equals(PieceValue.rook.points));
      expect(rook.value, equals(5));
    });

    test('should have correct algebraic notation', () {
      const rook = Rook.white;
      expect(rook.toAlgebraic(), equals('R'));
    });

    test('should have correct string representation', () {
      const rook = Rook.black;
      expect(rook.toString(), equals('rook'));
    });

    test('should be a promotion piece', () {
      const rook = Rook.white;
      expect(rook, isA<PromotionPiece>());
    });
  });

  group('Bishop', () {
    test('should have correct symbol and value', () {
      const bishop = Bishop.white;
      expect(bishop.symbol, equals(PieceSymbol.bishop));
      expect(bishop.value, equals(PieceValue.bishop.points));
      expect(bishop.value, equals(3));
    });

    test('should have correct algebraic notation', () {
      const bishop = Bishop.white;
      expect(bishop.toAlgebraic(), equals('B'));
    });

    test('should have correct string representation', () {
      const bishop = Bishop.black;
      expect(bishop.toString(), equals('bishop'));
    });

    test('should be a promotion piece', () {
      const bishop = Bishop.white;
      expect(bishop, isA<PromotionPiece>());
    });
  });

  group('Knight', () {
    test('should have correct symbol and value', () {
      const knight = Knight.white;
      expect(knight.symbol, equals(PieceSymbol.knight));
      expect(knight.value, equals(PieceValue.knight.points));
      expect(knight.value, equals(3));
    });

    test('should have correct algebraic notation', () {
      const knight = Knight.white;
      expect(knight.toAlgebraic(), equals('N'));
    });

    test('should have correct string representation', () {
      const knight = Knight.black;
      expect(knight.toString(), equals('knight'));
    });

    test('should be a promotion piece', () {
      const knight = Knight.white;
      expect(knight, isA<PromotionPiece>());
    });
  });

  group('Pawn', () {
    test('should have correct symbol and value', () {
      const pawn = Pawn.white;
      expect(pawn.symbol, equals(PieceSymbol.pawn));
      expect(pawn.value, equals(PieceValue.pawn.points));
      expect(pawn.value, equals(1));
    });

    test('should have empty algebraic notation', () {
      const pawn = Pawn.white;
      expect(pawn.toAlgebraic(), equals(''));
    });

    test('should have correct string representation', () {
      const pawn = Pawn.black;
      expect(pawn.toString(), equals('pawn'));
    });

    test('should preserve team', () {
      const whitePawn = Pawn.white;
      const blackPawn = Pawn.black;
      expect(whitePawn.team, equals(Team.white));
      expect(blackPawn.team, equals(Team.black));
    });

    test('should not be a promotion piece', () {
      const pawn = Pawn.white;
      expect(pawn, isNot(isA<PromotionPiece>()));
    });
  });

  group('PromotionPiece', () {
    test('should include Queen, Rook, Bishop, and Knight', () {
      const queen = Queen.white;
      const rook = Rook.white;
      const bishop = Bishop.white;
      const knight = Knight.white;

      expect(queen, isA<PromotionPiece>());
      expect(rook, isA<PromotionPiece>());
      expect(bishop, isA<PromotionPiece>());
      expect(knight, isA<PromotionPiece>());
    });

    test('should not include King and Pawn', () {
      const king = King.white;
      const pawn = Pawn.white;

      expect(king, isNot(isA<PromotionPiece>()));
      expect(pawn, isNot(isA<PromotionPiece>()));
    });
  });

  group('piece equality and identity', () {
    test('same piece type with different teams should be different', () {
      const whiteQueen = Queen.white;
      const blackQueen = Queen.black;

      expect(whiteQueen.team, isNot(equals(blackQueen.team)));
      expect(whiteQueen.symbol, equals(blackQueen.symbol));
      expect(whiteQueen.value, equals(blackQueen.value));
    });
  });

  group('piece hierarchy', () {
    test('all pieces should inherit from Piece', () {
      final pieces = [
        King.white,
        Queen.white,
        Rook.white,
        Bishop.white,
        Knight.white,
        Pawn.white,
      ];

      for (final piece in pieces) {
        expect(piece, isA<Piece>());
      }
    });

    test('promotion pieces should have promotion symbol correspondence', () {
      final promotionPieces = [
        Queen.white,
        Rook.white,
        Bishop.white,
        Knight.white,
      ];

      final promotionSymbols = PieceSymbol.promotionSymbols;

      for (final piece in promotionPieces) {
        expect(promotionSymbols, contains(piece.symbol));
      }

      final others = <Piece>[King.white, Pawn.white];

      for (final piece in others) {
        expect(promotionSymbols, isNot(contains(piece.symbol)));
      }
    });

    test('sliding pieces should implement slidingpieces', () {
      final slidingPieces = [Queen.white, Rook.white, Bishop.white];

      for (final piece in slidingPieces) {
        expect(piece, isA<SlidingPiece>());
      }

      final others = [King.white, Knight.white, Pawn.white];

      for (final piece in others) {
        expect(piece, isNot(isA<SlidingPiece>()));
      }
    });
  });

  group('piece values', () {
    test('should match corresponding PieceValue enum values', () {
      const king = King.white;
      const queen = Queen.white;
      const rook = Rook.white;
      const bishop = Bishop.white;
      const knight = Knight.white;
      const pawn = Pawn.white;

      expect(king.value, equals(PieceValue.king.points));
      expect(queen.value, equals(PieceValue.queen.points));
      expect(rook.value, equals(PieceValue.rook.points));
      expect(bishop.value, equals(PieceValue.bishop.points));
      expect(knight.value, equals(PieceValue.knight.points));
      expect(pawn.value, equals(PieceValue.pawn.points));
    });
  });

  group('piece equality tests', () {
    group('same piece type with same team', () {
      test('should be equal', () {
        const piece1 = King.white;
        const piece2 = King.white;

        expect(piece1 == piece2, isTrue);
        expect(piece1, equals(piece2));
      });

      test('should have same hashCode', () {
        const piece1 = Queen.black;
        const piece2 = Queen.black;

        expect(piece1.hashCode, equals(piece2.hashCode));
      });

      test('should work for all piece types', () {
        final whitePieces1 = [
          King.white,
          Queen.white,
          Rook.white,
          Bishop.white,
          Knight.white,
          Pawn.white,
        ];

        final whitePieces2 = [
          King.white,
          Queen.white,
          Rook.white,
          Bishop.white,
          Knight.white,
          Pawn.white,
        ];

        for (int i = 0; i < whitePieces1.length; i++) {
          expect(whitePieces1[i], equals(whitePieces2[i]));
          expect(whitePieces1[i].hashCode, equals(whitePieces2[i].hashCode));
        }
      });
    });

    group('same piece type with different teams', () {
      test('should not be equal', () {
        const whiteKing = King.white;
        const blackKing = King.black;

        expect(whiteKing == blackKing, isFalse);
        expect(whiteKing, isNot(equals(blackKing)));
      });

      test('should have different hashCodes', () {
        const whiteQueen = Queen.white;
        const blackQueen = Queen.black;

        expect(whiteQueen.hashCode, isNot(equals(blackQueen.hashCode)));
      });

      test('should work for all piece types', () {
        final whitePieces = [
          King.white,
          Queen.white,
          Rook.white,
          Bishop.white,
          Knight.white,
          Pawn.white,
        ];

        final blackPieces = [
          King.black,
          Queen.black,
          Rook.black,
          Bishop.black,
          Knight.black,
          Pawn.black,
        ];

        for (int i = 0; i < whitePieces.length; i++) {
          expect(whitePieces[i], isNot(equals(blackPieces[i])));
        }
      });
    });

    group('different piece types with same team', () {
      test('should not be equal', () {
        const Piece king = King.white;
        const Piece queen = Queen.white;

        expect(king == queen, isFalse);
        expect(king, isNot(equals(queen)));
      });

      test('should have different hashCodes', () {
        const rook = Rook.black;
        const bishop = Bishop.black;

        expect(rook.hashCode, isNot(equals(bishop.hashCode)));
      });

      test('should work for various combinations', () {
        final pieces = [
          King.white,
          Queen.white,
          Rook.white,
          Bishop.white,
          Knight.white,
          Pawn.white,
        ];

        for (int i = 0; i < pieces.length; i++) {
          for (int j = i + 1; j < pieces.length; j++) {
            expect(pieces[i], isNot(equals(pieces[j])));
          }
        }
      });
    });

    group('identical instances', () {
      test('should be equal to itself', () {
        const piece = Knight.white;

        expect(piece == piece, isTrue);
        expect(piece, equals(piece));
        expect(identical(piece, piece), isTrue);
      });

      test('should have consistent hashCode', () {
        const piece = Bishop.black;
        final hashCode1 = piece.hashCode;
        final hashCode2 = piece.hashCode;

        expect(hashCode1, equals(hashCode2));
      });
    });
    group('equality with null and other types', () {
      test('should not be equal to null', () {
        const piece = Pawn.white;

        expect(piece, isNot(equals(null)));
      });

      test('should not be equal to different types', () {
        const piece = Queen.black;

        expect(piece, isNot(equals('queen')));
        expect(piece, isNot(equals(42)));
        expect(piece, isNot(equals([])));
      });
    });

    group('factory constructor equality', () {
      test('should create equal pieces from same symbol and team', () {
        final piece1 = Piece.fromSymbol(PieceSymbol.rook, Team.white);
        final piece2 = Piece.fromSymbol(PieceSymbol.rook, Team.white);

        expect(piece1, equals(piece2));
        expect(piece1.hashCode, equals(piece2.hashCode));
      });

      test('should create different pieces from different symbols', () {
        final piece1 = Piece.fromSymbol(PieceSymbol.king, Team.white);
        final piece2 = Piece.fromSymbol(PieceSymbol.queen, Team.white);

        expect(piece1, isNot(equals(piece2)));
      });

      test('should create different pieces from different teams', () {
        final piece1 = Piece.fromSymbol(PieceSymbol.bishop, Team.white);
        final piece2 = Piece.fromSymbol(PieceSymbol.bishop, Team.black);

        expect(piece1, isNot(equals(piece2)));
      });
    });

    group('equality reflexivity, symmetry, and transitivity', () {
      test('should be reflexive (a == a)', () {
        final pieces = [
          King.white,
          Queen.black,
          Rook.white,
          Bishop.black,
          Knight.white,
          Pawn.black,
        ];

        for (final piece in pieces) {
          expect(piece == piece, isTrue);
        }
      });

      test('should be symmetric (a == b implies b == a)', () {
        const piece1 = Knight.white;
        const piece2 = Knight.white;

        expect(piece1 == piece2, equals(piece2 == piece1));
      });

      test('should be transitive (a == b and b == c implies a == c)', () {
        const piece1 = Rook.black;
        const piece2 = Rook.black;
        const piece3 = Rook.black;

        expect(piece1 == piece2, isTrue);
        expect(piece2 == piece3, isTrue);
        expect(piece1 == piece3, isTrue);
      });
    });

    group('hashCode contract', () {
      test('equal objects should have equal hashCodes', () {
        const piece1 = Queen.white;
        const piece2 = Queen.white;

        expect(piece1 == piece2, isTrue);
        expect(piece1.hashCode, equals(piece2.hashCode));
      });

      test('hashCode should be consistent across multiple calls', () {
        const piece = King.black;
        final hashCodes = List.generate(10, (_) => piece.hashCode);

        expect(hashCodes.every((hash) => hash == hashCodes.first), isTrue);
      });

      test('different pieces should generally have different hashCodes', () {
        final pieces = [
          King.white,
          Queen.white,
          Rook.white,
          Bishop.white,
          Knight.white,
          Pawn.white,
          King.black,
          Queen.black,
          Rook.black,
          Bishop.black,
          Knight.black,
          Pawn.black,
        ];

        final hashCodes = pieces.map((p) => p.hashCode).toSet();

        // While not guaranteed, different pieces should generally have
        //different hash codes
        expect(hashCodes.length, greaterThan(1));
      });
    });

    group('Set and Map behavior', () {
      test('should work correctly in Sets', () {
        const piece1 = Bishop.white;
        // ignore: prefer_const_constructors, testing for equality
        final piece2 = Bishop(Team.white);
        const piece3 = Bishop.black;

        final set = {piece1, piece2, piece3};

        expect(set.length, equals(2)); // piece1 and piece2 are equal
        expect(set.contains(piece1), isTrue);
        expect(set.contains(piece2), isTrue);
        expect(set.contains(piece3), isTrue);
      });

      test('should work correctly as Map keys', () {
        const piece1 = Pawn.white;
        const piece2 = Pawn.white;
        const piece3 = Pawn.black;

        final map = <Piece, String>{piece1: 'white pawn', piece3: 'black pawn'};

        expect(map[piece1], equals('white pawn'));
        expect(map[piece2], equals('white pawn')); // piece1 == piece2
        expect(map[piece3], equals('black pawn'));
        expect(map.length, equals(2));
      });
    });
  });

  group('Piece validPositions tests', () {
    late BoardState boardState;

    setUp(() {
      boardState = BoardState.empty();
    });
    group('King validPositions', () {
      test('should return all adjacent squares on empty board', () {
        // Define piece instances once
        const whiteKing = King.white;

        // Define position instances once
        const d4 = Position.d4; // Center position
        const c5 = Position.c5; // up-left
        const d5 = Position.d5; // up
        const e5 = Position.e5; // up-right
        const c4 = Position.c4; // left
        const e4 = Position.e4; // right
        const c3 = Position.c3; // down-left
        const d3 = Position.d3; // down
        const e3 = Position.e3; // down-right

        final validPositions = whiteKing.validPositions(boardState, d4);

        final expectedPositions = [c5, d5, e5, c4, e4, c3, d3, e3];

        expect(validPositions.length, equals(8));
        for (final expectedPos in expectedPositions) {
          expect(validPositions, contains(expectedPos));
        }
      });

      test('should not include positions with same team pieces', () {
        // Define piece instances once
        const whiteKing = King.white;
        const whitePawn = Pawn.white;
        const whiteKnight = Knight.white;

        // Define position instances once
        const d4 = Position.d4;
        const c5 = Position.c5;
        const e4 = Position.e4;
        const d5 = Position.d5;
        const e5 = Position.e5;

        // Place same team pieces in some adjacent squares
        boardState.replace(const OccupiedSquare(c5, whitePawn));
        boardState.replace(const OccupiedSquare(e4, whiteKnight));

        final validPositions = whiteKing.validPositions(boardState, d4);

        expect(validPositions, isNot(contains(c5)));
        expect(validPositions, isNot(contains(e4)));
        expect(validPositions, contains(d5));
        expect(validPositions, contains(e5));
      });

      test('should include positions with enemy pieces for capture', () {
        // Define piece instances once
        const whiteKing = King.white;
        const blackPawn = Pawn.black;
        const blackKnight = Knight.black;

        // Define position instances once
        const d4 = Position.d4;
        const c5 = Position.c5;
        const e4 = Position.e4;
        const d5 = Position.d5;
        const e5 = Position.e5;

        // Place enemy pieces in some adjacent squares
        boardState.replace(c5 < blackPawn);
        boardState.replace(e4 < blackKnight);

        final validPositions = whiteKing.validPositions(boardState, d4);

        expect(validPositions, contains(c5));
        expect(validPositions, contains(e4));
        expect(validPositions, contains(d5));
        expect(validPositions, contains(e5));
      });

      test('should handle edge positions correctly', () {
        // Define piece instances once
        const whiteKing = King.white;

        // Define position instances once
        const a1 = Position.a1; // Corner position
        const a2 = Position.a2; // up
        const b1 = Position.b1; // right
        const b2 = Position.b2; // up-right

        final validPositions = whiteKing.validPositions(boardState, a1);

        final expectedPositions = [a2, b1, b2];

        expect(validPositions.length, equals(3));
        for (final expectedPos in expectedPositions) {
          expect(validPositions, contains(expectedPos));
        }
      });
    });
    group('Queen validPositions', () {
      test('should return all lines of movement on empty board', () {
        // Define piece instances once
        const whiteQueen = Queen.white;

        // Define position instances once
        const d4 = Position.d4;
        const d8 = Position.d8; // vertical up
        const d1 = Position.d1; // vertical down
        const a4 = Position.a4; // horizontal left
        const h4 = Position.h4; // horizontal right
        const a1 = Position.a1; // diagonal down-left
        const h8 = Position.h8; // diagonal up-right

        final validPositions = whiteQueen.validPositions(boardState, d4);

        // Queen should be able to move in all 8 directions until board edge
        expect(
          validPositions.length,
          equals(27),
        ); // 8 directions * varying lengths

        // Check some specific positions
        expect(validPositions, contains(d8));
        expect(validPositions, contains(d1));
        expect(validPositions, contains(a4));
        expect(validPositions, contains(h4));
        expect(validPositions, contains(a1));
        expect(validPositions, contains(h8));
      });

      test('should stop at same team pieces and not include them', () {
        // Define piece instances once
        const whiteQueen = Queen.white;
        const whiteRook = Rook.white;
        const whiteBishop = Bishop.white;

        // Define position instances once
        const d4 = Position.d4;
        const d6 = Position.d6;
        const f4 = Position.f4;
        const d7 = Position.d7;
        const d8 = Position.d8;
        const g4 = Position.g4;
        const h4 = Position.h4;
        const d5 = Position.d5;
        const e4 = Position.e4;

        // Place same team piece on the queen's path
        boardState.replace(d6 < whiteRook);
        boardState.replace(f4 < whiteBishop);

        final validPositions = whiteQueen.validPositions(boardState, d4);

        // Should not include the squares with same team pieces
        expect(validPositions, isNot(contains(d6)));
        expect(validPositions, isNot(contains(d7)));
        expect(validPositions, isNot(contains(d8)));
        expect(validPositions, isNot(contains(f4)));
        expect(validPositions, isNot(contains(g4)));
        expect(validPositions, isNot(contains(h4)));

        // But should include squares before the blocking pieces
        expect(validPositions, contains(d5));
        expect(validPositions, contains(e4));
      });

      test('should stop at enemy pieces but include them for capture', () {
        // Define piece instances once
        const whiteQueen = Queen.white;
        const blackRook = Rook.black;
        const blackBishop = Bishop.black;

        // Define position instances once
        const d4 = Position.d4;
        const d6 = Position.d6;
        const f4 = Position.f4;
        const d7 = Position.d7;
        const d8 = Position.d8;
        const g4 = Position.g4;
        const h4 = Position.h4;
        const d5 = Position.d5;
        const e4 = Position.e4;

        // Place enemy pieces on the queen's path
        boardState.replace(d6 < blackRook);
        boardState.replace(f4 < blackBishop);

        final validPositions = whiteQueen.validPositions(boardState, d4);

        // Should include the squares with enemy pieces for capture
        expect(validPositions, contains(d6));
        expect(validPositions, contains(f4));

        // But should not include squares beyond them
        expect(validPositions, isNot(contains(d7)));
        expect(validPositions, isNot(contains(d8)));
        expect(validPositions, isNot(contains(g4)));
        expect(validPositions, isNot(contains(h4)));

        // Should include squares before the enemy pieces
        expect(validPositions, contains(d5));
        expect(validPositions, contains(e4));
      });
    });
    group('Rook validPositions', () {
      test(
        'should return all horizontal and vertical lines on empty board',
        () {
          // Define piece instances once
          const whiteRook = Rook.white;

          // Define position instances once
          const d4 = Position.d4;
          const d8 = Position.d8; // vertical up
          const d1 = Position.d1; // vertical down
          const a4 = Position.a4; // horizontal left
          const h4 = Position.h4; // horizontal right
          const e5 = Position.e5;
          const c3 = Position.c3;

          final validPositions = whiteRook.validPositions(boardState, d4);

          // Rook moves in 4 directions (horizontal and vertical)
          expect(
            validPositions.length,
            equals(14),
          ); // 3+3+4+4 squares in each direction

          // Check specific positions
          expect(validPositions, contains(d8));
          expect(validPositions, contains(d1));
          expect(validPositions, contains(a4));
          expect(validPositions, contains(h4));

          // Should not include diagonal moves
          expect(validPositions, isNot(contains(e5)));
          expect(validPositions, isNot(contains(c3)));
        },
      );

      test('should stop at same team pieces and not include them', () {
        // Define piece instances once
        const whiteRook = Rook.white;
        const whitePawn = Pawn.white;

        // Define position instances once
        const d4 = Position.d4;
        const d6 = Position.d6;
        const d7 = Position.d7;
        const d8 = Position.d8;
        const d5 = Position.d5;

        // Place same team piece blocking vertical movement
        boardState.replace(d6 < whitePawn);

        final validPositions = whiteRook.validPositions(boardState, d4);

        // Should not include the blocking square or beyond
        expect(validPositions, isNot(contains(d6)));
        expect(validPositions, isNot(contains(d7)));
        expect(validPositions, isNot(contains(d8)));

        // Should include squares before the blocking piece
        expect(validPositions, contains(d5));
      });

      test('should include enemy pieces for capture', () {
        // Define piece instances once
        const whiteRook = Rook.white;
        const blackPawn = Pawn.black;

        // Define position instances once
        const d4 = Position.d4;
        const d6 = Position.d6;
        const d7 = Position.d7;
        const d8 = Position.d8;

        // Place enemy piece on the rook's path
        boardState.replace(d6 < blackPawn);

        final validPositions = whiteRook.validPositions(boardState, d4);

        // Should include the enemy piece for capture
        expect(validPositions, contains(d6));

        // Should not include squares beyond the enemy piece
        expect(validPositions, isNot(contains(d7)));
        expect(validPositions, isNot(contains(d8)));
      });
    });
    group('Bishop validPositions', () {
      test('should return all diagonal lines on empty board', () {
        // Define piece instances once
        const whiteBishop = Bishop.white;

        // Define position instances once
        const d4 = Position.d4;
        const a1 = Position.a1; // down-left
        const g7 = Position.g7; // up-right
        const a7 = Position.a7; // up-left
        const h8 = Position.h8; // up-right extended
        const d5 = Position.d5;
        const e4 = Position.e4;

        final validPositions = whiteBishop.validPositions(boardState, d4);

        // Bishop moves in 4 diagonal directions
        expect(
          validPositions.length,
          equals(13),
        ); // Sum of diagonal lengths from d4

        // Check specific diagonal positions
        expect(validPositions, contains(a1));
        expect(validPositions, contains(g7));
        expect(validPositions, contains(a7));
        expect(validPositions, contains(h8));

        // Should not include straight line moves
        expect(validPositions, isNot(contains(d5)));
        expect(validPositions, isNot(contains(e4)));
      });

      test('should stop at same team pieces and not include them', () {
        // Define piece instances once
        const whiteBishop = Bishop.white;
        const whiteKnight = Knight.white;

        // Define position instances once
        const d4 = Position.d4;
        const f6 = Position.f6;
        const g7 = Position.g7;
        const h8 = Position.h8;
        const e5 = Position.e5;

        // Place same team piece on diagonal
        boardState.replace(f6 < whiteKnight);

        final validPositions = whiteBishop.validPositions(boardState, d4);

        // Should not include the blocking square or beyond
        expect(validPositions, isNot(contains(f6)));
        expect(validPositions, isNot(contains(g7)));
        expect(validPositions, isNot(contains(h8)));

        // Should include squares before the blocking piece
        expect(validPositions, contains(e5));
      });

      test('should include enemy pieces for capture', () {
        // Define piece instances once
        const whiteBishop = Bishop.white;
        const blackKnight = Knight.black;

        // Define position instances once
        const d4 = Position.d4;
        const f6 = Position.f6;
        const g7 = Position.g7;
        const h8 = Position.h8;

        // Place enemy piece on diagonal
        boardState.replace(f6 < blackKnight);

        final validPositions = whiteBishop.validPositions(boardState, d4);

        // Should include the enemy piece for capture
        expect(validPositions, contains(f6));

        // Should not include squares beyond the enemy piece
        expect(validPositions, isNot(contains(g7)));
        expect(validPositions, isNot(contains(h8)));
      });
    });
    group('Knight validPositions', () {
      test('should return all L-shaped moves on empty board', () {
        // Define piece instances once
        const whiteKnight = Knight.white;

        // Define position instances once
        const d4 = Position.d4;
        const b5 = Position.b5; // up-up-left
        const b3 = Position.b3; // down-down-left
        const c6 = Position.c6; // up-left-left
        const c2 = Position.c2; // down-left-left
        const e6 = Position.e6; // up-right-right
        const e2 = Position.e2; // down-right-right
        const f5 = Position.f5; // up-up-right
        const f3 = Position.f3; // down-down-right

        final validPositions = whiteKnight.validPositions(boardState, d4);

        final expectedPositions = [b5, b3, c6, c2, e6, e2, f5, f3];

        expect(validPositions.length, equals(8));
        for (final expectedPos in expectedPositions) {
          expect(validPositions, contains(expectedPos));
        }
      });

      test('should not include positions with same team pieces', () {
        // Define piece instances once
        const whiteKnight = Knight.white;
        const whitePawn = Pawn.white;
        const whiteRook = Rook.white;

        // Define position instances once
        const d4 = Position.d4;
        const b5 = Position.b5;
        const f3 = Position.f3;
        const c6 = Position.c6;
        const e6 = Position.e6;

        // Place same team pieces at some knight move destinations
        boardState.replace(b5 < whitePawn);
        boardState.replace(f3 < whiteRook);

        final validPositions = whiteKnight.validPositions(boardState, d4);

        expect(validPositions, isNot(contains(b5)));
        expect(validPositions, isNot(contains(f3)));
        expect(validPositions, contains(c6));
        expect(validPositions, contains(e6));
      });

      test('should include positions with enemy pieces for capture', () {
        // Define piece instances once
        const whiteKnight = Knight.white;
        const blackPawn = Pawn.black;
        const blackRook = Rook.black;

        // Define position instances once
        const d4 = Position.d4;
        const b5 = Position.b5;
        const f3 = Position.f3;
        const c6 = Position.c6;
        const e6 = Position.e6;

        // Place enemy pieces at some knight move destinations
        boardState.replace(b5 < blackPawn);
        boardState.replace(f3 < blackRook);

        final validPositions = whiteKnight.validPositions(boardState, d4);

        expect(validPositions, contains(b5));
        expect(validPositions, contains(f3));
        expect(validPositions, contains(c6));
        expect(validPositions, contains(e6));
      });

      test('should handle edge positions correctly', () {
        // Define piece instances once
        const whiteKnight = Knight.white;

        // Define position instances once
        const a1 = Position.a1; // Corner position
        const b3 = Position.b3;
        const c2 = Position.c2;

        final validPositions = whiteKnight.validPositions(boardState, a1);

        final expectedPositions = [b3, c2];

        expect(validPositions.length, equals(2));
        for (final expectedPos in expectedPositions) {
          expect(validPositions, contains(expectedPos));
        }
      });
    });
    group('Pawn validPositions', () {
      test(
        'should return forward moves on empty board from initial position',
        () {
          // Define piece instances once
          const whitePawn = Pawn.white;

          // Define position instances once
          const e2 = Position.e2; // Initial position for white pawn
          const e3 = Position.e3;
          const e4 = Position.e4;

          final validPositions = whitePawn.validPositions(boardState, e2);

          // Pawn should be able to move 1 or 2 squares forward from initial
          // position
          expect(validPositions.length, equals(2));
          expect(validPositions, containsAll([e3, e4]));
        },
      );

      test('should return only one forward move from non-initial position', () {
        // Define piece instances once
        const whitePawn = Pawn.white;

        // Define position instances once
        const e3 = Position.e3; // Non-initial position
        const e4 = Position.e4;

        final validPositions = whitePawn.validPositions(boardState, e3);

        expect(validPositions, contains(e4));
        expect(validPositions.length, equals(1));
      });

      test('should not move forward if blocked by any piece', () {
        // Define piece instances once
        const whitePawn = Pawn.white;
        const blackPawn = Pawn.black;

        // Define position instances once
        const e2 = Position.e2;
        const e3 = Position.e3;

        // Block the square in front
        boardState.replace(e3 < blackPawn);

        final validPositions = whitePawn.validPositions(boardState, e2);

        expect(validPositions.isEmpty, isTrue);
      });

      test('should include diagonal captures of enemy pieces', () {
        // Define piece instances once
        const whitePawn = Pawn.white;
        const blackPawn = Pawn.black;
        const blackKnight = Knight.black;

        // Define position instances once
        const e4 = Position.e4;
        const d5 = Position.d5;
        const f5 = Position.f5;
        const e5 = Position.e5;

        // Place enemy pieces diagonally
        boardState.replace(d5 < blackPawn);
        boardState.replace(f5 < blackKnight);

        final validPositions = whitePawn.validPositions(boardState, e4);

        // Should include diagonal captures and forward move
        expect(validPositions, contains(d5));
        expect(validPositions, contains(f5));
        expect(validPositions, contains(e5));
        expect(validPositions.length, equals(3));
      });

      test('should not capture same team pieces diagonally', () {
        // Define piece instances once
        const whitePawn = Pawn.white;
        const whitePawn2 = Pawn.white;
        const whiteKnight = Knight.white;

        // Define position instances once
        const e4 = Position.e4;
        const d5 = Position.d5;
        const f5 = Position.f5;
        const e5 = Position.e5;

        // Place same team pieces diagonally
        boardState.replace(d5 < whitePawn2);
        boardState.replace(f5 < whiteKnight);

        final validPositions = whitePawn.validPositions(boardState, e4);

        // Should not include diagonal same team pieces, only forward move
        expect(validPositions, isNot(contains(d5)));
        expect(validPositions, isNot(contains(f5)));
        expect(validPositions, contains(e5));
        expect(validPositions.length, equals(1));
      });

      test('should work correctly for black pawns moving down', () {
        // Define piece instances once
        const blackPawn = Pawn.black;

        // Define position instances once
        const e7 = Position.e7; // Initial position for black pawn
        const e6 = Position.e6;
        const e5 = Position.e5;

        final validPositions = blackPawn.validPositions(boardState, e7);

        // Black pawn should move down
        expect(validPositions, contains(e6));
        expect(validPositions, contains(e5));
        expect(validPositions.length, equals(2));
      });

      test('should include diagonal captures for black pawns', () {
        // Define piece instances once
        const blackPawn = Pawn.black;
        const whitePawn = Pawn.white;
        const whiteKnight = Knight.white;

        // Define position instances once
        const e5 = Position.e5;
        const d4 = Position.d4;
        const f4 = Position.f4;
        const e4 = Position.e4;

        // Place white pieces diagonally down from black pawn
        boardState.replace(d4 < whitePawn);
        boardState.replace(f4 < whiteKnight);

        final validPositions = blackPawn.validPositions(boardState, e5);

        // Should include diagonal captures and forward move
        expect(validPositions, contains(d4));
        expect(validPositions, contains(f4));
        expect(validPositions, contains(e4));
        expect(validPositions.length, equals(3));
      });

      test(
        'should not move from initial position if second square is blocked',
        () {
          // Define piece instances once
          const whitePawn = Pawn.white;
          const blackPawn = Pawn.black;

          // Define position instances once
          const e2 = Position.e2;
          const e4 = Position.e4;
          const e3 = Position.e3;

          // Block the second square ahead
          boardState.replace(e4 < blackPawn);

          final validPositions = whitePawn.validPositions(boardState, e2);

          // Should only be able to move one square
          expect(validPositions, contains(e3));
          expect(validPositions, isNot(contains(e4)));
          expect(validPositions.length, equals(1));
        },
      );
    });

    group('Pawn validPositions with lastMove parameter', () {
      test(
        'should enable en passant capture when last move was PawnInitialMove',
        () {
          // Setup: White pawn at e5, black pawn just moved from d7 to d5
          // (PawnInitialMove)
          const whitePawn = Pawn.white;
          const blackPawn = Pawn.black;

          const e5 = Position.e5;
          const d5 = Position.d5;
          const d7 = Position.d7;
          const d6 = Position.d6;

          // Place pawns on board
          boardState.replace(e5 < whitePawn);
          boardState.replace(d5 < blackPawn);

          // Create the last move - black pawn initial move from d7 to d5
          final lastMove = PawnInitialMove(from: d7, to: d5, moving: blackPawn);

          final validPositions = whitePawn.validPositions(
            boardState,
            e5,
            lastMove: lastMove,
          );

          // Should include en passant capture to d6
          expect(validPositions, contains(d6));
          expect(
            validPositions.length,
            greaterThan(1),
          ); // Should have forward move + en passant
        },
      );

      test('should enable en passant capture for black pawn when last move was '
          'white PawnInitialMove', () {
        // Setup: Black pawn at d4, white pawn just moved from e2 to e4
        // (PawnInitialMove)
        const whitePawn = Pawn.white;
        const blackPawn = Pawn.black;

        const d4 = Position.d4;
        const e4 = Position.e4;
        const e2 = Position.e2;
        const e3 = Position.e3;

        // Place pawns on board
        boardState.replace(d4 < blackPawn);
        boardState.replace(e4 < whitePawn);

        // Create the last move - white pawn initial move from e2 to e4
        final lastMove = PawnInitialMove(from: e2, to: e4, moving: whitePawn);

        final validPositions = blackPawn.validPositions(
          boardState,
          d4,
          lastMove: lastMove,
        );

        // Should include en passant capture to e3
        expect(validPositions, contains(e3));
        expect(
          validPositions.length,
          greaterThan(1),
        ); // Should have forward move + en passant
      });

      test(
        'should not enable en passant when last move was not PawnInitialMove',
        () {
          // Setup: White pawn at e5, black pawn at d5, but last move was
          //regular PawnMove
          const whitePawn = Pawn.white;
          const blackPawn = Pawn.black;

          const e5 = Position.e5;
          const d5 = Position.d5;
          const d6 = Position.d6;
          const e6 = Position.e6;

          // Place pawns on board
          boardState.replace(e5 < whitePawn);
          boardState.replace(d5 < blackPawn);

          // Create a regular pawn move (not initial move)
          final lastMove = PawnMove(from: d6, to: d5, moving: blackPawn);

          final validPositions = whitePawn.validPositions(
            boardState,
            e5,
            lastMove: lastMove,
          );

          // Should not include diagonal capture to d6 (no piece there)
          expect(validPositions, isNot(contains(d6)));
          // Should only have forward move
          expect(validPositions, contains(e6));
          expect(validPositions.length, equals(1));
        },
      );

      test('should not enable en passant when PawnInitialMove destination is '
          'wrong file', () {
        // Setup: White pawn at e5, black pawn moved from f7 to f5 (wrong file
        //for en passant)
        const whitePawn = Pawn.white;
        const blackPawn = Pawn.black;

        const e5 = Position.e5;
        const g5 = Position.g5;
        const g7 = Position.g7;
        const f6 = Position.f6;
        const e6 = Position.e6;
        const d6 = Position.d6;

        // Place pawns on board
        boardState.replace(e5 < whitePawn);
        boardState.replace(g5 < blackPawn);

        // Create PawnInitialMove but to wrong file for en passant
        final lastMove = PawnInitialMove(from: g7, to: g5, moving: blackPawn);

        final validPositions = whitePawn.validPositions(
          boardState,
          e5,
          lastMove: lastMove,
        );

        // Should not include en passant capture since f5 is not adjacent to
        //e5 diagonally
        expect(validPositions, isNot(contains(f6)));
        expect(validPositions, isNot(contains(d6)));
        // Should only have forward move
        expect(validPositions, contains(e6));
        expect(validPositions.length, equals(1));
      });
      test('should work with en passant and regular captures together', () {
        // Setup: White pawn at e5 can capture both normally and en passant
        const whitePawn = Pawn.white;
        const blackPawn1 = Pawn.black;
        const blackKnight = Knight.black;

        const e5 = Position.e5;
        const d5 = Position.d5;
        const f6 = Position.f6;
        const d6 = Position.d6;
        const e6 = Position.e6;

        // Place pieces on board
        boardState.replace(e5 < whitePawn);
        boardState.replace(d5 < blackPawn1); // For en passant
        boardState.replace(f6 < blackKnight); // For regular capture

        // Create PawnInitialMove for en passant
        final lastMove = PawnInitialMove(
          from: Position.d7,
          to: d5,
          moving: blackPawn1,
        );

        final validPositions = whitePawn.validPositions(
          boardState,
          e5,
          lastMove: lastMove,
        );

        // Should include both en passant and regular capture
        expect(validPositions, contains(d6)); // En passant
        expect(validPositions, contains(f6)); // Regular capture
        expect(validPositions, contains(e6)); // Forward move
        expect(validPositions.length, equals(3));
      });

      test('should not enable en passant when no lastMove is provided', () {
        // Setup: White pawn at e5, black pawn at d5, but no lastMove provided
        const whitePawn = Pawn.white;
        const blackPawn = Pawn.black;

        const e5 = Position.e5;
        const d5 = Position.d5;
        const d6 = Position.d6;
        const e6 = Position.e6;

        // Place pawns on board
        boardState.replace(e5 < whitePawn);
        boardState.replace(d5 < blackPawn);

        // Call without lastMove parameter
        final validPositions = whitePawn.validPositions(boardState, e5);

        // Should not include en passant capture
        expect(validPositions, isNot(contains(d6)));
        // Should only have forward move
        expect(validPositions, contains(e6));
        expect(validPositions.length, equals(1));
      });

      test('should handle en passant on both sides of pawn simultaneously', () {
        // Setup: White pawn at e5, black pawns on both sides with valid
        // PawnInitialMoves
        const whitePawn = Pawn.white;
        const blackPawn1 = Pawn.black;
        const blackPawn2 = Pawn.black;

        const e5 = Position.e5;
        const d5 = Position.d5;
        const f5 = Position.f5;
        const d6 = Position.d6;
        const f6 = Position.f6;
        const e6 = Position.e6;

        // Place pawns on board
        boardState.replace(e5 < whitePawn);
        boardState.replace(d5 < blackPawn1);
        boardState.replace(f5 < blackPawn2);

        // Create PawnInitialMove for left side en passant
        final lastMove = PawnInitialMove(
          from: Position.d7,
          to: d5,
          moving: blackPawn1,
        );

        final validPositions = whitePawn.validPositions(
          boardState,
          e5,
          lastMove: lastMove,
        );

        // Should include en passant to d6, but not f6 (since lastMove was only
        // for d-file)
        expect(validPositions, contains(d6)); // En passant for lastMove
        expect(
          validPositions,
          isNot(contains(f6)),
        ); // No en passant for f5 pawn
        expect(validPositions, contains(e6)); // Forward move
        expect(validPositions.length, equals(2));
      });

      test('should work correctly for black pawn en passant scenarios', () {
        // Setup: Black pawn at d4, white pawns that could be captured en
        // passant
        const blackPawn = Pawn.black;
        const whitePawn1 = Pawn.white;
        const whitePawn2 = Pawn.white;

        const d4 = Position.d4;
        const c4 = Position.c4;
        const e4 = Position.e4;
        const c3 = Position.c3;
        const e3 = Position.e3;
        const d3 = Position.d3;

        // Place pawns on board
        boardState.replace(d4 < blackPawn);
        boardState.replace(c4 < whitePawn1);
        boardState.replace(e4 < whitePawn2);

        // Create PawnInitialMove for en passant on e-file
        final lastMove = PawnInitialMove(
          from: Position.e2,
          to: e4,
          moving: whitePawn2,
        );

        final validPositions = blackPawn.validPositions(
          boardState,
          d4,
          lastMove: lastMove,
        );

        // Should include en passant to e3, but not c3
        expect(validPositions, contains(e3)); // En passant for lastMove
        expect(
          validPositions,
          isNot(contains(c3)),
        ); // No en passant for c4 pawn
        expect(validPositions, contains(d3)); // Forward move
        expect(validPositions.length, equals(2));
      });

      test('should not enable en passant when target square is occupied', () {
        // Setup: White pawn at e5, black pawn moved d7->d5, but d6 is occupied
        const whitePawn = Pawn.white;
        const blackPawn1 = Pawn.black;
        const blackPawn2 = Pawn.black;

        const e5 = Position.e5;
        const d5 = Position.d5;
        const d6 = Position.d6;
        const e6 = Position.e6;

        // Place pawns on board
        boardState.replace(e5 < whitePawn);
        boardState.replace(d5 < blackPawn1);
        boardState.replace(
          d6 < blackPawn2,
        ); // Occupy the en passant target square

        // Create PawnInitialMove
        final lastMove = PawnInitialMove(
          from: Position.d7,
          to: d5,
          moving: blackPawn1,
        );

        final validPositions = whitePawn.validPositions(
          boardState,
          e5,
          lastMove: lastMove,
        );

        // Should include regular capture of piece at d6
        expect(validPositions, contains(d6)); // Regular capture, not en passant
        expect(validPositions, contains(e6)); // Forward move
        expect(validPositions.length, equals(2));
      });
    });

    group('Mixed scenarios', () {
      test('should handle complex board with multiple pieces', () {
        // Define piece instances once
        const whiteQueen = Queen.white;
        const blackRook = Rook.black;
        const whiteBishop = Bishop.white;
        const blackKnight = Knight.black;
        const whiteKing = King.white;

        // Define position instances once
        const d4 = Position.d4;
        const d6 = Position.d6; // Enemy piece
        const f4 = Position.f4; // Same team piece
        const b2 = Position.b2; // Enemy piece on diagonal
        const a1 = Position.a1; // Same team piece on diagonal
        const d7 = Position.d7;
        const g4 = Position.g4;

        // Set up a complex board scenario
        boardState.replace(d6 < blackRook);
        boardState.replace(f4 < whiteBishop);
        boardState.replace(b2 < blackKnight);
        boardState.replace(a1 < whiteKing);

        final validPositions = whiteQueen.validPositions(boardState, d4);

        // Should include enemy pieces for capture
        expect(validPositions, contains(d6));
        expect(validPositions, contains(b2));

        // Should not include same team pieces
        expect(validPositions, isNot(contains(f4)));
        expect(validPositions, isNot(contains(a1)));

        // Should not include squares beyond blocking pieces
        expect(validPositions, isNot(contains(d7)));
        expect(validPositions, isNot(contains(g4)));
        expect(
          validPositions,
          isNot(contains(a1)),
        ); // Should include squares before blocking pieces
        expect(validPositions, contains(Position.d5));
        expect(validPositions, contains(Position.e4));
        expect(validPositions, contains(Position.c3));
      });

      test('should handle edge cases with pieces at board boundaries', () {
        // Define piece instances once
        const whiteRook = Rook.white;
        const whitePawn = Pawn.white;
        const blackQueen = Queen.black;

        // Define position instances once
        const a1 = Position.a1; // Corner position
        const a3 = Position.a3;
        const c1 = Position.c1;
        const a2 = Position.a2;
        const b1 = Position.b1;
        const d1 = Position.d1;

        // Place pieces limiting movement
        boardState.replace(a3 < whitePawn);
        boardState.replace(c1 < blackQueen);

        final validPositions = whiteRook.validPositions(boardState, a1);

        // Should be able to move up one square and right to capture
        expect(validPositions, contains(a2));
        expect(validPositions, contains(b1));
        expect(validPositions, contains(c1)); // Capture

        // Should not include blocked positions
        expect(validPositions, isNot(contains(a3)));
        expect(validPositions, isNot(contains(d1)));

        expect(validPositions.length, equals(3));
      });
    });
    group('validPositions comprehensive tests', () {
      group('Empty board tests', () {
        test('King in center of empty board', () {
          final state = BoardState.empty();

          // Define piece instances once
          const whiteKing = King.white;

          // Define position instances once
          const e4 = Position.e4;
          const d3 = Position.d3;
          const d4 = Position.d4;
          const d5 = Position.d5;
          const e3 = Position.e3;
          const e5 = Position.e5;
          const f3 = Position.f3;
          const f4 = Position.f4;
          const f5 = Position.f5;

          final validPositions = whiteKing.validPositions(state, e4);

          // King should be able to move to all 8 adjacent squares
          expect(validPositions.length, equals(8));
          expect(
            validPositions..sort(),
            containsAll([d3, d4, d5, e3, e5, f3, f4, f5]),
          );
        });

        test('Queen in center of empty board', () {
          final state = BoardState.empty();

          // Define piece instances once
          const whiteQueen = Queen.white;

          // Define position instances once
          const d4 = Position.d4;
          const a4 = Position.a4;
          const h4 = Position.h4;
          const d1 = Position.d1;
          const d8 = Position.d8;
          const a1 = Position.a1;
          const g7 = Position.g7;
          const a7 = Position.a7;
          const g1 = Position.g1;

          final validPositions = whiteQueen.validPositions(state, d4);

          // Queen should be able to move in all 8 directions across the board
          // Test a few key positions in each direction
          expect(
            validPositions,
            containsAll([
              // Horizontal
              a4, h4,
              // Vertical
              d1, d8,
              // Diagonal
              a1, g7, a7, g1,
            ]),
          );
          expect(
            validPositions.length,
            equals(27),
          ); // 7 + 7 + 7 + 6 (3+3+3+3 diagonals)
        });

        test('Rook in center of empty board', () {
          final state = BoardState.empty();

          // Define piece instances once
          const blackRook = Rook.black;

          // Define position instances once
          const e5 = Position.e5;

          final validPositions = blackRook.validPositions(state, e5);

          // Rook should move horizontally and vertically
          expect(
            validPositions,
            containsAll([
              // Horizontal
              Position.a5, Position.h5,
              // Vertical
              Position.e1, Position.e8,
            ]),
          );
          expect(
            validPositions.length,
            equals(14),
          ); // 7 horizontal + 7 vertical
        });

        test('Bishop in center of empty board', () {
          final state = BoardState.empty();
          const bishop = Bishop.white;
          const position = Position.d4;

          final validPositions = bishop.validPositions(state, position);

          // Bishop should move diagonally
          expect(
            validPositions,
            containsAll([Position.a1, Position.g7, Position.a7, Position.g1]),
          );
          expect(validPositions.length, equals(13)); // 3+3+6+1 diagonal moves
        });

        test('Knight in center of empty board', () {
          final state = BoardState.empty();
          const knight = Knight.black;
          const position = Position.e4;

          final validPositions = knight.validPositions(state, position);

          // Knight should move in L-shapes
          expect(
            validPositions,
            containsAll([
              Position.d2,
              Position.f2,
              Position.c3,
              Position.g3,
              Position.c5,
              Position.g5,
              Position.d6,
              Position.f6,
            ]),
          );
          expect(validPositions.length, equals(8));
        });

        test('White pawn in center of empty board', () {
          final state = BoardState.empty();
          const pawn = Pawn.white;
          const position = Position.e4;

          final validPositions = pawn.validPositions(state, position);

          // White pawn should only move forward one square
          expect(validPositions, contains(Position.e5));
          expect(validPositions.length, equals(1));
        });

        test('Black pawn in center of empty board', () {
          final state = BoardState.empty();
          const pawn = Pawn.black;
          const position = Position.e5;

          final validPositions = pawn.validPositions(state, position);

          // Black pawn should only move forward one square (down)
          expect(validPositions, contains(Position.e4));
          expect(validPositions.length, equals(1));
        });

        test('White pawn on starting rank', () {
          final state = BoardState.empty();
          const pawn = Pawn.white;
          const position = Position.e2;

          final validPositions = pawn.validPositions(state, position);

          // White pawn on starting rank should move 1 or 2 squares forward
          expect(validPositions, containsAll([Position.e3, Position.e4]));
          expect(validPositions.length, equals(2));
        });

        test('Black pawn on starting rank', () {
          final state = BoardState.empty();
          const pawn = Pawn.black;
          const position = Position.d7;

          final validPositions = pawn.validPositions(state, position);

          // Black pawn on starting rank should move 1 or 2 squares forward
          expect(validPositions, containsAll([Position.d6, Position.d5]));
          expect(validPositions.length, equals(2));
        });
      });

      group('Same team piece blocking tests', () {
        test('Queen blocked by same team pieces', () {
          final state = BoardState.empty();
          // Place white queen at d4
          state.replace(Queen.white > Position.d4);
          // Place white pieces blocking some directions
          state.replace(Pawn.white > Position.d5); // Block north
          state.replace(Rook.white > Position.f4); // Block east
          state.replace(Bishop.white > Position.e5); // Block northeast

          const queen = Queen.white;
          const position = Position.d4;
          final validPositions = queen.validPositions(state, position);

          // Should not be able to move to or past blocked squares
          expect(validPositions, isNot(contains(Position.d5)));
          expect(validPositions, isNot(contains(Position.d6)));
          expect(validPositions, isNot(contains(Position.f4)));
          expect(validPositions, isNot(contains(Position.g4)));
          expect(validPositions, isNot(contains(Position.e5)));
          expect(validPositions, isNot(contains(Position.f6)));

          // Should still be able to move in unblocked directions
          expect(validPositions, contains(Position.d3));
          expect(validPositions, contains(Position.c4));
          expect(validPositions, contains(Position.e4));
        });

        test('Rook blocked by same team piece', () {
          final state = BoardState.empty();
          // Place black rook at a1
          state.replace(Rook.black > Position.a1);
          // Place black piece blocking horizontal movement
          state.replace(Knight.black > Position.d1);

          const rook = Rook.black;
          const position = Position.a1;
          final validPositions = rook.validPositions(state, position);

          // Should not be able to move to or past blocking piece
          expect(validPositions, isNot(contains(Position.d1)));
          expect(validPositions, isNot(contains(Position.e1)));

          // Should still be able to move before blocking piece and vertically
          expect(validPositions, contains(Position.b1));
          expect(validPositions, contains(Position.c1));
          expect(validPositions, contains(Position.a8));
        });

        test('Bishop blocked by same team piece', () {
          final state = BoardState.empty();
          // Place white bishop at c1
          state.replace(Bishop.white > Position.c1);
          // Place white piece blocking diagonal
          state.replace(Pawn.white > Position.e3);

          const bishop = Bishop.white;
          const position = Position.c1;
          final validPositions = bishop.validPositions(state, position);

          // Should not be able to move to or past blocking piece
          expect(validPositions, isNot(contains(Position.e3)));
          expect(validPositions, isNot(contains(Position.f4)));

          // Should still be able to move before blocking piece
          expect(validPositions, contains(Position.d2));
        });

        test('Knight not blocked by same team piece (jumps over)', () {
          final state = BoardState.empty();
          // Place black knight at e4
          state.replace(Knight.black > Position.e4);
          // Place black pieces around it
          state.replace(Pawn.black > Position.d4);
          state.replace(Rook.black > Position.e3);

          const knight = Knight.black;
          const position = Position.e4;
          final validPositions = knight.validPositions(state, position);

          // Knight should still be able to jump to most L-shaped positions
          // But not where same team pieces are already placed
          expect(validPositions, contains(Position.f6));
          expect(validPositions, contains(Position.g5));

          // Should not be able to land on squares with same team pieces
          if (validPositions.any(
            (pos) =>
                state[pos].isOccupied && state[pos].piece!.team == Team.black,
          )) {
            fail(
              'Knight should not be able to move to squares occupied by same '
              'team',
            );
          }
        });

        test('Pawn blocked by same team piece', () {
          final state = BoardState.empty();
          // Place white pawn at e2
          state.replace(Pawn.white > Position.e2);
          // Place white piece blocking forward movement
          state.replace(Bishop.white > Position.e3);

          const pawn = Pawn.white;
          const position = Position.e2;
          final validPositions = pawn.validPositions(state, position);

          // Should not be able to move forward when blocked
          expect(validPositions, isEmpty);
        });
      });

      group('Enemy piece capture tests', () {
        test('Queen can capture enemy pieces', () {
          final state = BoardState.empty();
          // Place white queen at d4
          state.replace(Queen.white > Position.d4);
          // Place black pieces in various directions
          state.replace(Pawn.black > Position.d7); // North
          state.replace(Rook.black > Position.g4); // East
          state.replace(Knight.black > Position.f6); // Northeast

          const queen = Queen.white;
          const position = Position.d4;
          final validPositions = queen.validPositions(state, position);

          // Should be able to capture enemy pieces
          expect(validPositions, contains(Position.d7));
          expect(validPositions, contains(Position.g4));
          expect(validPositions, contains(Position.f6));

          // Should not be able to move past captured pieces
          expect(validPositions, isNot(contains(Position.d8)));
          expect(validPositions, isNot(contains(Position.h4)));
          expect(validPositions, isNot(contains(Position.g7)));

          // Should still be able to move in unblocked directions
          expect(validPositions, contains(Position.d1));
          expect(validPositions, contains(Position.a4));
        });

        test('Rook can capture enemy pieces', () {
          final state = BoardState.empty();
          const rook = Rook.black;
          const rookPosition = Position.h8;
          // Place black rook at h8
          state.replace(rook > rookPosition);

          // Place white pieces to capture
          const bishopPosition = Position.h3;
          state.replace(Bishop.white > bishopPosition);
          const queenPosition = Position.c8;
          state.replace(Queen.white > queenPosition);

          final validPositions = rook.validPositions(state, rookPosition);

          // Should be able to capture enemy pieces
          expect(validPositions, contains(bishopPosition));
          expect(validPositions, contains(queenPosition));

          // Should not be able to move past captured pieces
          expect(validPositions, isNot(contains(Position.h2)));
          expect(validPositions, isNot(contains(Position.b8)));
        });

        test('Bishop can capture enemy pieces', () {
          final state = BoardState.empty();
          // Place white bishop at f1
          state.replace(Bishop.white > Position.f1);
          // Place black pieces on diagonals
          state.replace(Pawn.black > Position.h3);
          state.replace(Rook.black > Position.c4);

          const bishop = Bishop.white;
          const position = Position.f1;
          final validPositions = bishop.validPositions(state, position);

          // Should be able to capture enemy pieces
          expect(validPositions, contains(Position.h3));
          expect(validPositions, contains(Position.c4));

          // Should not be able to move past captured pieces
          expect(validPositions, isNot(contains(Position.b5)));
        });

        test('Knight can capture enemy pieces', () {
          final state = BoardState.empty();
          // Place black knight at e4
          state.replace(Knight.black > Position.e4);
          // Place white pieces at knight's target squares
          state.replace(Pawn.white > Position.f6);
          state.replace(Bishop.white > Position.c3);
          // Place black piece at another target square
          state.replace(Rook.black > Position.g5);

          const knight = Knight.black;
          const position = Position.e4;
          final validPositions = knight.validPositions(state, position);

          // Should be able to capture enemy pieces
          expect(validPositions, contains(Position.f6));
          expect(validPositions, contains(Position.c3));

          // Should not be able to move to squares with same team pieces
          expect(validPositions, isNot(contains(Position.g5)));
        });

        test('King can capture enemy pieces', () {
          final state = BoardState.empty();
          // Place white king at e4
          state.replace(King.white > Position.e4);
          // Place black pieces around
          state.replace(Pawn.black > Position.e5);
          state.replace(Rook.black > Position.f4);
          // Place white piece
          state.replace(Bishop.white > Position.d4);

          const king = King.white;
          const position = Position.e4;
          final validPositions = king.validPositions(state, position);

          // Should be able to capture enemy pieces
          expect(validPositions, contains(Position.e5));
          expect(validPositions, contains(Position.f4));

          // Should not be able to move to squares with same team pieces
          expect(validPositions, isNot(contains(Position.d4)));
        });

        test('Pawn capture behavior', () {
          final state = BoardState.empty();
          // Place white pawn at e4
          state.replace(Pawn.white > Position.e4);
          // Place black pieces diagonally (for capture)
          state.replace(Knight.black > Position.d5);
          state.replace(Bishop.black > Position.f5);
          // Place black piece directly ahead (blocks forward movement)
          state.replace(Rook.black > Position.e5);

          const pawn = Pawn.white;
          const position = Position.e4;
          final validPositions = pawn.validPositions(state, position);

          // White pawn should be able to capture diagonally
          expect(validPositions, contains(Position.d5));
          expect(validPositions, contains(Position.f5));

          // Should not be able to move forward when blocked
          expect(validPositions, isNot(contains(Position.e5)));
        });

        test('Black pawn capture behavior', () {
          final state = BoardState.empty();
          // Place black pawn at d5
          state.replace(Pawn.black > Position.d5);
          // Place white pieces diagonally (for capture)
          state.replace(Knight.white > Position.c4);
          state.replace(Queen.white > Position.e4);
          // Place white piece directly ahead (blocks forward movement)
          state.replace(Pawn.white > Position.d4);

          const pawn = Pawn.black;
          const position = Position.d5;
          final validPositions = pawn.validPositions(state, position);

          // Black pawn should be able to capture diagonally
          expect(validPositions, contains(Position.c4));
          expect(validPositions, contains(Position.e4));

          // Should not be able to move forward when blocked
          expect(validPositions, isNot(contains(Position.d4)));
        });
      });

      group('Edge cases and complex scenarios', () {
        test('King castling with valid positions', () {
          final state = BoardState.empty();

          // Define piece instances once
          const whiteKing = King.white;
          const whiteRook = Rook.white;

          // Define position instances once
          const e1 = Position.e1;
          const a1 = Position.a1;
          const h1 = Position.h1;
          const c1 = Position.c1;
          const g1 = Position.g1;
          const d1 = Position.d1;
          const f1 = Position.f1;
          const e2 = Position.e2;

          // Place white king at starting position
          state.replace(whiteKing > e1);
          // Place rooks at starting positions
          state.replace(whiteRook > a1);
          state.replace(whiteRook > h1);

          final validPositions = whiteKing.validPositions(state, e1);

          // Should include castling positions
          expect(validPositions, contains(c1)); // Queen-side castling
          expect(validPositions, contains(g1)); // King-side castling

          // Should also include normal king moves
          expect(validPositions, contains(d1));
          expect(validPositions, contains(f1));
          expect(validPositions, contains(e2));
        });
        test('King castling blocked by pieces', () {
          final state = BoardState.empty();

          // Define piece instances once
          const whiteKing = King.white;
          const whiteRook = Rook.white;
          const whiteBishop = Bishop.white;

          // Define position instances once
          const e1 = Position.e1;
          const a1 = Position.a1;
          const h1 = Position.h1;
          const f1 = Position.f1;
          const g1 = Position.g1;
          const c1 = Position.c1;

          // Place white king at starting position
          state.replace(whiteKing > e1);
          // Place rooks at starting positions
          state.replace(whiteRook > a1);
          state.replace(whiteRook > h1);
          // Block castling path
          state.replace(whiteBishop > f1);

          final validPositions = whiteKing.validPositions(state, e1);

          // Should not include blocked castling position
          expect(validPositions, isNot(contains(g1)));

          // Should still include unblocked castling
          expect(validPositions, contains(c1));
        });
        test('Pieces at board edges', () {
          final state = BoardState.empty();

          // Define piece instances once
          const blackQueen = Queen.black;

          // Define position instances once
          const a1 = Position.a1;
          const h1 = Position.h1;
          const a8 = Position.a8;
          const h8 = Position.h8;

          // Place queen at corner
          state.replace(blackQueen > a1);

          final validPositions = blackQueen.validPositions(state, a1);

          // Should be able to move along edges
          expect(validPositions, contains(h1));
          expect(validPositions, contains(a8));
          expect(validPositions, contains(h8));

          // Should have correct number of moves (7+7+7 = 21)
          expect(validPositions.length, equals(21));
        });
        test('Knight at board edges', () {
          final state = BoardState.empty();

          // Define piece instances once
          const whiteKnight = Knight.white;

          // Define position instances once
          const a1 = Position.a1;
          const b3 = Position.b3;
          const c2 = Position.c2;

          // Place knight at edge
          state.replace(whiteKnight > a1);

          final validPositions = whiteKnight.validPositions(state, a1);

          // Knight at a1 should only have 2 valid moves
          expect(validPositions, containsAll([b3, c2]));
          expect(validPositions.length, equals(2));
        });
        test('Multiple pieces creating complex blocking scenario', () {
          final state = BoardState.empty();

          // Define piece instances once
          const whiteQueen = Queen.white;
          const whitePawn = Pawn.white;
          const blackRook = Rook.black;
          const whiteBishop = Bishop.white;
          const blackKnight = Knight.black;

          // Define position instances once
          const d4 = Position.d4;
          const d6 = Position.d6;
          const f4 = Position.f4;
          const b4 = Position.b4;
          const f6 = Position.f6;
          const g4 = Position.g4;
          const g7 = Position.g7;
          const a4 = Position.a4;
          const d1 = Position.d1;

          // Place white queen at center
          state.replace(whiteQueen > d4);
          // Create a complex blocking scenario with mixed teams
          state.replace(whitePawn > d6); // Same team block
          state.replace(blackRook > f4); // Enemy capture
          state.replace(whiteBishop > b4); // Same team block
          state.replace(blackKnight > f6); // Enemy capture

          final validPositions = whiteQueen.validPositions(state, d4);

          // Should be able to capture enemies but not move past them
          expect(validPositions, contains(f4));
          expect(validPositions, isNot(contains(g4)));
          expect(validPositions, contains(f6));
          expect(validPositions, isNot(contains(g7)));

          // Should not be able to move to or past same team pieces
          expect(validPositions, isNot(contains(d6)));
          expect(validPositions, isNot(contains(b4)));
          expect(validPositions, isNot(contains(a4)));

          // Should still have valid moves in unblocked direction
          expect(validPositions, contains(d1));
        });
      });
    });
  });
}
