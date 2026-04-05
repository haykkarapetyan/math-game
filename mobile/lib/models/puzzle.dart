/// Cell types in the crossword grid
enum CellType { number, op, equals, empty }

/// A single cell in the crossword grid
class Cell {
  final int row;
  final int col;
  final CellType type;
  final dynamic value; // int, double, or String (operator)
  final bool given;

  const Cell({
    required this.row,
    required this.col,
    required this.type,
    this.value,
    this.given = true,
  });

  bool get isBlank => !given && type == CellType.number;
}

/// An equation in the crossword (horizontal or vertical)
class MathEquation {
  final String num1Key; // "row,col" of first operand
  final String num2Key; // "row,col" of second operand
  final String resultKey; // "row,col" of result cell
  final String op; // "+", "-", "*", "/"
  final int? resultValue; // expected result (null if result cell is blank)
  final List<String> allCellKeys; // all cells to highlight if wrong

  const MathEquation({
    required this.num1Key,
    required this.num2Key,
    required this.resultKey,
    required this.op,
    this.resultValue,
    required this.allCellKeys,
  });

  /// Evaluate whether this equation is correct given cell values
  /// Returns true if equation is satisfied, false if violated,
  /// null if not enough data to evaluate
  bool? evaluateWith(int? num1, int? num2, int? result) {
    if (num1 == null || num2 == null || result == null) return null;

    int expected;
    switch (op) {
      case '+':
        expected = num1 + num2;
      case '-':
        expected = num1 - num2;
      case '*':
        expected = num1 * num2;
      case '/':
        if (num2 == 0 || num1 % num2 != 0) return false;
        expected = num1 ~/ num2;
      default:
        return false;
    }
    return expected == result;
  }
}

/// A crossword puzzle
class Puzzle {
  final int id;
  final int levelId;
  final int gridRows;
  final int gridCols;
  final List<Cell> cells;
  final Map<String, int> answers; // "row,col" -> correct value
  final List<int> numberPool; // available numbers for the player to place
  final List<MathEquation> equations; // all equations for validation
  final int timeLimitSec;
  final int hintCount;

  const Puzzle({
    required this.id,
    required this.levelId,
    required this.gridRows,
    required this.gridCols,
    required this.cells,
    required this.answers,
    required this.numberPool,
    required this.equations,
    this.timeLimitSec = 120,
    this.hintCount = 3,
  });

  Cell? cellAt(int row, int col) {
    for (final c in cells) {
      if (c.row == row && c.col == col) return c;
    }
    return null;
  }

  /// Get value of a cell — from given data or player answers
  int? getValue(String key, Map<String, int> playerAnswers) {
    if (playerAnswers.containsKey(key)) return playerAnswers[key];
    final parts = key.split(',');
    final r = int.parse(parts[0]);
    final c = int.parse(parts[1]);
    final cell = cellAt(r, c);
    if (cell != null && cell.given && cell.value != null) return cell.value as int;
    return null;
  }

  /// Get all equations that involve a specific cell (as operand OR result)
  List<MathEquation> equationsForCell(String cellKey) {
    return equations
        .where((eq) =>
            eq.num1Key == cellKey ||
            eq.num2Key == cellKey ||
            eq.resultKey == cellKey)
        .toList();
  }
}
