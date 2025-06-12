enum PieceSymbol {
  king('K', canPromoteTo: false),
  queen('Q'),
  rook('R'),
  bishop('B'),
  knight('N'),
  pawn('P', canPromoteTo: false);

  const PieceSymbol(this.lexeme, {this.canPromoteTo = true});

  factory PieceSymbol.fromLexeme(String lexeme) {
    return PieceSymbol.values.firstWhere(
      (symbol) => symbol.lexeme == lexeme,
      orElse: () => throw ArgumentError('Invalid piece symbol: $lexeme'),
    );
  }

  final String lexeme;
  final bool canPromoteTo;

  static List<PieceSymbol> get promotionSymbols {
    return PieceSymbol.values.where((s) => s.canPromoteTo).toList();
  }
}
