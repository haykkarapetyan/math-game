import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/puzzle.dart';

/// Current player state
final playerProvider = StateNotifierProvider<PlayerNotifier, Player>(
  (ref) => PlayerNotifier(),
);

class PlayerNotifier extends StateNotifier<Player> {
  PlayerNotifier() : super(const Player());

  void login(String username, String email) {
    state = state.copyWith(
      username: username,
      email: email,
      isLoggedIn: true,
    );
  }

  void register(String username, String email) {
    state = state.copyWith(
      username: username,
      email: email,
      isLoggedIn: true,
    );
  }

  void logout() => state = const Player();

  void setAvatar(String avatarId) =>
      state = state.copyWith(avatarId: avatarId);

  void setUsername(String username) =>
      state = state.copyWith(username: username);

  void addXp(int amount) => state = state.copyWith(xp: state.xp + amount);
  void addCoins(int amount) =>
      state = state.copyWith(coins: state.coins + amount);
  void useEnergy() {
    if (state.energy > 0) {
      state = state.copyWith(energy: state.energy - 1);
    }
  }

  void addStars(int amount) =>
      state = state.copyWith(starsCollected: state.starsCollected + amount);

  void completeLevel() =>
      state = state.copyWith(levelsCompleted: state.levelsCompleted + 1);
}

/// Mock friends list
final friendsProvider = Provider<List<Friend>>((ref) {
  return const [
    Friend(id: '1', username: 'Armen', avatarId: 'lion', xp: 2450, starsCollected: 45, isOnline: true),
    Friend(id: '2', username: 'Ani', avatarId: 'unicorn', xp: 1800, starsCollected: 32, isOnline: true),
    Friend(id: '3', username: 'Davit', avatarId: 'eagle', xp: 3200, starsCollected: 58, isOnline: false),
    Friend(id: '4', username: 'Mariam', avatarId: 'panda', xp: 950, starsCollected: 18, isOnline: false),
    Friend(id: '5', username: 'Gor', avatarId: 'robot', xp: 4100, starsCollected: 72, isOnline: true),
    Friend(id: '6', username: 'Lusine', avatarId: 'cat', xp: 1500, starsCollected: 28, isOnline: false),
    Friend(id: '7', username: 'Tigran', avatarId: 'bear', xp: 2800, starsCollected: 50, isOnline: true),
  ];
});

/// Mock leaderboard
final leaderboardProvider = Provider<List<LeaderboardEntry>>((ref) {
  return const [
    LeaderboardEntry(rank: 1, username: 'Gor', avatarId: 'robot', xp: 4100),
    LeaderboardEntry(rank: 2, username: 'Davit', avatarId: 'eagle', xp: 3200),
    LeaderboardEntry(rank: 3, username: 'Tigran', avatarId: 'bear', xp: 2800),
    LeaderboardEntry(rank: 4, username: 'Armen', avatarId: 'lion', xp: 2450),
    LeaderboardEntry(rank: 5, username: 'Ani', avatarId: 'unicorn', xp: 1800),
    LeaderboardEntry(rank: 6, username: 'Lusine', avatarId: 'cat', xp: 1500),
    LeaderboardEntry(rank: 7, username: 'Mariam', avatarId: 'panda', xp: 950),
    LeaderboardEntry(rank: 8, username: 'You', avatarId: 'fox', xp: 0, isCurrentUser: true),
  ];
});

/// Tiers with mutable progress
final tiersProvider = StateNotifierProvider<TiersNotifier, List<Tier>>(
  (ref) => TiersNotifier(),
);

class TiersNotifier extends StateNotifier<List<Tier>> {
  TiersNotifier() : super(mockTiers);

  void completeLevel(int tierId, int chapterId, int levelId, int stars) {
    state = [
      for (final tier in state)
        if (tier.id == tierId)
          Tier(
            id: tier.id,
            name: tier.name,
            subtitle: tier.subtitle,
            minGrade: tier.minGrade,
            maxGrade: tier.maxGrade,
            unlocked: tier.unlocked,
            chapters: [
              for (final chapter in tier.chapters)
                if (chapter.id == chapterId)
                  Chapter(
                    id: chapter.id,
                    name: chapter.name,
                    tierId: chapter.tierId,
                    unlocked: chapter.unlocked,
                    levels: _updateLevels(chapter.levels, levelId, stars),
                  )
                else
                  chapter,
            ],
          )
        else
          tier,
    ];
  }

