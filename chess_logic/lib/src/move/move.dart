import 'package:equatable/equatable.dart';

import '../controller/capture.dart';
import '../position/direction.dart';
import '../position/file.dart';
import '../position/position.dart';
import '../square/piece.dart';
import '../square/piece_symbol.dart';
import '../team/team.dart';
import '../utility/visitor.dart';
import 'algebraic_notation_formatter.dart';
import 'ambiguous_movement_type.dart';
import 'check.dart';

part 'bishop_move.dart';
part 'king_move.dart';
part 'knight_move.dart';
part 'pawn_move.dart';
part 'queen_move.dart';
part 'rook_move.dart';

/// Regular move of a piece from one square to another
sealed class Move<P extends Piece> extends Equatable
    with Visitee<AlgebraicNotationFormatter, Move> {
  factory Move.create({
    required P moving,
    required Position from,
    required Position to,
    Check check = Check.none,
    AmbiguousMovementType? ambiguous,
  }) {
    return switch (moving) {
          King() => KingMove(from: from, to: to, moving: moving, check: check),
          Queen() => QueenMove(
            from: from,
            to: to,
            moving: moving,
            check: check,
            ambiguous: ambiguous,
          ),
          Rook() => RookMove(
            from: from,
            to: to,
            moving: moving,
            check: check,
            ambiguous: ambiguous,
          ),
          Bishop() => BishopMove(
            from: from,
            to: to,
            moving: moving,
            check: check,
            ambiguous: ambiguous,
          ),
          Knight() => KnightMove(
            from: from,
            to: to,
            moving: moving,
            check: check,
            ambiguous: ambiguous,
          ),
          Pawn() => PawnMove(
            from: from,
            to: to,
            moving: moving,
            check: check,
            ambiguous: ambiguous,
          ),
          _ => Move.create(moving: moving, from: from, to: to),
        }
        as Move<P>;
  }

  const Move.base({
    required this.from,
    required this.to,
    required this.moving,
    this.check = Check.none,
    this.ambiguous,
  }) : assert(
         from != to,
         'Move must be from a different square (from: $from, to: $to)',
       );

  static final _algebraicRegex = RegExp(
    '^(([QRBNK]?([a-h]?[1-8]?)?(x)?([a-h][1-8])(=[QRBN])?)|(O-O)|(O-O-O))([+#]'
    r')?$',
  );

  static final _visitor = AlgebraicNotationFormatter();

  final Position from;
  final Position to;
  final P moving;
  final Check check;
  final AmbiguousMovementType? ambiguous;

  static Move<P> fromAlgebraic<P extends Piece, C extends Piece>(
    String algebraic,
    Team team, {
    required C? Function(Position position) pieceAt,
    required Pawn? Function({required Position from, required Position to})
    enpassant,
    required Position Function({
      required Piece piece,
      required Position to,
      required AmbiguousPosition? ambiguous,
    })
    pieceOrigin,
  }) {
    final match = _algebraicRegex.firstMatch(algebraic);
    if (match == null) {
      throw ArgumentError.value(
        algebraic,
        'algebraic',
        'Invalid algebraic notation format',
      );
    }
    final pieceSymbol = match.group(2);
    final ambiguous = match.group(3);
    final capture = match.group(4);
    final to = Position.fromAlgebraic(match.group(5)!);
    var promotion = match.group(6);
    final queenCastling = match.group(7);
    final kingCastling = match.group(8);
    final check = Check.fromAlgebraic(match.group(9) ?? '');

    if (queenCastling != null) {
      return KingMove.queensideCastling(
            king: King(team),
            from: Position(File.e, team.homeRank),
            to: Position(File.c, team.homeRank),
            rook: RookMove(
              from: Position(File.a, team.homeRank),
              to: Position(File.d, team.homeRank),
              moving: Rook(team),
              check: check,
            ),
            check: check,
          )
          as Move<P>;
    }

    if (kingCastling != null) {
      return KingMove.kingsideCastling(
            king: King(team),
            from: Position(File.e, team.homeRank),
            to: Position(File.g, team.homeRank),
            rook: RookMove(
              from: Position(File.h, team.homeRank),
              to: Position(File.f, team.homeRank),
              moving: Rook(team),
              check: check,
            ),
            check: check,
          )
          as Move<P>;
    }

    AmbiguousPosition? ambiguousPosition;
    if (ambiguous != null && ambiguous.isNotEmpty) {
      ambiguousPosition = AmbiguousPosition.fromAlgebraic(ambiguous);
    }

    Piece movingPiece;
    if (pieceSymbol != null) {
      movingPiece = Piece.fromSymbol(PieceSymbol.fromLexeme(pieceSymbol), team);
    } else {
      movingPiece = Pawn(team);
    }

    C? captured;
    if (capture != null) {
      captured = pieceAt(to);
    }

    final from = pieceOrigin(
      piece: movingPiece,
      to: to,
      ambiguous: ambiguousPosition,
    );

    PieceSymbol? promotionSymbol;
    if (promotion != null && promotion.isNotEmpty) {
      if (promotion.startsWith('=')) {
        promotion = promotion.substring(1);
      }
      promotionSymbol = PieceSymbol.fromLexeme(promotion);
      switch (promotionSymbol) {
        case PieceSymbol.pawn || PieceSymbol.king:
          throw ArgumentError.value(
            promotion,
            'promotion',
            'Pawn cannot be promoted to a ${promotionSymbol.name}',
          );
        default:
          break;
      }
    }

    if (capture != null) {
      if (captured == null) {
        if (movingPiece is Pawn ? enpassant(from: from, to: to) : null
            case final pawn? when movingPiece is Pawn) {
          return PawnMove.enPassant(
                captured: pawn,
                pawn: movingPiece,
                to: to,
                from: from,
                check: check,
              )
              as Move<P>;
        }
        throw ArgumentError.value(
          algebraic,
          'algebraic',
          'Capture move without a captured piece at the destination',
        );
      }

      if (movingPiece is Pawn && promotionSymbol != null) {
        PromotionCaptureMove(
          moving: movingPiece,
          from: from,
          to: to,
          captured: captured,
          promotion: promotionSymbol,
          check: check,
        );
      }

      return CaptureMove.create(
        moving: movingPiece as P,
        captured: captured,
        from: from,
        to: to,
        check: check,
        ambiguous: ambiguousPosition?.ambiguousMovementType,
      );
    }

    return Move.create(
      moving: movingPiece as P,
      from: from,
      to: to,
      check: check,
      ambiguous: ambiguousPosition?.ambiguousMovementType,
    );
  }

  static CaptureMove<P, C> capture<P extends Piece, C extends Piece>({
    required P moving,
    required Position from,
    required Position to,
    required C captured,
    Check check = Check.none,
    AmbiguousMovementType? ambiguous,
  }) => CaptureMove<P, C>.create(
    moving: moving,
    from: from,
    to: to,
    captured: captured,
    check: check,
    ambiguous: ambiguous,
  );

  @override
  String accept(AlgebraicNotationFormatter visitor) {
    return visitor.visit(this);
  }

  String toAlgebraic() => accept(_visitor);

  @override
  String toString() => toAlgebraic();

  /// Creates a copy of this move with the given parameters.
  ///
  /// This method is used to create a new instance of the move with modified
  /// properties ([Move.check] or [Move.ambiguous]). It is useful for fixing
  /// these properties after the move has been created.
  Move<P> copyWith({Check? check, AmbiguousMovementType? ambiguous});

  /// The team that is making the move.
  Team get team => moving.team;

  @override
  List<Object?> get props => [from, to, moving, check];
}

