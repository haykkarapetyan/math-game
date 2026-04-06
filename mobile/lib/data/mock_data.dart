import '../models/game.dart';
import '../models/puzzle.dart';
import 'puzzle_generator.dart';

/// All tiers with chapters and levels
final List<Tier> mockTiers = [
  Tier(
    id: 1,
    name: 'Grades 1-5',
    subtitle: 'Addition & Subtraction',
    minGrade: 1,
    maxGrade: 5,
    unlocked: true,
    chapters: [
      Chapter(
        id: 1,
        name: 'Addition',
        tierId: 1,
        unlocked: true,
        levels: generateLevelsWithBonus(1, 1),
      ),
      Chapter(
        id: 2,
        name: 'Subtraction',
        tierId: 1,
        unlocked: false,
        levels: List.generate(
          10,
          (i) => Level(id: 100 + i + 1, number: i + 1, chapterId: 2),
        ),
      ),
      Chapter(
        id: 3,
        name: 'Mixed + -',
        tierId: 1,
        unlocked: false,
        levels: List.generate(
          10,
          (i) => Level(id: 200 + i + 1, number: i + 1, chapterId: 3),
        ),
      ),
    ],
  ),
  Tier(
    id: 2,
    name: 'Grades 5-7',
    subtitle: 'All Operations',
    minGrade: 5,
    maxGrade: 7,
    unlocked: false,
    chapters: [
      Chapter(
        id: 4,
        name: 'Fractions',
        tierId: 2,
        levels: List.generate(
          10,
          (i) => Level(id: 300 + i + 1, number: i + 1, chapterId: 4),
        ),
      ),
    ],
  ),
  Tier(
    id: 3,
    name: 'Grades 7-10',
    subtitle: 'Algebra & Geometry',
    minGrade: 7,
    maxGrade: 10,
    unlocked: false,
    chapters: [
      Chapter(
        id: 5,
        name: 'Linear Equations',
        tierId: 3,
        levels: List.generate(
          10,
          (i) => Level(id: 400 + i + 1, number: i + 1, chapterId: 5),
        ),
      ),
    ],
  ),
  Tier(
    id: 4,
    name: 'University',
    subtitle: 'Advanced Math',
    minGrade: 11,
    maxGrade: 16,
    unlocked: false,
    chapters: [
      Chapter(
        id: 6,
        name: 'Powers & Roots',
        tierId: 4,
        levels: List.generate(
          10,
          (i) => Level(id: 500 + i + 1, number: i + 1, chapterId: 6),
        ),
      ),
    ],
  ),
];

/// Generate levels with bonus levels after every 5
/// Layout: 1,2,3,4,5,[BONUS],6,7,8,9,10,[BONUS]
List<Level> generateLevelsWithBonus(int startId, int chapterId) {
  final levels = <Level>[];
  int id = startId;
  for (int i = 1; i <= 12; i++) {
    final isBonus = (i == 6 || i == 12);
    levels.add(Level(
      id: id,
      number: i,
      chapterId: chapterId,
      unlocked: i == 1,
      isBonus: isBonus,
    ));
    id++;
  }
  return levels;
}

/// Tracks which puzzles have been shown per level
final Map<int, Set<String>> _usedPuzzles = {};

/// Generate a fresh puzzle for a level (never repeats)
Puzzle getPuzzleForLevel(int levelId) {
  _usedPuzzles.putIfAbsent(levelId, () => {});
  final puzzle = PuzzleGenerator.generate(
    levelId,
    usedHashes: _usedPuzzles[levelId]!,
  );
  _usedPuzzles[levelId]!.add(PuzzleGenerator.puzzleHash(puzzle));
  return puzzle;
}
