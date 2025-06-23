---
applyTo: '**.dart'
---

# Class Structure

## Ordering of members

**Empty Line Rules:**
- **CRITICAL**: Between different member types (constructors → fields → methods → getters, etc), there MUST always be empty lines
- **CRITICAL**: If a member has annotations or comments before it, there MUST also be an empty line before the member annotation and/or comment
- **CRITICAL**: Between individual getters/setters/methods that have documentation comments, there MUST be empty lines before each comment
- **CRITICAL**: All field/variable declarations MUST be on individual lines (lint diagnostic if not followed)
- Before methods there MUST always be an empty line, even if there are no comments or annotations
- Also use empty lines to separate groups of setters/getters that represent the same field from others setters/getters
- The only exception is when the member is the first in the class, in which case it should NOT have an empty line before it
- **For enhanced enums, there MUST always be an empty line after the last enum constant**
- **No comments should be used to identify different types of members** - only empty lines for separation

**Example of correct empty line usage:**
```dart
class Example {
  // 1. Constructors (no empty line before first member)
  Example();
  
  factory Example.create();
  
  // 2. Fields (empty line before different member type, individual lines)
  final String name;
  final int value;
  
  // 3. Methods (empty line before different member type)
  void doSomething() {}
  
  // 4. Getters (empty line before different member type)
  /// Description of first getter
  String get description => name;

  /// Description of second getter (empty line before comment)
  int get length => value;

  /// Description of third getter (empty line before comment)
  bool get isValid => name.isNotEmpty;
}
```

**❌ Incorrect field declarations (multiple on same line):**
```dart
final String name; final int value;
```

**✅ Correct field declarations (individual lines):**
```dart
final String name;
final int value;
```

1. Constructors (**unnamed constructors MUST come first**, then named constructors - factory constructors follow the same rule based on whether they are unnamed or named)
2. Static fields (ordered as described below)
3. Instance fields (ordered as described below)

**Field Ordering Rules:**
- **Static fields MUST come before instance fields** (with empty line between them)
- Within each group (static/instance), order by modifiers: **const (only static) -> final → late final → late → regular (no modifier)**
- Within each modifier group, order by: **public non-null → private non-null → public nullable → private nullable**
- **Empty lines MUST separate different modifier groups** within static/instance categories

**Field ordering example:**
```dart
class Example {
  // Static const public non-null
  static const String staticFinalPublicNonNull = 'value';
  static const int staticFinalPublicNonNull2 = 42;
  // Static const private non-null
  static const String _staticFinalPrivateNonNull = 'value';
  // Static const public nullable
  static const String? staticFinalPublicNullable = null;
  // Static const private nullable
  static const String? _staticFinalPrivateNullable = null;

  // Static final public non-null
  static final String staticFinalPublicNonNull = 'value';
  static final int staticFinalPublicNonNull2 = 42;
  // Static final private non-null
  static final String _staticFinalPrivateNonNull = 'value';
  // Static final public nullable
  static final String? staticFinalPublicNullable = null;
  // Static final private nullable
  static final String? _staticFinalPrivateNullable = null;

  // Static late final public non-null
  static late final String staticLateFinalPublicNonNull;
  // Static late final private non-null
  static late final String _staticLateFinalPrivateNonNull;
  // Static late final public nullable
  static late final String? staticLateFinalPublicNullable;
  // Static late final private nullable
  static late final String? _staticLateFinalPrivateNullable;

  // Static late public non-null
  static late String staticLatePublicNonNull;
  // Static late private non-null
  static late String _staticLatePrivateNonNull;
  // Static late public nullable
  static late String? staticLatePublicNullable;
  // Static late private nullable
  static late String? _staticLatePrivateNullable;

  // Instance final public non-null
  final String instanceFinalPublicNonNull;
  final int instanceFinalPublicNonNull2;
  // Instance final private non-null
  final String _instanceFinalPrivateNonNull;
  // Instance final public nullable
  final String? instanceFinalPublicNullable;
  // Instance final private nullable
  final String? _instanceFinalPrivateNullable;

  // Instance late final public non-null
  late final String instanceLateFinalPublicNonNull;
  // Instance late final private non-null
  late final String _instanceLateFinalPrivateNonNull;
  // Instance late final public nullable
  late final String? instanceLateFinalPublicNullable;
  // Instance late final private nullable
  late final String? _instanceLateFinalPrivateNullable;

  // Instance late public non-null
  late String instanceLatePublicNonNull;
  // Instance late private non-null
  late String _instanceLatePrivateNonNull;
  // Instance late public nullable
  late String? instanceLatePublicNullable;
  // Instance late private nullable
  late String? _instanceLatePrivateNullable;

  // Instance public non-null
  String instancePublicNonNull = '';
  // Instance private non-null
  String _instanceLatePrivateNonNull = '';
  // Instance public nullable
  String? instanceLatePublicNullable = null;
  // Instance private nullable
  String? _instanceLatePrivateNullable = null;
}
```
4. Static getters/setters (pair should be coupled together with setters first)
5. Static methods
6. Instance methods
7. Operators
8. Instance getters/setters (pair should be coupled together with setters first)

Overriden members should be placed after new members of the same type.
Underscore members (private) should be placed after public members of the same type.

**Interdependent members should ALMOST ALWAYS be grouped together by their dependencies and calling order**, from the most general to the most specific and in the calling order that they are called in the more general member. **The member that calls other members should come BEFORE the members it calls** (e.g., if `pieces` getter calls `pawn`, `rook`, etc., then `pieces` should be placed before `pawn`, `rook`, etc.). Only use alphabetical order when the class is extremely long (50+ members) and interdependency becomes too complex to manage.
