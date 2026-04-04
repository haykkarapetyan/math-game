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
  final String op; // "+", "-", "*", "/"
  final int result; // expected result
  final List<String> allCellKeys; // all cells to highlight if wrong

  const MathEquation({
    required this.num1Key,
    required this.num2Key,
    required this.op,
    required this.result,
    required this.allCellKeys,
  });

  /// Evaluate whether this equation is correct given the values
  bool evaluate(int num1, int num2) {
    switch (op) {
      case '+':
        return num1 + num2 == result;
      case '-':
        return num1 - num2 == result;
      case '*':
        return num1 * num2 == result;
      case '/':
        return num2 != 0 && num1 ~/ num2 == result && num1 % num2 == 0;
      default:
        return false;
    }
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

  /// Get all equations that involve a specific cell
  List<MathEquation> equationsForCell(String cellKey) {
    return equations
        .where((eq) => eq.num1Key == cellKey || eq.num2Key == cellKey)
        .toList();
  }
}
