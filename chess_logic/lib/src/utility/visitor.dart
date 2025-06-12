mixin Visitee<
  In extends Visitor<Ref, In, dynamic>,
  Ref extends Visitee<In, Ref>
> {
  /// Accepts a visitor and allows it to perform an operation on this object.
  void accept(In visitor);
}

mixin Visitor<
  In extends Visitee<Ref, In>,
  Ref extends Visitor<In, Ref, Out>,
  Out
> {
  /// Visits the given visitee and performs an operation on it.
  Out? visit(In visitee);
}