/// Regular move of a piece from one square to another with a capture
sealed class CaptureMove<P extends Piece, C extends Piece> extends Move<P> {
  CaptureMove.base({
    required this.captured,
    required super.from,
    required super.to,
    required super.moving,
    super.check,
    super.ambiguous,
  }) : assert(
         captured.team != moving.team,
         'Captured piece must be from a different team',
       ),
       super.base();

  factory CaptureMove.create({
    required P moving,
    required C captured,
    required Position from,
    required Position to,
    Check check = Check.none,
    AmbiguousMovementType? ambiguous,
  }) {
    return switch (moving) {
          King() => KingCaptureMove<C>(
            moving: moving,
            captured: captured,
            from: from,
            to: to,
            check: check,
          ),
          Queen() => QueenCaptureMove<C>(
            moving: moving,
            captured: captured,
            from: from,
            to: to,
            check: check,
            ambiguous: ambiguous,
          ),
          Rook() => RookCaptureMove<C>(
            moving: moving,
            captured: captured,
            from: from,
            to: to,
            check: check,
            ambiguous: ambiguous,
          ),
          Bishop() => BishopCaptureMove<C>(
            moving: moving,
            captured: captured,
            from: from,
            to: to,
            check: check,
            ambiguous: ambiguous,
          ),
          Knight() => KnightCaptureMove<C>(
            moving: moving,
            captured: captured,
            from: from,
            to: to,
            check: check,
            ambiguous: ambiguous,
          ),
          Pawn() => PawnCaptureMove<C>(
            moving: moving,
            captured: captured,
            from: from,
            to: to,
            check: check,
          ),
          _ => CaptureMove<P, C>.create(
            moving: moving,
            captured: captured,
            from: from,
            to: to,
            check: check,
            ambiguous: ambiguous,
          ),
        }
        as CaptureMove<P, C>;
  }

  final C captured;

  late final capturedPosition = to;
  late final _capture = Capture<P, C>(this);

  Capture<P, C> asCapture() => _capture;

  @override
  CaptureMove<P, C> copyWith({Check? check, AmbiguousMovementType? ambiguous});

  @override
  List<Object?> get props => [...super.props, captured];
}
