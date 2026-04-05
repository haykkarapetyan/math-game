import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../models/game.dart';
import '../models/puzzle.dart';

/// Fetch tiers from backend API
final apiTiersProvider = FutureProvider<List<Tier>>((ref) async {
  final api = ref.read(apiClientProvider);
  if (!await api.hasToken()) return [];

  final data = await api.getTiers();
  return data.map<Tier>((t) => Tier(
    id: t['id'],
    name: t['name'] ?? '',
    subtitle: 'Grades ${t['min_grade']}-${t['max_grade']}',
    minGrade: t['min_grade'],
    maxGrade: t['max_grade'],
    unlocked: t['unlocked'] ?? false,
    chapters: [], // levels fetched separately
  )).toList();
});

/// Fetch levels for a tier from backend API
final apiLevelsProvider = FutureProvider.family<List<Level>, int>((ref, tierId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getLevels(tierId);
  return data.map<Level>((l) => Level(
    id: l['id'],
    number: l['number'],
    chapterId: 1, // backend doesn't use chapters yet
    stars: l['stars'] ?? 0,
    unlocked: l['unlocked'] ?? false,
    completed: l['completed'] ?? false,
  )).toList();
});

/// Fetch a puzzle from backend API
final apiPuzzleProvider = FutureProvider.family<ApiPuzzle?, int>((ref, levelId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getPuzzle(levelId);

  final puzzleData = data['data'] as Map<String, dynamic>;
  final cells = (puzzleData['cells'] as List).map<Cell>((c) {
    return Cell(
      row: c['row'],
      col: c['col'],
      type: _parseCellType(c['type']),
      value: c['value'],
      given: c['given'] ?? true,
    );
  }).toList();

  final numberPool = (puzzleData['number_pool'] as List?)
      ?.map<int>((n) => n as int).toList() ?? [];

  return ApiPuzzle(
    id: data['id'],
    puzzle: Puzzle(
      id: data['id'],
      levelId: levelId,
      gridRows: puzzleData['grid_rows'] ?? 5,
      gridCols: puzzleData['grid_cols'] ?? 5,
      cells: cells,
      answers: {}, // answers stay server-side
      numberPool: numberPool,
      equations: _buildEquations(cells),
      timeLimitSec: puzzleData['time_limit_sec'] ?? 120,
    ),
  );
});

/// Puzzle with server ID for submission
class ApiPuzzle {
  final int id;
  final Puzzle puzzle;
  const ApiPuzzle({required this.id, required this.puzzle});
}

CellType _parseCellType(String type) {
  switch (type) {
    case 'number': return CellType.number;
    case 'op': return CellType.op;
    case 'equals': return CellType.equals;
    default: return CellType.empty;
  }
}

/// Build equations from cell layout (auto-detect from 2x2 grid)
List<MathEquation> _buildEquations(List<Cell> cells) {
  // Find operators to determine equation ops
  String findOp(int row, int col) {
    for (final c in cells) {
      if (c.row == row && c.col == col && c.type == CellType.op) {
        return c.value as String;
      }
    }
    return '+';
  }

  final equations = <MathEquation>[];

  // Row 0: (0,0) op(0,1) (0,2) = (0,4)
  equations.add(MathEquation(
    num1Key: '0,0', num2Key: '0,2', resultKey: '0,4', op: findOp(0, 1),
    allCellKeys: ['0,0', '0,1', '0,2', '0,3', '0,4'],
  ));

  // Row 1: (2,0) op(2,1) (2,2) = (2,4)
  equations.add(MathEquation(
    num1Key: '2,0', num2Key: '2,2', resultKey: '2,4', op: findOp(2, 1),
    allCellKeys: ['2,0', '2,1', '2,2', '2,3', '2,4'],
  ));

  // Col 0: (0,0) op(1,0) (2,0) = (4,0)
  equations.add(MathEquation(
    num1Key: '0,0', num2Key: '2,0', resultKey: '4,0', op: findOp(1, 0),
    allCellKeys: ['0,0', '1,0', '2,0', '3,0', '4,0'],
  ));

  // Col 1: (0,2) op(1,2) (2,2) = (4,2)
  equations.add(MathEquation(
    num1Key: '0,2', num2Key: '2,2', resultKey: '4,2', op: findOp(1, 2),
    allCellKeys: ['0,2', '1,2', '2,2', '3,2', '4,2'],
  ));

  return equations;
}
