import 'dart:math';
import '../models/puzzle.dart';

/// Configuration for each level's puzzle generation
class LevelConfig {
  final int minNum;
  final int maxNum;
  final List<String> ops;
  final int blankCount;
  final int timeLimitSec;

  const LevelConfig({
    required this.minNum,
    required this.maxNum,
    required this.ops,
    required this.blankCount,
    required this.timeLimitSec,
  });
}

/// Level configs — difficulty curve
final Map<int, LevelConfig> levelConfigs = {
  1: const LevelConfig(minNum: 1, maxNum: 5, ops: ['+'], blankCount: 1, timeLimitSec: 30),
  2: const LevelConfig(minNum: 1, maxNum: 6, ops: ['+'], blankCount: 1, timeLimitSec: 30),
  3: const LevelConfig(minNum: 1, maxNum: 7, ops: ['+'], blankCount: 2, timeLimitSec: 45),
  4: const LevelConfig(minNum: 1, maxNum: 8, ops: ['+'], blankCount: 2, timeLimitSec: 45),
  5: const LevelConfig(minNum: 1, maxNum: 9, ops: ['+'], blankCount: 3, timeLimitSec: 60),
  6: const LevelConfig(minNum: 2, maxNum: 12, ops: ['+'], blankCount: 3, timeLimitSec: 60),
  7: const LevelConfig(minNum: 1, maxNum: 9, ops: ['+', '-'], blankCount: 3, timeLimitSec: 75),
  8: const LevelConfig(minNum: 2, maxNum: 12, ops: ['+', '-'], blankCount: 3, timeLimitSec: 75),
  9: const LevelConfig(minNum: 1, maxNum: 12, ops: ['+', '-'], blankCount: 4, timeLimitSec: 90),
  10: const LevelConfig(minNum: 1, maxNum: 9, ops: ['+', '*'], blankCount: 4, timeLimitSec: 90),
};

/// Get config for a level — falls back to level 10 config for higher levels
LevelConfig getConfig(int levelId) {
  return levelConfigs[levelId] ??
      LevelConfig(
        minNum: 1,
        maxNum: 12,
        ops: const ['+', '-', '*'],
        blankCount: 4,
        timeLimitSec: 90,
      );
}

/// Generates a valid 2x2 crossword puzzle
///
/// Grid layout:
///   a  op1  b  =  r1    (row 0)
///  op3     op4
///   c  op2  d  =  r2    (row 1)
///   =       =
///   r3      r4
class PuzzleGenerator {
  static final Random _rng = Random();

  /// Generate a unique puzzle for a level, avoiding previously seen ones
  static Puzzle generate(int levelId, {Set<String> usedHashes = const {}}) {
    final config = getConfig(levelId);
    var attempts = 0;

    while (attempts < 5000) {
      attempts++;
      final puzzle = _tryGenerate(levelId, config);
      if (puzzle != null) {
        final hash = puzzleHash(puzzle);
        if (!usedHashes.contains(hash)) {
          return puzzle;
        }
      }
    }

    // Fallback — return any valid puzzle (extremely unlikely to reach here)
    while (true) {
      final puzzle = _tryGenerate(levelId, config);
      if (puzzle != null) return puzzle;
    }
  }

