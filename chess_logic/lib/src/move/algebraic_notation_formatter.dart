import 'package:chess_logic/src/move/ambiguous_movement_type.dart';
import 'package:chess_logic/src/move/check.dart';
import 'package:chess_logic/src/move/move.dart';
import 'package:chess_logic/src/position/position.dart';
import 'package:chess_logic/src/utility/visitor.dart';

class AlgebraicNotationFormatter
    with Visitor<Move, AlgebraicNotationFormatter, String> {
  static const _capture = 'x';
  static const _promotion = '=';
  static const _kingsideCastling = 'O-O';
  static const _queensideCastling = '$_kingsideCastling-O';

  final _buffer = StringBuffer();

  // One method for each move type
  String formatRegularMove(Move move) {
    _buffer.write(move.moving.toAlgebraic());
    if (move.ambiguous case var ambiguous? when move is! EnPassantMove) {
      _formatAmbiguous(ambiguous, move.from);
    }
    _buffer.write(move.to.toAlgebraic());
    return _buffer.toString();
  }

  String formatRegularCaptureMove(CaptureMove move) {
    _buffer.write(move.moving.toAlgebraic());
    if (move.ambiguous case var ambiguous? when move is! EnPassantMove) {
      _formatAmbiguous(ambiguous, move.from);
    }
    _buffer.write(_capture);
    _buffer.write(move.to.toAlgebraic());
    return _buffer.toString();
  }

  String formatKingsideCastling(KingsideCastling move) {
    _buffer.write(_kingsideCastling);
    return _buffer.toString();
  }

  String formatQueensideCastling(QueensideCastling move) {
    _buffer.write(_queensideCastling);
    return _buffer.toString();
  }

  String formatEnPassantMove(EnPassantMove move) {
    _formatAmbiguous(AmbiguousMovementType.file, move.from);
    formatRegularCaptureMove(move);
    return _buffer.toString();
  }

  String formatPromotionMove(PromotionMove move) {
    formatRegularMove(move);
    _formatPromotion(move);
    return _buffer.toString();
  }

  String formatPromotionCaptureMove(PromotionCaptureMove move) {
    formatRegularCaptureMove(move);
    _formatPromotion(move);
    return _buffer.toString();
  }

  String _formatCheck(Check check) {
    _buffer.write(check.algebraic);
    return _buffer.toString();
  }

  String _formatPromotion(PromotionMove move) {
    _buffer.write(_promotion);
    _buffer.write(move.promotion.lexeme);
    return _buffer.toString();
  }

  String _formatAmbiguous(AmbiguousMovementType type, Position from) {
    (switch (type) {
      AmbiguousMovementType.file => _buffer.write(from.file.letter),
      AmbiguousMovementType.rank => _buffer.write(from.rank.value),
      AmbiguousMovementType.both => _buffer.write(from.toAlgebraic()),
    });
    return _buffer.toString();
  }

  @override
  String visit(Move visitee) {
    _buffer.clear();
    (switch (visitee) {
      EnPassantMove move => formatEnPassantMove(move),
      KingsideCastling move => formatKingsideCastling(move),
      PromotionCaptureMove move => formatPromotionCaptureMove(move),
      PromotionMove move => formatPromotionMove(move),
      QueensideCastling move => formatQueensideCastling(move),
      CaptureMove move => formatRegularCaptureMove(move),
      Move move => formatRegularMove(move),
    });
    return _formatCheck(visitee.check);
  }
}
