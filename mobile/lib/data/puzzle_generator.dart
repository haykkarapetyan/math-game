import 'dart:math';
import '../models/puzzle.dart';

class LevelConfig {
  final int gridRows; // number of equation rows (number cells)
  final int gridCols; // number of equation cols (number cells)
  final int minNum;
  final int maxNum;
  final List<String> ops;
  final int blankCount;
  final int timeLimitSec;

  const LevelConfig({
    required this.gridRows,
    required this.gridCols,
    required this.minNum,
    required this.maxNum,
    required this.ops,
    required this.blankCount,
    required this.timeLimitSec,
  });
}

/// Level configs — grid size increases + more blanks + harder ops
final Map<int, LevelConfig> levelConfigs = {
  //        grid    nums      ops              blanks  time
  1:  const LevelConfig(gridRows: 2, gridCols: 2, minNum: 1, maxNum: 5,  ops: ['+'],           blankCount: 1,  timeLimitSec: 30),
  2:  const LevelConfig(gridRows: 2, gridCols: 2, minNum: 1, maxNum: 6,  ops: ['+'],           blankCount: 2,  timeLimitSec: 45),
  3:  const LevelConfig(gridRows: 2, gridCols: 2, minNum: 1, maxNum: 7,  ops: ['+'],           blankCount: 3,  timeLimitSec: 60),
  4:  const LevelConfig(gridRows: 2, gridCols: 2, minNum: 1, maxNum: 8,  ops: ['+'],           blankCount: 4,  timeLimitSec: 75),
  5:  const LevelConfig(gridRows: 2, gridCols: 3, minNum: 1, maxNum: 7,  ops: ['+'],           blankCount: 4,  timeLimitSec: 90),
  6:  const LevelConfig(gridRows: 3, gridCols: 2, minNum: 1, maxNum: 8,  ops: ['+', '-'],      blankCount: 5,  timeLimitSec: 90),
  7:  const LevelConfig(gridRows: 3, gridCols: 3, minNum: 1, maxNum: 7,  ops: ['+'],           blankCount: 5,  timeLimitSec: 105),
  8:  const LevelConfig(gridRows: 3, gridCols: 3, minNum: 1, maxNum: 8,  ops: ['+', '-'],      blankCount: 7,  timeLimitSec: 120),
  9:  const LevelConfig(gridRows: 3, gridCols: 3, minNum: 1, maxNum: 9,  ops: ['+', '-'],      blankCount: 9,  timeLimitSec: 135),
  10: const LevelConfig(gridRows: 4, gridCols: 4, minNum: 1, maxNum: 7,  ops: ['+', '-'],      blankCount: 10, timeLimitSec: 150),
};

LevelConfig getConfig(int levelId) {
  return levelConfigs[levelId] ??
      LevelConfig(
        gridRows: 4, gridCols: 4,
        minNum: 1, maxNum: 9,
        ops: const ['+', '-', '*'],
        blankCount: 12,
        timeLimitSec: 150,
      );
}

/// Bonus level config
LevelConfig getBonusConfig(int levelNumber) {
  final baseLevelNum = levelNumber == 6 ? 5 : 10;
  final base = getConfig(baseLevelNum);
  return LevelConfig(
    gridRows: base.gridRows,
    gridCols: base.gridCols,
    minNum: base.minNum,
    maxNum: base.maxNum,
    ops: base.ops,
    blankCount: (base.blankCount + 2).clamp(1, base.gridRows * base.gridCols + base.gridRows + base.gridCols),
    timeLimitSec: (base.timeLimitSec * 0.75).round(),
  );
}

int bonusXpMultiplier(int levelNumber) {
  if (levelNumber == 6) return 2;
  if (levelNumber == 12) return 3;
  return 1;
}

/// Generalized NxM crossword puzzle generator
class PuzzleGenerator {
  static final Random _rng = Random();