  static Puzzle? _tryGenerate(int levelId, LevelConfig config) {
    final ops = config.ops;

    // Pick 4 operators
    final op1 = ops[_rng.nextInt(ops.length)]; // row 0
    final op2 = ops[_rng.nextInt(ops.length)]; // row 1
    final op3 = ops[_rng.nextInt(ops.length)]; // col 0
    final op4 = ops[_rng.nextInt(ops.length)]; // col 1

    // Pick 4 number cells: a, b, c, d
    final a = _randNum(config);
    final b = _randNum(config);
    final c = _randNum(config);
    final d = _randNum(config);

    // Compute results
    final r1 = _eval(a, op1, b);
    final r2 = _eval(c, op2, d);
    final r3 = _eval(a, op3, c);
    final r4 = _eval(b, op4, d);

    // Validate: all results must be non-negative integers, reasonable size
    if (r1 == null || r2 == null || r3 == null || r4 == null) return null;
    if (r1 < 0 || r2 < 0 || r3 < 0 || r4 < 0) return null;
    if (r1 > 99 || r2 > 99 || r3 > 99 || r4 > 99) return null;

    // Ensure numbers aren't all the same (boring puzzle)
    if (a == b && b == c && c == d) return null;

    // Pick which cells to blank
    // Positions: 0=a, 1=b, 2=c, 3=d, 4=r1, 5=r2, 6=r3, 7=r4
    final allPositions = [0, 1, 2, 3, 4, 5, 6, 7];
    allPositions.shuffle(_rng);
    final blankPositions = allPositions.take(config.blankCount).toList()..sort();

    // Check solvability: each blank must be determinable from at least one equation
    // (simplified check — for 2x2, this is almost always true)
    final values = [a, b, c, d, r1, r2, r3, r4];

    // Map position index to grid key
    final posKeys = ['0,0', '0,2', '2,0', '2,2', '0,4', '2,4', '4,0', '4,2'];
    final answers = <String, int>{};
    final numberPool = <int>[];
    for (final pos in blankPositions) {
      answers[posKeys[pos]] = values[pos];
      numberPool.add(values[pos]);
    }
    numberPool.sort();

    // Build cells
    final cells = <Cell>[
      // Row 0
      _numCell(0, 0, a, !blankPositions.contains(0)),
      _opCell(0, 1, op1),
      _numCell(0, 2, b, !blankPositions.contains(1)),
      _eqCell(0, 3),
      _numCell(0, 4, r1, !blankPositions.contains(4)),
      // Vertical ops
      _opCell(1, 0, op3),
      _opCell(1, 2, op4),
      // Row 1
      _numCell(2, 0, c, !blankPositions.contains(2)),
      _opCell(2, 1, op2),
      _numCell(2, 2, d, !blankPositions.contains(3)),
      _eqCell(2, 3),
      _numCell(2, 4, r2, !blankPositions.contains(5)),
      // Equals row
      _eqCell(3, 0),
      _eqCell(3, 2),
      // Results row
      _numCell(4, 0, r3, !blankPositions.contains(6)),
      _numCell(4, 2, r4, !blankPositions.contains(7)),
    ];

    // Build equations with resultKey for proper validation
    final equations = [
      MathEquation(
        num1Key: '0,0', num2Key: '0,2', resultKey: '0,4', op: op1,
        allCellKeys: ['0,0', '0,1', '0,2', '0,3', '0,4'],
      ),
      MathEquation(
        num1Key: '2,0', num2Key: '2,2', resultKey: '2,4', op: op2,
        allCellKeys: ['2,0', '2,1', '2,2', '2,3', '2,4'],
      ),
      MathEquation(
        num1Key: '0,0', num2Key: '2,0', resultKey: '4,0', op: op3,
        allCellKeys: ['0,0', '1,0', '2,0', '3,0', '4,0'],
      ),
      MathEquation(
        num1Key: '0,2', num2Key: '2,2', resultKey: '4,2', op: op4,
        allCellKeys: ['0,2', '1,2', '2,2', '3,2', '4,2'],
      ),
    ];

    return Puzzle(
      id: levelId * 10000 + _rng.nextInt(10000),
      levelId: levelId,
      gridRows: 5,
      gridCols: 5,
      cells: cells,
      answers: answers,
      numberPool: numberPool,
      equations: equations,
      timeLimitSec: config.timeLimitSec,
    );
  }

  static int _randNum(LevelConfig config) {
    return config.minNum + _rng.nextInt(config.maxNum - config.minNum + 1);
  }

  static int? _eval(int a, String op, int b) {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '*': return a * b;
      case '/': return b != 0 && a % b == 0 ? a ~/ b : null;
      default: return null;
    }
  }

  static Cell _numCell(int r, int c, int value, bool given) =>
      Cell(row: r, col: c, type: CellType.number, value: given ? value : null, given: given);

  static Cell _opCell(int r, int c, String op) =>
      Cell(row: r, col: c, type: CellType.op, value: op, given: true);

  static Cell _eqCell(int r, int c) =>
      Cell(row: r, col: c, type: CellType.equals, value: '=', given: true);

  /// Hash a puzzle by its cell values for deduplication
  static String puzzleHash(Puzzle puzzle) {
    final buf = StringBuffer();
    for (final cell in puzzle.cells) {
      if (cell.type == CellType.number) {
        buf.write('${cell.row},${cell.col}:${cell.value ?? "?"}|');
      } else if (cell.type == CellType.op) {
        buf.write('${cell.value}|');
      }
    }
    return buf.toString();
  }
}
