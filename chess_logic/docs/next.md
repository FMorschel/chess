# 🔄 Next Steps - What's Left to Address

## **High Priority:**

### 1. **God Class Pattern in GameController:**

Split responsibilities into separate classes:

#### `GameRuleEngine`

Handles special chess rules and game termination conditions:

- **Draw Conditions**:
  - 50-move rule (no pawn move or capture in 50 moves)
  - Insufficient material (K vs K, K+B vs K, etc.)
  - Stalemate detection
- **Game Termination**:
  - Checkmate detection and validation
  - Resignation and timeout handling
  - Draw by agreement
- **Special Move Rules**:
  - En passant legality and expiration
  - Castling rights management
  - Pawn promotion validation

### 2. **Thread Safety Issues:**

- Add immutable state management patterns
- Implement proper synchronization for shared mutable state
- Consider using immutable data structures

### 3. **Performance Optimizations:**

- Cache expensive move calculations
- Optimize check detection algorithms
- Reduce object creation in hot paths
