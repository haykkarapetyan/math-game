import '../models/puzzle.dart';

/// Helpers
Cell _n(int r, int c, int value) =>
    Cell(row: r, col: c, type: CellType.number, value: value, given: true);

Cell _b(int r, int c) =>
    Cell(row: r, col: c, type: CellType.number, value: null, given: false);

Cell _op(int r, int c, String o) =>
    Cell(row: r, col: c, type: CellType.op, value: o, given: true);

Cell _eq(int r, int c) =>
    Cell(row: r, col: c, type: CellType.equals, value: '=', given: true);

/// Standard 2x2 crossword grid (5x5 visual):
///   (0,0) (0,1)op (0,2) (0,3)= (0,4)result
///   (1,0)op       (1,2)op
///   (2,0) (2,1)op (2,2) (2,3)= (2,4)result
///   (3,0)=        (3,2)=
///   (4,0)result   (4,2)result
///
/// Horizontal equations: row0 and row2
/// Vertical equations: col0 and col2

MathEquation _hEq(int row, String op, int result) => MathEquation(
      num1Key: '$row,0',
      num2Key: '$row,2',
      resultKey: '$row,4',
      op: op,
      allCellKeys: ['$row,0', '$row,1', '$row,2', '$row,3', '$row,4'],
    );

MathEquation _vEq(int col, String op, int result) => MathEquation(
      num1Key: '0,$col',
      num2Key: '2,$col',
      resultKey: '4,$col',
      op: op,
      allCellKeys: ['0,$col', '1,$col', '2,$col', '3,$col', '4,$col'],
    );

// ─────────────────────────────────────────────
// LEVEL 1 — 1 blank, addition only
//   3 + ? = 5      → ? = 2
//   +       +
//   1 + 4 = 5
//   =       =
//   4       6
// ─────────────────────────────────────────────
final _level1 = Puzzle(
  id: 1, levelId: 1, gridRows: 5, gridCols: 5,
  cells: [
    _n(0, 0, 3), _op(0, 1, '+'), _b(0, 2), _eq(0, 3), _n(0, 4, 5),
    _op(1, 0, '+'), _op(1, 2, '+'),
    _n(2, 0, 1), _op(2, 1, '+'), _n(2, 2, 4), _eq(2, 3), _n(2, 4, 5),
    _eq(3, 0), _eq(3, 2),
    _n(4, 0, 4), _n(4, 2, 6),
  ],
  answers: {'0,2': 2},
  numberPool: [2],
  equations: [_hEq(0, '+', 5), _hEq(2, '+', 5), _vEq(0, '+', 4), _vEq(2, '+', 6)],
  timeLimitSec: 30,
);

// ─────────────────────────────────────────────
// LEVEL 2 — 1 blank, slightly harder
//   5 + 3 = 8
//   +       +
//   ? + 1 = 3
//   =       =
//   7       4
// ─────────────────────────────────────────────
final _level2 = Puzzle(
  id: 2, levelId: 2, gridRows: 5, gridCols: 5,
  cells: [
    _n(0, 0, 5), _op(0, 1, '+'), _n(0, 2, 3), _eq(0, 3), _n(0, 4, 8),
    _op(1, 0, '+'), _op(1, 2, '+'),
    _b(2, 0), _op(2, 1, '+'), _n(2, 2, 1), _eq(2, 3), _n(2, 4, 3),
    _eq(3, 0), _eq(3, 2),
    _n(4, 0, 7), _n(4, 2, 4),
  ],
  answers: {'2,0': 2},
  numberPool: [2],
  equations: [_hEq(0, '+', 8), _hEq(2, '+', 3), _vEq(0, '+', 7), _vEq(2, '+', 4)],
  timeLimitSec: 30,
);

