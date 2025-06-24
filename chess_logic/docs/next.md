# 🔄 Next Steps - What's Left to Address

## **High Priority:**

### 1. **God Class Pattern in GameController:**

Split responsibilities into separate classes:

- `GameStateManager` (handles game state transitions)
- `GameRuleEngine` (handles special rules like 50-move rule)

### 2. **Thread Safety Issues:**

- Add immutable state management patterns
- Implement proper synchronization for shared mutable state
- Consider using immutable data structures

### 3. **Performance Optimizations:**

- Cache expensive move calculations
- Optimize check detection algorithms
- Reduce object creation in hot paths
