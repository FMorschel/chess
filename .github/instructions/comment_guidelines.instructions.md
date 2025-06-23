---
applyTo: '**.dart'
---

# Comment Guidelines

## Line Length Rules

**CRITICAL**: All comment lines MUST be less than 80 characters long. A lint will warn when this is surpassed.

## Comment References

Use comment references when convenient to link to related classes, methods, functions, extensions, etc.

**CRITICAL**: Comment references MUST exist. Do not reference a class, member, or anything that is non-existing. A lint will trigger if that happens.

**Format**: `[referencedSomething]`

**Examples:**
```dart
/// Creates a new chess piece based on the given [PieceType] and [Team].
/// 
/// The [position] parameter specifies where the piece will be placed on
/// the board. See [ChessBoard.placePiece] for placement rules.
Piece createPiece(PieceType type, Team team, Position position) {
  // Implementation
}

/// Validates if a move is legal according to chess rules.
/// 
/// Returns true if the move is valid, false otherwise. Considers:
/// - Piece movement patterns (see [Piece.getValidMoves])
/// - Board state and piece positions
/// - Special rules like castling and en passant
bool isValidMove(Move move) {
  // Implementation
}

/// The current state of the chess game.
/// 
/// Contains information about:
/// - Board layout and piece positions
/// - Active player turn (see [Team])
/// - Game history and move log
/// - Check/checkmate status
class GameState {
  // Implementation
}
```

## Best Practices

### 1. **Line Breaking**
Break long comments into multiple lines, each under 80 characters from the line start:

**❌ Incorrect:**
```dart
/// This is a very long comment that exceeds the 80-character limit and should be broken into multiple lines
```

```dart
        /// This is a long comment that exceeds the 80-character limit and should be broken into multiple lines
```

**✅ Correct:**
```dart
/// This is a very long comment that exceeds the 80-character limit
/// and should be broken into multiple lines
```

```dart
        /// This is a long comment that exceeds the 80-character limit and
        /// should be broken into multiple lines when the last word
        /// surpasses the limit
```

### 2. **Reference Usage**
Use references to connect related concepts:

**❌ Less clear:**
```dart
/// Moves a piece from one position to another position on the board
```

**✅ More clear:**
```dart
/// Moves a piece from one [Position] to another on the [ChessBoard]
```

### 3. **Documentation Structure**
For complex methods, structure comments clearly:

```dart
/// Calculates all possible moves for the given piece.
/// 
/// Takes into account:
/// - Current board state (see [BoardState])
/// - Piece-specific movement rules
/// - Blocking pieces and capture opportunities
/// - Special moves like castling (see [CastlingMove])
/// 
/// Returns a list of valid [Move] objects.
List<Move> calculatePossibleMoves(Piece piece) {
  // Implementation
}
```

### 4. **Inline Comments**
Keep inline comments concise and under 80 characters whenever possible:

```dart
// Check if king is in check after this move
if (wouldExposeKing(move)) {
  return false; // Invalid move - exposes king
}
```

## Comment Types

### 1. **Class Documentation**
```dart
/// Represents a chess piece with its type and team.
///
/// Each piece knows its movement rules and can calculate valid moves
/// based on the current [BoardState]. See [PieceType] for available
/// piece types.
class Piece {
  // Implementation
}
```

### 2. **Method Documentation**
```dart
/// Checks if the given move puts the player's own king in check.
/// 
/// This is used to validate move legality, as players cannot make
/// moves that would expose their king to attack.
bool wouldExposeKing(Move move) {
  // Implementation
}
```

### 3. **Field/Property Documentation**
```dart
/// Position of this square on the board
final Position position;

/// Team that owns this piece (white or black)
final Team team;
```

### 4. **Getter/Setter Documentation**

Getter documentation should describe what the property **is**, not what it **returns**.

**❌ Incorrect:**
```dart
/// Returns the list of teams in the game
List<Team> get teams => _teams;

/// Returns true if the square is occupied
bool get isOccupied => piece != null;
```

**✅ Correct:**
```dart
/// List of teams in the game
List<Team> get teams => _teams;

/// True if the square is occupied
bool get isOccupied => piece != null;
```

This makes the documentation read more naturally, as getters represent properties/values rather than computed functions.

### 5. **Inline Code Comments**
```dart
void executeMove(Move move) {
  // Validate move before execution
  if (!isValidMove(move)) {
    throw IllegalMoveException('Invalid move: $move');
  }
  
  // Update board state
  _updateBoardState(move);
  
  // Switch active player
  _switchTurn();
}
```

## Special Cases

### 1. **Long URLs or References**
When including long URLs, break them appropriately:

```dart
/// Chess rules reference:
/// https://www.fide.com/FIDE/handbook/LawsOfChess.pdf
/// Section 3.1 covers piece movement
```

### 2. **Code Examples in Comments**
Keep code examples concise:

```dart
/// Usage example:
/// ```dart
/// final move = Move(from: a1, to: a8);
/// board.executeMove(move);
/// ```
```

### 3. **Multi-line Lists**
Format lists clearly within the 80-character limit:

```dart
/// Supported piece types:
/// - [King]: Moves one square in any direction
/// - [Queen]: Combines rook and bishop movement
/// - [Rook]: Moves horizontally and vertically
/// - [Bishop]: Moves diagonally
/// - [Knight]: Moves in L-shape pattern
/// - [Pawn]: Moves forward, captures diagonally
```