// ─────────────────────────────────────────────
// LEVEL 3 — 2 blanks
//   4 + ? = 9
//   +       +
//   ? + 3 = 6
//   =       =
//   7       8
// ─────────────────────────────────────────────
final _level3 = Puzzle(
  id: 3, levelId: 3, gridRows: 5, gridCols: 5,
  cells: [
    _n(0, 0, 4), _op(0, 1, '+'), _b(0, 2), _eq(0, 3), _n(0, 4, 9),
    _op(1, 0, '+'), _op(1, 2, '+'),
    _b(2, 0), _op(2, 1, '+'), _n(2, 2, 3), _eq(2, 3), _n(2, 4, 6),
    _eq(3, 0), _eq(3, 2),
    _n(4, 0, 7), _n(4, 2, 8),
  ],
  answers: {'0,2': 5, '2,0': 3},
  numberPool: [3, 5],
  equations: [_hEq(0, '+', 9), _hEq(2, '+', 6), _vEq(0, '+', 7), _vEq(2, '+', 8)],
  timeLimitSec: 45,
);

// ─────────────────────────────────────────────
// LEVEL 4 — 2 blanks, numbers 4-5
//   ? + 5 = 9
//   +       +
//   6 + ? = 8
//   =       =
//  10       7
// ─────────────────────────────────────────────
final _level4 = Puzzle(
  id: 4, levelId: 4, gridRows: 5, gridCols: 5,
  cells: [
    _b(0, 0), _op(0, 1, '+'), _n(0, 2, 5), _eq(0, 3), _n(0, 4, 9),
    _op(1, 0, '+'), _op(1, 2, '+'),
    _n(2, 0, 6), _op(2, 1, '+'), _b(2, 2), _eq(2, 3), _n(2, 4, 8),
    _eq(3, 0), _eq(3, 2),
    _n(4, 0, 10), _n(4, 2, 7),
  ],
  answers: {'0,0': 4, '2,2': 2},
  numberPool: [2, 4],
  equations: [_hEq(0, '+', 9), _hEq(2, '+', 8), _vEq(0, '+', 10), _vEq(2, '+', 7)],
  timeLimitSec: 45,
);

// ─────────────────────────────────────────────
// LEVEL 5 — 3 blanks
//   ? + 6 = ?
//   +       +
//   3 + ? = 5
//   =       =
//   7       8
//
// Col0: ?+3=7 → ?=4, Row0: 4+6=10, Col2: 6+?=8 → ?=2, Row1: 3+2=5 ✓
// ─────────────────────────────────────────────
final _level5 = Puzzle(
  id: 5, levelId: 5, gridRows: 5, gridCols: 5,
  cells: [
    _b(0, 0), _op(0, 1, '+'), _n(0, 2, 6), _eq(0, 3), _b(0, 4),
    _op(1, 0, '+'), _op(1, 2, '+'),
    _n(2, 0, 3), _op(2, 1, '+'), _b(2, 2), _eq(2, 3), _n(2, 4, 5),
    _eq(3, 0), _eq(3, 2),
    _n(4, 0, 7), _n(4, 2, 8),
  ],
  answers: {'0,0': 4, '0,4': 10, '2,2': 2},
  numberPool: [2, 4, 10],
  equations: [_hEq(0, '+', 10), _hEq(2, '+', 5), _vEq(0, '+', 7), _vEq(2, '+', 8)],
  timeLimitSec: 60,
);

// ─────────────────────────────────────────────
// LEVEL 6 — 3 blanks, larger numbers
//   7 + ? = ?
//   +       +
//   ? + 5 = 8
//   =       =
//  10      11
//
// Col0: 7+?=10 → ?=3, Row1: 3+5=8 ✓, Col2: ?+5=11 → ?=6, Row0: 7+6=13
// ─────────────────────────────────────────────
final _level6 = Puzzle(
  id: 6, levelId: 6, gridRows: 5, gridCols: 5,
  cells: [
    _n(0, 0, 7), _op(0, 1, '+'), _b(0, 2), _eq(0, 3), _b(0, 4),
    _op(1, 0, '+'), _op(1, 2, '+'),
    _b(2, 0), _op(2, 1, '+'), _n(2, 2, 5), _eq(2, 3), _n(2, 4, 8),
    _eq(3, 0), _eq(3, 2),
    _n(4, 0, 10), _n(4, 2, 11),
  ],
  answers: {'0,2': 6, '0,4': 13, '2,0': 3},
  numberPool: [3, 6, 13],
  equations: [_hEq(0, '+', 13), _hEq(2, '+', 8), _vEq(0, '+', 10), _vEq(2, '+', 11)],
  timeLimitSec: 60,
);