  List<Level> _updateLevels(List<Level> levels, int levelId, int stars) {
    final updated = <Level>[];
    for (var i = 0; i < levels.length; i++) {
      final level = levels[i];
      if (level.id == levelId) {
        updated.add(Level(
          id: level.id,
          number: level.number,
          chapterId: level.chapterId,
          stars: stars > level.stars ? stars : level.stars,
          unlocked: true,
          completed: true,
        ));
      } else if (i > 0 && updated.last.completed && !level.completed) {
        updated.add(Level(
          id: level.id,
          number: level.number,
          chapterId: level.chapterId,
          stars: level.stars,
          unlocked: true,
          completed: level.completed,
        ));
      } else {
        updated.add(level);
      }
    }
    return updated;
  }
}

/// Active puzzle state for gameplay
class PuzzleState {
  final Puzzle puzzle;
  final Map<String, int> playerAnswers;
  final List<int> remainingPool;
  final String? selectedCell;
  final int moves;
  final int wrongMoves;
  final bool completed;
  final int stars;
  final List<MapEntry<String, int>> moveHistory;
  final Set<String> wrongCells;
  final int undosUsed;
  final int hintsUsed;
  final int elapsedSeconds;
  final int hearts;
  final bool failed;
  final int? selectedPoolIndex; // selected number from pool (number-first flow)

  const PuzzleState({
    required this.puzzle,
    this.playerAnswers = const {},
    this.remainingPool = const [],
    this.selectedCell,
    this.selectedPoolIndex,
    this.moves = 0,
    this.wrongMoves = 0,
    this.completed = false,
    this.stars = 0,
    this.moveHistory = const [],
    this.wrongCells = const {},
    this.undosUsed = 0,
    this.hintsUsed = 0,
    this.elapsedSeconds = 0,
    this.hearts = 3,
    this.failed = false,
  });

  int get maxUndos => 1;
  int get maxHints => 1;
  bool get canUndo => undosUsed < maxUndos && moveHistory.isNotEmpty;
  bool get canHint => hintsUsed < maxHints;

  PuzzleState copyWith({
    Map<String, int>? playerAnswers,
    List<int>? remainingPool,
    String? selectedCell,
    bool clearSelection = false,
    int? moves,
    int? wrongMoves,
    bool? completed,
    int? stars,
    List<MapEntry<String, int>>? moveHistory,
    Set<String>? wrongCells,
    int? undosUsed,
    int? hintsUsed,
    int? elapsedSeconds,
    int? hearts,
    bool? failed,
    int? selectedPoolIndex,
    bool clearPool = false,
  }) {
    return PuzzleState(
      puzzle: puzzle,
      playerAnswers: playerAnswers ?? this.playerAnswers,
      remainingPool: remainingPool ?? this.remainingPool,
      selectedCell: clearSelection ? null : (selectedCell ?? this.selectedCell),
      selectedPoolIndex: clearPool ? null : (selectedPoolIndex ?? this.selectedPoolIndex),
      moves: moves ?? this.moves,
      wrongMoves: wrongMoves ?? this.wrongMoves,
      completed: completed ?? this.completed,
      stars: stars ?? this.stars,
      moveHistory: moveHistory ?? this.moveHistory,
      wrongCells: wrongCells ?? this.wrongCells,
      undosUsed: undosUsed ?? this.undosUsed,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      hearts: hearts ?? this.hearts,
      failed: failed ?? this.failed,
    );
  }
}

final puzzleProvider =
    StateNotifierProvider.autoDispose<PuzzleNotifier, PuzzleState?>(
  (ref) => PuzzleNotifier(),
);

class PuzzleNotifier extends StateNotifier<PuzzleState?> {
  PuzzleNotifier() : super(null);

  void loadPuzzle(int levelId) {
    final puzzle = getPuzzleForLevel(levelId);
    state = PuzzleState(
      puzzle: puzzle,
      remainingPool: List<int>.from(puzzle.numberPool),
    );
  }

  /// Load puzzle from API data (answers stay server-side)
  void loadPuzzleFromData(Puzzle puzzle) {
    state = PuzzleState(
      puzzle: puzzle,
      remainingPool: List<int>.from(puzzle.numberPool),
    );
  }

  void tick() {
    if (state == null || state!.completed) return;
    state = state!.copyWith(elapsedSeconds: state!.elapsedSeconds + 1);
  }

