/// Represents the symbol and properties of chess pieces.
///
/// Each piece type has a lexeme (letter representation) and a flag
/// indicating whether it can be promoted to during pawn promotion.
enum PieceSymbol {
  king('K', canPromoteTo: false),
  queen('Q'),
  rook('R'),
  bishop('B'),
  knight('N'),
  pawn('P', canPromoteTo: false);

  const PieceSymbol(this.lexeme, {this.canPromoteTo = true});

  /// Creates a [PieceSymbol] from its string representation.
  factory PieceSymbol.fromLexeme(String lexeme) {
    return PieceSymbol.values.firstWhere(
      (symbol) => symbol.lexeme == lexeme,
      orElse: () => throw ArgumentError('Invalid piece symbol: $lexeme'),
    );
  }

  /// String representation of the piece symbol
  final String lexeme;

  /// Whether this piece type can be promoted to during pawn promotion
  final bool canPromoteTo;

  /// List of piece symbols that pawns can promote to
  static List<PieceSymbol> get promotionSymbols {
    return PieceSymbol.values.where((s) => s.canPromoteTo).toList();
  }
}