// ─────────────────────────────────────────────
// LEVEL 7 — 3 blanks, introduces subtraction
//   8 - ? = 5
//   +       +
//   ? + 4 = ?
//   =       =
//   9       7
//
// Row0: 8-?=5 → ?=3, Col2: 3+4=7 ✓, Col0: 8+?=9 → ?=1, Row1: 1+4=5
// Wait: Col2: ?+4=7 → ?=3, then Row0: 8-3=5 ✓
// Col0: 8+?=9 → ?=1, Row1: 1+4=5
// ─────────────────────────────────────────────
final _level7 = Puzzle(
  id: 7, levelId: 7, gridRows: 5, gridCols: 5,
  cells: [
    _n(0, 0, 8), _op(0, 1, '-'), _b(0, 2), _eq(0, 3), _n(0, 4, 5),
    _op(1, 0, '+'), _op(1, 2, '+'),
    _b(2, 0), _op(2, 1, '+'), _n(2, 2, 4), _eq(2, 3), _b(2, 4),
    _eq(3, 0), _eq(3, 2),
    _n(4, 0, 9), _n(4, 2, 7),
  ],
  answers: {'0,2': 3, '2,0': 1, '2,4': 5},
  numberPool: [1, 3, 5],
  equations: [_hEq(0, '-', 5), _hEq(2, '+', 5), _vEq(0, '+', 9), _vEq(2, '+', 7)],
  timeLimitSec: 75,
);

// ─────────────────────────────────────────────
// LEVEL 8 — 3 blanks, mixed + and -
//   9 - ? = ?
//   -       +
//   ? + 2 = 5
//   =       =
//   6       7
//
// Col0: 9-?=6 → ?=3, Row1: 3+2=5 ✓
// Col2: ?+2=7 → ?=5, Row0: 9-5=4
// Blanks: (0,2)=5 wrong... let me redo
// Actually: Row0: 9-?=?, Col0: 9-?=6 → (2,0)=3
// Col2: ?+2=7 → (0,2)=5, Row0: 9-5=4 → (0,4)=4
// ─────────────────────────────────────────────
final _level8 = Puzzle(
  id: 8, levelId: 8, gridRows: 5, gridCols: 5,
  cells: [
    _n(0, 0, 9), _op(0, 1, '-'), _b(0, 2), _eq(0, 3), _b(0, 4),
    _op(1, 0, '-'), _op(1, 2, '+'),
    _b(2, 0), _op(2, 1, '+'), _n(2, 2, 2), _eq(2, 3), _n(2, 4, 5),
    _eq(3, 0), _eq(3, 2),
    _n(4, 0, 6), _n(4, 2, 7),
  ],
  answers: {'0,2': 5, '0,4': 4, '2,0': 3},
  numberPool: [3, 4, 5],
  equations: [_hEq(0, '-', 4), _hEq(2, '+', 5), _vEq(0, '-', 6), _vEq(2, '+', 7)],
  timeLimitSec: 75,
);