  /// Cell tapped — either select it, or place if a number is already chosen
  void selectCell(String cellKey) {
    if (state == null || state!.failed) return;

    // If a number from pool is already selected, place it
    if (state!.selectedPoolIndex != null) {
      _doPlace(cellKey, state!.selectedPoolIndex!);
      return;
    }

    // Otherwise just select the cell
    state = state!.copyWith(selectedCell: cellKey, wrongCells: {}, clearPool: true);
  }

  /// Number from pool tapped — either select it, or place if a cell is already chosen
  void selectPoolNumber(int poolIndex) {
    if (state == null || state!.failed) return;
    if (poolIndex < 0 || poolIndex >= state!.remainingPool.length) return;

    // If a cell is already selected, place the number
    if (state!.selectedCell != null) {
      _doPlace(state!.selectedCell!, poolIndex);
      return;
    }

    // Otherwise just select the number
    state = state!.copyWith(selectedPoolIndex: poolIndex, wrongCells: {}, clearSelection: true);
  }

  void clearSelection() {
    if (state == null) return;
    state = state!.copyWith(clearSelection: true, clearPool: true);
  }

  /// Place number from pool at cell — shared by both flows
  void _doPlace(String key, int poolIndex) {
    if (state == null || state!.failed) return;
    if (poolIndex < 0 || poolIndex >= state!.remainingPool.length) return;
    final value = state!.remainingPool[poolIndex];

    final newAnswers = Map<String, int>.from(state!.playerAnswers);
    newAnswers[key] = value;

    // Check equations involving this cell for errors
    final wrongKeys = <String>{};
    final equations = state!.puzzle.equationsForCell(key);
    for (final eq in equations) {
      final v1 = state!.puzzle.getValue(eq.num1Key, newAnswers);
      final v2 = state!.puzzle.getValue(eq.num2Key, newAnswers);
      if (v1 != null && v2 != null) {
        if (!eq.evaluate(v1, v2)) {
          wrongKeys.addAll(eq.allCellKeys);
        }
      }
    }

    if (wrongKeys.isNotEmpty) {
      // Wrong placement — show red, then auto-undo
      final newPool = List<int>.from(state!.remainingPool);
      newPool.removeAt(poolIndex);

      final newHearts = state!.hearts - 1;

      state = state!.copyWith(
        playerAnswers: newAnswers,
        remainingPool: newPool,
        clearSelection: true,
        clearPool: true,
        moves: state!.moves + 1,
        wrongMoves: state!.wrongMoves + 1,
        wrongCells: wrongKeys,
        hearts: newHearts,
        failed: newHearts <= 0,
      );

      // Auto-undo wrong placement after delay (unless game over)
      if (newHearts > 0) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (state != null && state!.wrongCells.isNotEmpty) {
            final revertAnswers = Map<String, int>.from(state!.playerAnswers);
            revertAnswers.remove(key);

            final revertPool = List<int>.from(state!.remainingPool);
            revertPool.add(value);
            revertPool.sort();

            state = state!.copyWith(
              playerAnswers: revertAnswers,
              remainingPool: revertPool,
              wrongCells: {},
            );
          }
        });
      }
      return;
    }

    // Correct placement
    final newPool = List<int>.from(state!.remainingPool);
    newPool.removeAt(poolIndex);

    final newHistory = List<MapEntry<String, int>>.from(state!.moveHistory);
    newHistory.add(MapEntry(key, value));

    // All numbers placed = puzzle complete
    final allAnswered = newPool.isEmpty;

    if (allAnswered) {
      // For local puzzles, verify against answers map
      // For API puzzles (empty answers), trust equation validation above
      final allCorrect = state!.puzzle.answers.isEmpty ||
          state!.puzzle.answers.entries.every(
            (e) => newAnswers[e.key] == e.value,
          );
      final stars = allCorrect
          ? _calculateStars(state!.wrongMoves, state!.elapsedSeconds)
          : 0;

      state = state!.copyWith(
        playerAnswers: newAnswers,
        remainingPool: newPool,
        clearSelection: true,
        clearPool: true,
        moves: state!.moves + 1,
        completed: allCorrect,
        stars: stars,
        moveHistory: newHistory,
        wrongCells: {},
      );
    } else {
      state = state!.copyWith(
        playerAnswers: newAnswers,
        remainingPool: newPool,
        clearSelection: true,
        clearPool: true,
        moves: state!.moves + 1,
        moveHistory: newHistory,
        wrongCells: {},
      );
    }
  }

  void undo() {
    if (state == null || !state!.canUndo) return;

    final history = List<MapEntry<String, int>>.from(state!.moveHistory);
    final lastMove = history.removeLast();

    final newAnswers = Map<String, int>.from(state!.playerAnswers);
    newAnswers.remove(lastMove.key);

    final newPool = List<int>.from(state!.remainingPool);
    newPool.add(lastMove.value);
    newPool.sort();

    state = state!.copyWith(
      playerAnswers: newAnswers,
      remainingPool: newPool,
      clearSelection: true,
      clearPool: true,
      moveHistory: history,
      wrongCells: {},
      undosUsed: state!.undosUsed + 1,
    );
  }

  void useHint() {
    if (state == null || !state!.canHint) return;

    // Find blank cells and try to solve one using equations
    final blankCells = <String>[];
    for (final cell in state!.puzzle.cells) {
      if (cell.isBlank) {
        final key = '${cell.row},${cell.col}';
        if (!state!.playerAnswers.containsKey(key)) {
          blankCells.add(key);
        }
      }
    }
    if (blankCells.isEmpty) return;

    // If we have local answers, use them
    if (state!.puzzle.answers.isNotEmpty) {
      for (final key in blankCells) {
        if (state!.puzzle.answers.containsKey(key)) {
          _placeHint(key, state!.puzzle.answers[key]!);
          return;
        }
      }
      return;
    }

    // For API puzzles: solve using equations
    for (final key in blankCells) {
      final equations = state!.puzzle.equationsForCell(key);
      for (final eq in equations) {
        final currentAnswers = Map<String, int>.from(state!.playerAnswers);
        final v1 = state!.puzzle.getValue(eq.num1Key, currentAnswers);
        final v2 = state!.puzzle.getValue(eq.num2Key, currentAnswers);

        // If one value is known, compute the other
        int? solved;
        if (v1 != null && v2 == null && eq.num2Key == key) {
          solved = _solveForSecond(v1, eq.op, eq.result);
        } else if (v1 == null && v2 != null && eq.num1Key == key) {
          solved = _solveForFirst(eq.op, v2, eq.result);
        }

        if (solved != null && state!.remainingPool.contains(solved)) {
          _placeHint(key, solved);
          return;
        }
      }
    }
  }

  int? _solveForSecond(int a, String op, int result) {
    switch (op) {
      case '+': return result - a;
      case '-': return a - result;
      case '*': return result != 0 && a != 0 && result % a == 0 ? result ~/ a : null;
      case '/': return a != 0 ? a ~/ result : null;
      default: return null;
    }
  }

  int? _solveForFirst(String op, int b, int result) {
    switch (op) {
      case '+': return result - b;
      case '-': return result + b;
      case '*': return result != 0 && b != 0 && result % b == 0 ? result ~/ b : null;
      case '/': return result * b;
      default: return null;
    }
  }

  void _placeHint(String key, int value) {
    final newPool = List<int>.from(state!.remainingPool);
    final poolIdx = newPool.indexOf(value);
    if (poolIdx < 0) return;
    newPool.removeAt(poolIdx);

    final newAnswers = Map<String, int>.from(state!.playerAnswers);
    newAnswers[key] = value;

    final newHistory = List<MapEntry<String, int>>.from(state!.moveHistory);
    newHistory.add(MapEntry(key, value));

    final allAnswered = newPool.isEmpty;

    state = state!.copyWith(
      playerAnswers: newAnswers,
      remainingPool: newPool,
      clearSelection: true,
      clearPool: true,
      moves: state!.moves + 1,
      moveHistory: newHistory,
      hintsUsed: state!.hintsUsed + 1,
      completed: allAnswered,
      stars: allAnswered
          ? _calculateStars(state!.wrongMoves, state!.elapsedSeconds)
          : null,
      wrongCells: {},
    );
  }

  /// Stars based on wrong moves + time
  /// 3 stars: 0 wrong moves AND under time limit
  /// 2 stars: 1-2 wrong moves OR slightly over time
  /// 1 star: 3+ wrong moves OR way over time
  int _calculateStars(int wrongMoves, int seconds) {
    final timeLimit = state!.puzzle.timeLimitSec;
    final overTime = seconds > timeLimit;
    final wayOverTime = seconds > timeLimit * 1.5;

    if (wrongMoves == 0 && !overTime) return 3;
    if (wrongMoves <= 2 && !wayOverTime) return 2;
    return 1;
  }
}
