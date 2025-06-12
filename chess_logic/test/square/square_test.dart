import 'package:chess_logic/src/position/file.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/position/rank.dart';
import 'package:chess_logic/src/square/piece.dart';
import 'package:chess_logic/src/square/piece_symbol.dart';
import 'package:chess_logic/src/square/square.dart';
import 'package:chess_logic/src/team/team.dart';
import 'package:test/test.dart';

void main() {
  group('Square', () {
    late Position position;
    late Piece piece;

    setUp(() {
      position = Position(File.e, Rank.four);
      piece = Piece.fromSymbol(PieceSymbol.king, Team.white);
    });

    group('constructor', () {
      test('should create square with position only', () {
        final square = Square(position);
        expect(square.position, equals(position));
        expect(square.piece, isNull);
      });

      test('should create square with position and piece', () {
        final square = Square(position, piece);
        expect(square.position, equals(position));
        expect(square.piece, equals(piece));
      });

      test('should create square with null piece explicitly', () {
        final square = Square(position, null);
        expect(square.position, equals(position));
        expect(square.piece, isNull);
      });
    });

    group('isOccupied getter', () {
      test('should return true when piece is present', () {
        final square = Square(position, piece);
        expect(square.isOccupied, isTrue);
      });

      test('should return false when piece is null', () {
        final square = Square(position);
        expect(square.isOccupied, isFalse);
      });

      test('should return false when piece is explicitly null', () {
        final square = Square(position, null);
        expect(square.isOccupied, isFalse);
      });
    });

    group('isEmpty getter', () {
      test('should return false when piece is present', () {
        final square = Square(position, piece);
        expect(square.isEmpty, isFalse);
      });

      test('should return true when piece is null', () {
        final square = Square(position);
        expect(square.isEmpty, isTrue);
      });

      test('should return true when piece is explicitly null', () {
        final square = Square(position, null);
        expect(square.isEmpty, isTrue);
      });
    });

    group('equality operator', () {
      test('should be equal for identical squares', () {
        final square1 = Square(position, piece);
        final square2 = Square(position, piece);

        expect(square1 == square2, isTrue);
        expect(square1.hashCode == square2.hashCode, isTrue);
      });

      test('should be equal for same position and null pieces', () {
        final square1 = Square(position);
        final square2 = Square(position, null);

        expect(square1 == square2, isTrue);
        expect(square1.hashCode == square2.hashCode, isTrue);
      });

      test('should not be equal for different positions', () {
        final position2 = Position(File.a, Rank.one);
        final square1 = Square(position, piece);
        final square2 = Square(position2, piece);

        expect(square1 == square2, isFalse);
      });

      test('should not be equal for different pieces', () {
        final piece2 = Piece.fromSymbol(PieceSymbol.pawn, Team.black);
        final square1 = Square(position, piece);
        final square2 = Square(position, piece2);

        expect(square1 == square2, isFalse);
      });

      test('should not be equal when one has piece and other doesn\'t', () {
        final square1 = Square(position, piece);
        final square2 = Square(position);

        expect(square1 == square2, isFalse);
      });

      test('should be equal to itself', () {
        final square = Square(position, piece);
        expect(square == square, isTrue);
      });
    });

    group('toString', () {
      test('should include position and piece symbol for occupied square', () {
        final square = Square(position, piece);
        final result = square.toString();
        expect(result, equals('Square(e4, K)'));
      });

      test('should include position and empty for unoccupied square', () {
        final square = Square(position);
        final result = square.toString();
        expect(result, equals('Square(e4, empty)'));
      });

      test('should handle different positions correctly', () {
        final pos = Position(File.a, Rank.eight);
        final square = Square(pos);
        final result = square.toString();
        expect(result, equals('Square(a8, empty)'));
      });

      test('should handle different piece symbols correctly', () {
        final queen = Piece.fromSymbol(PieceSymbol.queen, Team.black);
        final square = Square(position, queen);
        final result = square.toString();
        expect(result, equals('Square(e4, Q)'));
      });

      test('should handle pawn correctly', () {
        final pawn = Piece.fromSymbol(PieceSymbol.pawn, Team.white);
        final square = Square(position, pawn);
        final result = square.toString();
        expect(result, equals('Square(e4, P)'));
      });
    });

    group('replacePiece', () {
      test('should create new square with replaced piece', () {
        final original = Square(position);
        final newPiece = Piece.fromSymbol(PieceSymbol.queen, Team.black);
        final result = original.replacePiece(newPiece);

        expect(result.position, equals(position));
        expect(result.piece, equals(newPiece));
        expect(result.isOccupied, isTrue);
        expect(original.piece, isNull); // Original unchanged
      });

      test('should replace existing piece with new piece', () {
        final original = Square(position, piece);
        final newPiece = Piece.fromSymbol(PieceSymbol.rook, Team.black);
        final result = original.replacePiece(newPiece);

        expect(result.position, equals(position));
        expect(result.piece, equals(newPiece));
        expect(result.isOccupied, isTrue);
        expect(original.piece, equals(piece)); // Original unchanged
      });

      test('should work with all piece types', () {
        final original = Square(position);
        final pieces = [
          Piece.fromSymbol(PieceSymbol.king, Team.white),
          Piece.fromSymbol(PieceSymbol.queen, Team.black),
          Piece.fromSymbol(PieceSymbol.rook, Team.white),
          Piece.fromSymbol(PieceSymbol.bishop, Team.black),
          Piece.fromSymbol(PieceSymbol.knight, Team.white),
          Piece.fromSymbol(PieceSymbol.pawn, Team.black),
        ];

        for (final testPiece in pieces) {
          final result = original.replacePiece(testPiece);
          expect(result.piece, equals(testPiece));
          expect(result.position, equals(position));
          expect(result.isOccupied, isTrue);
        }
      });

      test('should maintain immutability', () {
        final original = Square(position, piece);
        final newPiece = Piece.fromSymbol(PieceSymbol.pawn, Team.white);
        final result = original.replacePiece(newPiece);

        // Original should remain unchanged
        expect(original.piece, equals(piece));
        expect(original.position, equals(position));

        // Result should be different instance
        expect(result == original, isFalse);
        expect(result.piece, equals(newPiece));
        expect(result.position, equals(position));
      });
    });

    group('removePiece', () {
      test('should create new square with no piece from occupied square', () {
        final original = Square(position, piece);
        final result = original.removePiece();

        expect(result.position, equals(position));
        expect(result.piece, isNull);
        expect(result.isEmpty, isTrue);
        expect(result.isOccupied, isFalse);
        expect(original.piece, equals(piece)); // Original unchanged
      });

      test('should create new square with no piece from empty square', () {
        final original = Square(position);
        final result = original.removePiece();

        expect(result.position, equals(position));
        expect(result.piece, isNull);
        expect(result.isEmpty, isTrue);
        expect(result.isOccupied, isFalse);
        expect(original.piece, isNull); // Original unchanged
      });

      test('should maintain immutability', () {
        final original = Square(position, piece);
        final result = original.removePiece();

        // Original should remain unchanged
        expect(original.piece, equals(piece));
        expect(original.isOccupied, isTrue);

        // Result should be different instance
        expect(result == original, isFalse);
        expect(result.isEmpty, isTrue);
        expect(result.position, equals(position));
      });

      test('should create equal squares when removing from empty square', () {
        final original = Square(position);
        final result = original.removePiece();

        expect(result.position, equals(original.position));
        expect(result.piece, equals(original.piece));
        expect(result == original, isTrue); // Should be equal but different instances
      });
    });

    group('integration tests', () {
      test('should work with all piece types', () {
        final pieces = [
          Piece.fromSymbol(PieceSymbol.king, Team.white),
          Piece.fromSymbol(PieceSymbol.queen, Team.black),
          Piece.fromSymbol(PieceSymbol.rook, Team.white),
          Piece.fromSymbol(PieceSymbol.bishop, Team.black),
          Piece.fromSymbol(PieceSymbol.knight, Team.white),
          Piece.fromSymbol(PieceSymbol.pawn, Team.black),
        ];

        for (final piece in pieces) {
          final square = Square(position, piece);
          expect(square.isOccupied, isTrue);
          expect(square.isEmpty, isFalse);
          expect(square.piece, equals(piece));
        }
      });

      test('should work with all board positions', () {
        for (final file in File.values) {
          for (final rank in Rank.values) {
            final pos = Position(file, rank);
            final square = Square(pos);
            expect(square.position, equals(pos));
            expect(square.isEmpty, isTrue);
          }
        }
      });

      test('should support chess starting position squares', () {
        // Test some typical starting position squares
        final e1 = Square(
          Position(File.e, Rank.one),
          Piece.fromSymbol(PieceSymbol.king, Team.white),
        );
        final e8 = Square(
          Position(File.e, Rank.eight),
          Piece.fromSymbol(PieceSymbol.king, Team.black),
        );
        final e4 = Square(Position(File.e, Rank.four)); // Empty center

        expect(e1.isOccupied, isTrue);
        expect(e8.isOccupied, isTrue);
        expect(e4.isEmpty, isTrue);

        expect(e1.toString(), equals('Square(e1, K)'));
        expect(e8.toString(), equals('Square(e8, K)'));
        expect(e4.toString(), equals('Square(e4, empty)'));
      });

      test('should support piece movement simulation with replace/remove', () {
        // Simulate moving a piece from one square to another
        final fromSquare = Square(
          Position(File.e, Rank.two),
          Piece.fromSymbol(PieceSymbol.pawn, Team.white),
        );
        final toSquare = Square(Position(File.e, Rank.four));

        expect(fromSquare.isOccupied, isTrue);
        expect(toSquare.isEmpty, isTrue);

        // Simulate the move using replacePiece and removePiece
        final newFromSquare = fromSquare.removePiece();
        final newToSquare = toSquare.replacePiece(fromSquare.piece!);

        expect(newFromSquare.isEmpty, isTrue);
        expect(newToSquare.isOccupied, isTrue);
        expect(newToSquare.piece, equals(fromSquare.piece));
      });

      test('should support piece capture simulation', () {
        // Simulate capturing a piece
        final attackerSquare = Square(
          Position(File.d, Rank.four),
          Piece.fromSymbol(PieceSymbol.queen, Team.white),
        );
        final targetSquare = Square(
          Position(File.e, Rank.five),
          Piece.fromSymbol(PieceSymbol.pawn, Team.black),
        );

        expect(attackerSquare.isOccupied, isTrue);
        expect(targetSquare.isOccupied, isTrue);

        // Simulate the capture
        final newAttackerSquare = attackerSquare.removePiece();
        final newTargetSquare = targetSquare.replacePiece(attackerSquare.piece!);

        expect(newAttackerSquare.isEmpty, isTrue);
        expect(newTargetSquare.isOccupied, isTrue);
        expect(newTargetSquare.piece, equals(attackerSquare.piece));
      });

      test('should demonstrate method chaining possibilities', () {
        final original = Square(position, piece);
        
        // Chain operations: remove piece, then add a different piece
        final queen = Piece.fromSymbol(PieceSymbol.queen, Team.black);
        final result = original.removePiece().replacePiece(queen);

        expect(result.piece, equals(queen));
        expect(result.position, equals(position));
        expect(original.piece, equals(piece)); // Original unchanged
      });
    });
  });
}