// ─────────────────────────────────────────────
// LEVEL 9 — 4 blanks
//   ? + ? = 9
//   +       -
//   ? + 3 = ?
//   =       =
//   8       4
//
// Col0: ?+?=8, Col2: ?+3=? and ?-?=4
// Let (0,0)=a, (0,2)=b, (2,0)=c, (2,2)=d=3 given
// Row0: a+b=9, Col0: a+c=8, Col2: b-d... wait op is - for col2
// (1,2) op is -, so Col2: b - (d=3) but d is given as 3...
// Col2: b - 3 = 4... no wait, col result is 4, so: (0,2) then op(1,2)='-' then (2,2)=3...
// That means vertical eq col2: b - 3 = 4 → b = 7
// Row0: a + 7 = 9 → a = 2
// Col0: 2 + c = 8 → c = 6
// Row1: 6 + 3 = 9... (2,4) = 9
// ─────────────────────────────────────────────
final _level9 = Puzzle(
  id: 9, levelId: 9, gridRows: 5, gridCols: 5,
  cells: [
    _b(0, 0), _op(0, 1, '+'), _b(0, 2), _eq(0, 3), _n(0, 4, 9),
    _op(1, 0, '+'), _op(1, 2, '-'),
    _b(2, 0), _op(2, 1, '+'), _n(2, 2, 3), _eq(2, 3), _b(2, 4),
    _eq(3, 0), _eq(3, 2),
    _n(4, 0, 8), _n(4, 2, 4),
  ],
  answers: {'0,0': 2, '0,2': 7, '2,0': 6, '2,4': 9},
  numberPool: [2, 6, 7, 9],
  equations: [_hEq(0, '+', 9), _hEq(2, '+', 9), _vEq(0, '+', 8), _vEq(2, '-', 4)],
  timeLimitSec: 90,
);

// ─────────────────────────────────────────────
// LEVEL 10 — introduces multiplication!
//   3 * ? = 6
//   +       +
//   ? + 5 = ?
//   =       =
//   7      11
//
// Row0: 3*?=6 → ?=2, Col2: 2+5=7... but result is 11
// Hmm. Col2: ?+5=11 → (0,2)=6, wait no (0,2) is 2...
// Let me redo: Col2: 6+5=11 ✓ (0,2)=6 means Row0: 3*?=6, ?=2...
// (0,2) is the second operand of row AND first operand of col2
// Row0: 3*2=6, Col2: 2+5=7 but result says 11. Doesn't work.
//
// Let me separate the result cells. The results at (0,4) and (2,4)
// are row results. Results at (4,0) and (4,2) are col results.
// (0,2) appears in row0 and col2.
//
// Row0: 3 * (0,2) = (0,4)
// Row1: (2,0) + 5 = (2,4)
// Col0: 3 + (2,0) = (4,0)=7
// Col2: (0,2) + 5 = (4,2)=11
//
// Col2: (0,2)+5=11 → (0,2)=6
// Row0: 3*6=18 → (0,4)=18
// Col0: 3+(2,0)=7 → (2,0)=4
// Row1: 4+5=9 → (2,4)=9
// ─────────────────────────────────────────────
final _level10 = Puzzle(
  id: 10, levelId: 10, gridRows: 5, gridCols: 5,
  cells: [
    _n(0, 0, 3), _op(0, 1, '*'), _b(0, 2), _eq(0, 3), _b(0, 4),
    _op(1, 0, '+'), _op(1, 2, '+'),
    _b(2, 0), _op(2, 1, '+'), _n(2, 2, 5), _eq(2, 3), _b(2, 4),
    _eq(3, 0), _eq(3, 2),
    _n(4, 0, 7), _n(4, 2, 11),
  ],
  answers: {'0,2': 6, '0,4': 18, '2,0': 4, '2,4': 9},
  numberPool: [4, 6, 9, 18],
  equations: [_hEq(0, '*', 18), _hEq(2, '+', 9), _vEq(0, '+', 7), _vEq(2, '+', 11)],
  timeLimitSec: 90,
);

/// All puzzles indexed by levelId
final Map<int, Puzzle> allPuzzles = {
  for (final p in [
    _level1, _level2, _level3, _level4, _level5,
    _level6, _level7, _level8, _level9, _level10,
  ])
    p.levelId: p,
};
