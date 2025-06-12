import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/square/piece_value.dart';
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
      final king = King(Team.white);
      expect(king.symbol, equals(PieceSymbol.king));
      expect(king.value, equals(PieceValue.king.points));
      expect(king.value, equals(0));
    });

    test('should have correct algebraic notation', () {
      final king = King(Team.white);
      expect(king.toAlgebraic(), equals('K'));
    });

    test('should have correct string representation', () {
      final king = King(Team.black);
      expect(king.toString(), equals('king'));
    });

    test('should preserve team', () {
      final whiteKing = King(Team.white);
      final blackKing = King(Team.black);
      expect(whiteKing.team, equals(Team.white));
      expect(blackKing.team, equals(Team.black));
    });

    test('should not be a promotion piece', () {
      final king = King(Team.white);
      expect(king, isNot(isA<PromotionPiece>()));
    });
  });

  group('Queen', () {
    test('should have correct symbol and value', () {
      final queen = Queen(Team.white);
      expect(queen.symbol, equals(PieceSymbol.queen));
      expect(queen.value, equals(PieceValue.queen.points));
      expect(queen.value, equals(9));
    });

    test('should have correct algebraic notation', () {
      final queen = Queen(Team.white);
      expect(queen.toAlgebraic(), equals('Q'));
    });

    test('should have correct string representation', () {
      final queen = Queen(Team.black);
      expect(queen.toString(), equals('queen'));
    });

    test('should be a promotion piece', () {
      final queen = Queen(Team.white);
      expect(queen, isA<PromotionPiece>());
    });
  });

  group('Rook', () {
    test('should have correct symbol and value', () {
      final rook = Rook(Team.white);
      expect(rook.symbol, equals(PieceSymbol.rook));
      expect(rook.value, equals(PieceValue.rook.points));
      expect(rook.value, equals(5));
    });

    test('should have correct algebraic notation', () {
      final rook = Rook(Team.white);
      expect(rook.toAlgebraic(), equals('R'));
    });

    test('should have correct string representation', () {
      final rook = Rook(Team.black);
      expect(rook.toString(), equals('rook'));
    });

    test('should be a promotion piece', () {
      final rook = Rook(Team.white);
      expect(rook, isA<PromotionPiece>());
    });
  });

  group('Bishop', () {
    test('should have correct symbol and value', () {
      final bishop = Bishop(Team.white);
      expect(bishop.symbol, equals(PieceSymbol.bishop));
      expect(bishop.value, equals(PieceValue.bishop.points));
      expect(bishop.value, equals(3));
    });

    test('should have correct algebraic notation', () {
      final bishop = Bishop(Team.white);
      expect(bishop.toAlgebraic(), equals('B'));
    });

    test('should have correct string representation', () {
      final bishop = Bishop(Team.black);
      expect(bishop.toString(), equals('bishop'));
    });

    test('should be a promotion piece', () {
      final bishop = Bishop(Team.white);
      expect(bishop, isA<PromotionPiece>());
    });
  });

  group('Knight', () {
    test('should have correct symbol and value', () {
      final knight = Knight(Team.white);
      expect(knight.symbol, equals(PieceSymbol.knight));
      expect(knight.value, equals(PieceValue.knight.points));
      expect(knight.value, equals(3));
    });

    test('should have correct algebraic notation', () {
      final knight = Knight(Team.white);
      expect(knight.toAlgebraic(), equals('N'));
    });

    test('should have correct string representation', () {
      final knight = Knight(Team.black);
      expect(knight.toString(), equals('knight'));
    });

    test('should be a promotion piece', () {
      final knight = Knight(Team.white);
      expect(knight, isA<PromotionPiece>());
    });
  });

  group('Pawn', () {
    test('should have correct symbol and value', () {
      final pawn = Pawn(Team.white);
      expect(pawn.symbol, equals(PieceSymbol.pawn));
      expect(pawn.value, equals(PieceValue.pawn.points));
      expect(pawn.value, equals(1));
    });

    test('should have empty algebraic notation', () {
      final pawn = Pawn(Team.white);
      expect(pawn.toAlgebraic(), equals(''));
    });

    test('should have correct string representation', () {
      final pawn = Pawn(Team.black);
      expect(pawn.toString(), equals('pawn'));
    });

    test('should preserve team', () {
      final whitePawn = Pawn(Team.white);
      final blackPawn = Pawn(Team.black);
      expect(whitePawn.team, equals(Team.white));
      expect(blackPawn.team, equals(Team.black));
    });

    test('should not be a promotion piece', () {
      final pawn = Pawn(Team.white);
      expect(pawn, isNot(isA<PromotionPiece>()));
    });
  });

  group('PromotionPiece', () {
    test('should include Queen, Rook, Bishop, and Knight', () {
      final queen = Queen(Team.white);
      final rook = Rook(Team.white);
      final bishop = Bishop(Team.white);
      final knight = Knight(Team.white);

      expect(queen, isA<PromotionPiece>());
      expect(rook, isA<PromotionPiece>());
      expect(bishop, isA<PromotionPiece>());
      expect(knight, isA<PromotionPiece>());
    });

    test('should not include King and Pawn', () {
      final king = King(Team.white);
      final pawn = Pawn(Team.white);

      expect(king, isNot(isA<PromotionPiece>()));
      expect(pawn, isNot(isA<PromotionPiece>()));
    });
  });

  group('piece equality and identity', () {
    test(
      'different pieces with same type and team should be equal instances',
      () {
        final king1 = King(Team.white);
        final king2 = King(Team.white);

        // They are different instances but same type and team
        expect(identical(king1, king2), isFalse);
        expect(king1.runtimeType, equals(king2.runtimeType));
        expect(king1.team, equals(king2.team));
      },
    );

    test(
      'same piece type with different teams should have different teams',
      () {
        final whiteQueen = Queen(Team.white);
        final blackQueen = Queen(Team.black);

        expect(whiteQueen.team, isNot(equals(blackQueen.team)));
        expect(whiteQueen.symbol, equals(blackQueen.symbol));
        expect(whiteQueen.value, equals(blackQueen.value));
      },
    );
  });

  group('piece hierarchy', () {
    test('all pieces should inherit from Piece', () {
      final pieces = [
        King(Team.white),
        Queen(Team.white),
        Rook(Team.white),
        Bishop(Team.white),
        Knight(Team.white),
        Pawn(Team.white),
      ];

      for (final piece in pieces) {
        expect(piece, isA<Piece>());
      }
    });

    test('promotion pieces should have promotion symbol correspondence', () {
      final promotionPieces = [
        Queen(Team.white),
        Rook(Team.white),
        Bishop(Team.white),
        Knight(Team.white),
      ];

      final promotionSymbols = PieceSymbol.promotionSymbols;

      for (final piece in promotionPieces) {
        expect(promotionSymbols, contains(piece.symbol));
      }
    });
  });

  group('piece values', () {
    test('should match corresponding PieceValue enum values', () {
      final king = King(Team.white);
      final queen = Queen(Team.white);
      final rook = Rook(Team.white);
      final bishop = Bishop(Team.white);
      final knight = Knight(Team.white);
      final pawn = Pawn(Team.white);

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
        final piece1 = King(Team.white);
        final piece2 = King(Team.white);

        expect(piece1 == piece2, isTrue);
        expect(piece1, equals(piece2));
      });

      test('should have same hashCode', () {
        final piece1 = Queen(Team.black);
        final piece2 = Queen(Team.black);

        expect(piece1.hashCode, equals(piece2.hashCode));
      });

      test('should work for all piece types', () {
        final whitePieces1 = [
          King(Team.white),
          Queen(Team.white),
          Rook(Team.white),
          Bishop(Team.white),
          Knight(Team.white),
          Pawn(Team.white),
        ];

        final whitePieces2 = [
          King(Team.white),
          Queen(Team.white),
          Rook(Team.white),
          Bishop(Team.white),
          Knight(Team.white),
          Pawn(Team.white),
        ];

        for (int i = 0; i < whitePieces1.length; i++) {
          expect(whitePieces1[i], equals(whitePieces2[i]));
          expect(whitePieces1[i].hashCode, equals(whitePieces2[i].hashCode));
        }
      });
    });

    group('same piece type with different teams', () {
      test('should not be equal', () {
        final whiteKing = King(Team.white);
        final blackKing = King(Team.black);

        expect(whiteKing == blackKing, isFalse);
        expect(whiteKing, isNot(equals(blackKing)));
      });

      test('should have different hashCodes', () {
        final whiteQueen = Queen(Team.white);
        final blackQueen = Queen(Team.black);

        expect(whiteQueen.hashCode, isNot(equals(blackQueen.hashCode)));
      });

      test('should work for all piece types', () {
        final whitePieces = [
          King(Team.white),
          Queen(Team.white),
          Rook(Team.white),
          Bishop(Team.white),
          Knight(Team.white),
          Pawn(Team.white),
        ];

        final blackPieces = [
          King(Team.black),
          Queen(Team.black),
          Rook(Team.black),
          Bishop(Team.black),
          Knight(Team.black),
          Pawn(Team.black),
        ];

        for (int i = 0; i < whitePieces.length; i++) {
          expect(whitePieces[i], isNot(equals(blackPieces[i])));
        }
      });
    });

    group('different piece types with same team', () {
      test('should not be equal', () {
        final Piece king = King(Team.white);
        final Piece queen = Queen(Team.white);

        expect(king == queen, isFalse);
        expect(king, isNot(equals(queen)));
      });

      test('should have different hashCodes', () {
        final rook = Rook(Team.black);
        final bishop = Bishop(Team.black);

        expect(rook.hashCode, isNot(equals(bishop.hashCode)));
      });

      test('should work for various combinations', () {
        final pieces = [
          King(Team.white),
          Queen(Team.white),
          Rook(Team.white),
          Bishop(Team.white),
          Knight(Team.white),
          Pawn(Team.white),
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
        final piece = Knight(Team.white);

        expect(piece == piece, isTrue);
        expect(piece, equals(piece));
        expect(identical(piece, piece), isTrue);
      });

      test('should have consistent hashCode', () {
        final piece = Bishop(Team.black);
        final hashCode1 = piece.hashCode;
        final hashCode2 = piece.hashCode;

        expect(hashCode1, equals(hashCode2));
      });
    });
    group('equality with null and other types', () {
      test('should not be equal to null', () {
        final piece = Pawn(Team.white);

        expect(piece, isNot(equals(null)));
      });

      test('should not be equal to different types', () {
        final piece = Queen(Team.black);

        expect(piece, isNot(equals("queen")));
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
          King(Team.white),
          Queen(Team.black),
          Rook(Team.white),
          Bishop(Team.black),
          Knight(Team.white),
          Pawn(Team.black),
        ];

        for (final piece in pieces) {
          expect(piece == piece, isTrue);
        }
      });

      test('should be symmetric (a == b implies b == a)', () {
        final piece1 = Knight(Team.white);
        final piece2 = Knight(Team.white);

        expect(piece1 == piece2, equals(piece2 == piece1));
      });

      test('should be transitive (a == b and b == c implies a == c)', () {
        final piece1 = Rook(Team.black);
        final piece2 = Rook(Team.black);
        final piece3 = Rook(Team.black);

        expect(piece1 == piece2, isTrue);
        expect(piece2 == piece3, isTrue);
        expect(piece1 == piece3, isTrue);
      });
    });

    group('hashCode contract', () {
      test('equal objects should have equal hashCodes', () {
        final piece1 = Queen(Team.white);
        final piece2 = Queen(Team.white);

        expect(piece1 == piece2, isTrue);
        expect(piece1.hashCode, equals(piece2.hashCode));
      });

      test('hashCode should be consistent across multiple calls', () {
        final piece = King(Team.black);
        final hashCodes = List.generate(10, (_) => piece.hashCode);

        expect(hashCodes.every((hash) => hash == hashCodes.first), isTrue);
      });

      test('different pieces should generally have different hashCodes', () {
        final pieces = [
          King(Team.white),
          Queen(Team.white),
          Rook(Team.white),
          Bishop(Team.white),
          Knight(Team.white),
          Pawn(Team.white),
          King(Team.black),
          Queen(Team.black),
          Rook(Team.black),
          Bishop(Team.black),
          Knight(Team.black),
          Pawn(Team.black),
        ];

        final hashCodes = pieces.map((p) => p.hashCode).toSet();

        // While not guaranteed, different pieces should generally have different hash codes
        expect(hashCodes.length, greaterThan(1));
      });
    });

    group('Set and Map behavior', () {
      test('should work correctly in Sets', () {
        final piece1 = Bishop(Team.white);
        final piece2 = Bishop(Team.white);
        final piece3 = Bishop(Team.black);

        final set = {piece1, piece2, piece3};

        expect(set.length, equals(2)); // piece1 and piece2 are equal
        expect(set.contains(piece1), isTrue);
        expect(set.contains(piece2), isTrue);
        expect(set.contains(piece3), isTrue);
      });

      test('should work correctly as Map keys', () {
        final piece1 = Pawn(Team.white);
        final piece2 = Pawn(Team.white);
        final piece3 = Pawn(Team.black);

        final map = <Piece, String>{piece1: 'white pawn', piece3: 'black pawn'};

        expect(map[piece1], equals('white pawn'));
        expect(map[piece2], equals('white pawn')); // piece1 == piece2
        expect(map[piece3], equals('black pawn'));
        expect(map.length, equals(2));
      });
    });
  });
}