  static Puzzle generate(int levelId, {Set<String> usedHashes = const {}}) {
    final config = getConfig(levelId);
    for (var attempt = 0; attempt < 5000; attempt++) {
      final puzzle = _tryGenerate(levelId, config);
      if (puzzle != null) {
        final hash = puzzleHash(puzzle);
        if (!usedHashes.contains(hash)) return puzzle;
      }
    }
    // Fallback
    while (true) {
      final puzzle = _tryGenerate(levelId, config);
      if (puzzle != null) return puzzle;
    }
  }

  static Puzzle? _tryGenerate(int levelId, LevelConfig config) {
    final r = config.gridRows;
    final c = config.gridCols;

    // Generate number grid [r][c]
    final nums = List.generate(r, (_) =>
        List.generate(c, (_) => _randNum(config)));

    // Generate row operators: [r][c-1]
    final rowOps = List.generate(r, (_) =>
        List.generate(c - 1, (_) => config.ops[_rng.nextInt(config.ops.length)]));

    // Generate column operators: [r-1][c]
    final colOps = List.generate(r - 1, (_) =>
        List.generate(c, (_) => config.ops[_rng.nextInt(config.ops.length)]));

    // Compute row results (left-to-right)
    final rowResults = <int>[];
    for (var row = 0; row < r; row++) {
      var result = nums[row][0];
      for (var col = 1; col < c; col++) {
        final v = _eval(result, rowOps[row][col - 1], nums[row][col]);
        if (v == null) return null;
        result = v;
      }
      if (result < 0 || result > 99) return null;
      rowResults.add(result);
    }

    // Compute column results (top-to-bottom)
    final colResults = <int>[];
    for (var col = 0; col < c; col++) {
      var result = nums[0][col];
      for (var row = 1; row < r; row++) {
        final v = _eval(result, colOps[row - 1][col], nums[row][col]);
        if (v == null) return null;
        result = v;
      }
      if (result < 0 || result > 99) return null;
      colResults.add(result);
    }

    // Check not all same number
    final allNums = nums.expand((row) => row).toSet();
    if (allNums.length <= 1) return null;

    // Visual grid dimensions
    final visualRows = r * 2 - 1 + 2; // num rows + op rows + equals row + result row
    final visualCols = c * 2 - 1 + 2; // num cols + op cols + equals col + result col

    // Build all value positions for blanking
    // Index: number cells first, then row results, then col results
    final allPositions = <_CellPos>[];

    // Number cells
    for (var row = 0; row < r; row++) {
      for (var col = 0; col < c; col++) {
        allPositions.add(_CellPos(row * 2, col * 2, nums[row][col]));
      }
    }
    // Row result cells
    for (var row = 0; row < r; row++) {
      allPositions.add(_CellPos(row * 2, visualCols - 1, rowResults[row]));
    }
    // Column result cells
    for (var col = 0; col < c; col++) {
      allPositions.add(_CellPos(visualRows - 1, col * 2, colResults[col]));
    }

    // Pick blanks
    final indices = List.generate(allPositions.length, (i) => i);
    indices.shuffle(_rng);
    final blankCount = config.blankCount.clamp(0, allPositions.length);
    final blankIndices = indices.take(blankCount).toSet();

    // Build cells
    final cells = <Cell>[];

    // Number cells + horizontal operators + equals + row results
    for (var row = 0; row < r; row++) {
      for (var col = 0; col < c; col++) {
        final idx = row * c + col;
        final isBlank = blankIndices.contains(idx);
        cells.add(Cell(
          row: row * 2, col: col * 2,
          type: CellType.number,
          value: isBlank ? null : nums[row][col],
          given: !isBlank,
        ));
        // Horizontal operator (between number cells)
        if (col < c - 1) {
          cells.add(Cell(
            row: row * 2, col: col * 2 + 1,
            type: CellType.op,
            value: rowOps[row][col],
            given: true,
          ));
        }
      }
      // Equals sign for row (between last number and result)
      cells.add(Cell(row: row * 2, col: visualCols - 2, type: CellType.equals, value: '=', given: true));

      // Row result
      final rIdx = r * c + row;
      final rBlank = blankIndices.contains(rIdx);
      cells.add(Cell(
        row: row * 2, col: visualCols - 1,
        type: CellType.number,
        value: rBlank ? null : rowResults[row],
        given: !rBlank,
      ));
    }

    // Vertical operators
    for (var row = 0; row < r - 1; row++) {
      for (var col = 0; col < c; col++) {
        cells.add(Cell(
          row: row * 2 + 1, col: col * 2,
          type: CellType.op,
          value: colOps[row][col],
          given: true,
        ));
      }
    }

    // Equals row (for columns) — between last number row and result row
    for (var col = 0; col < c; col++) {
      cells.add(Cell(
        row: visualRows - 2, col: col * 2,
        type: CellType.equals, value: '=', given: true,
      ));
    }

    // Column results row
    for (var col = 0; col < c; col++) {
      final cIdx = r * c + r + col;
      final cBlank = blankIndices.contains(cIdx);
      cells.add(Cell(
        row: visualRows - 1, col: col * 2,
        type: CellType.number,
        value: cBlank ? null : colResults[col],
        given: !cBlank,
      ));
    }

    // Build answers + number pool
    final answers = <String, int>{};
    final numberPool = <int>[];
    for (final idx in blankIndices) {
      final pos = allPositions[idx];
      final key = '${pos.row},${pos.col}';
      answers[key] = pos.value;
      numberPool.add(pos.value);
    }
    numberPool.sort();

    // Build equations
    final equations = <MathEquation>[];

    // Row equations (each row: chained evaluation)
    for (var row = 0; row < r; row++) {
      // For multi-number rows, create pairwise equations
      // But for validation, we need the full chain
      // Simple approach: one equation per row covering all cells
      final numKeys = List.generate(c, (col) => '${row * 2},${col * 2}');
      final opKeys = List.generate(c - 1, (col) => '${row * 2},${col * 2 + 1}');
      final eqKey = '${row * 2},${(c - 1) * 2 + 1}';
      final resultKey = '${row * 2},${visualCols - 1}';
      final allKeys = [...numKeys, ...opKeys, eqKey, resultKey];

      // For 2-number rows, use simple MathEquation
      if (c == 2) {
        equations.add(MathEquation(
          num1Key: numKeys[0], num2Key: numKeys[1],
          resultKey: resultKey, op: rowOps[row][0],
          allCellKeys: allKeys,
        ));
      } else {
        // For 3+ number rows, create chain equations
        // First pair
        equations.add(MathEquation(
          num1Key: numKeys[0], num2Key: numKeys[1],
          resultKey: resultKey, op: rowOps[row][0],
          allCellKeys: allKeys,
        ));
        // Additional pairs share the result validation
        for (var i = 1; i < c - 1; i++) {
          equations.add(MathEquation(
            num1Key: numKeys[i], num2Key: numKeys[i + 1],
            resultKey: resultKey, op: rowOps[row][i],
            allCellKeys: allKeys,
          ));
        }
      }
    }

    // Column equations
    for (var col = 0; col < c; col++) {
      final numKeys = List.generate(r, (row) => '${row * 2},${col * 2}');
      final opKeys = List.generate(r - 1, (row) => '${row * 2 + 1},${col * 2}');
      final eqKey = '${(r - 1) * 2 + 1},${col * 2}';
      final resultKey = '${visualRows - 1},${col * 2}';
      final allKeys = [...numKeys, ...opKeys, eqKey, resultKey];

      if (r == 2) {
        equations.add(MathEquation(
          num1Key: numKeys[0], num2Key: numKeys[1],
          resultKey: resultKey, op: colOps[0][col],
          allCellKeys: allKeys,
        ));
      } else {
        for (var i = 0; i < r - 1; i++) {
          equations.add(MathEquation(
            num1Key: numKeys[i], num2Key: numKeys[i + 1],
            resultKey: resultKey, op: colOps[i][col],
            allCellKeys: allKeys,
          ));
        }
      }
    }

    return Puzzle(
      id: levelId * 10000 + _rng.nextInt(10000),
      levelId: levelId,
      gridRows: visualRows,
      gridCols: visualCols,
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

class _CellPos {
  final int row;
  final int col;
  final int value;
  const _CellPos(this.row, this.col, this.value);
}
