enum Check implements Comparable<Check> {
  none(''),
  check('+'),
  checkmate('#');

  const Check(this.algebraic);

  factory Check.fromAlgebraic(String algebraic) {
    return Check.values.firstWhere(
      (check) => check.algebraic == algebraic,
      orElse: () => throw ArgumentError.value(
        algebraic,
        'algebraic',
        'Invalid check algebraic notation: "$algebraic"',
      ),
    );
  }

  final String algebraic;

  @override
  int compareTo(Check other) => index.compareTo(other.index);
}
