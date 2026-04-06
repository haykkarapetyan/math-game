/// Education tier (grade group)
class Tier {
  final int id;
  final String name;
  final String subtitle;
  final int minGrade;
  final int maxGrade;
  final List<Chapter> chapters;
  final bool unlocked;

  const Tier({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.minGrade,
    required this.maxGrade,
    required this.chapters,
    this.unlocked = false,
  });
}

/// A chapter within a tier
class Chapter {
  final int id;
  final String name;
  final int tierId;
  final List<Level> levels;
  final bool unlocked;

  const Chapter({
    required this.id,
    required this.name,
    required this.tierId,
    required this.levels,
    this.unlocked = false,
  });
}

/// A single level (one crossword puzzle)
class Level {
  final int id;
  final int number;
  final int chapterId;
  final int stars; // 0-3, earned by player
  final bool unlocked;
  final bool completed;
  final bool isBonus;

  const Level({
    required this.id,
    required this.number,
    required this.chapterId,
    this.stars = 0,
    this.unlocked = false,
    this.completed = false,
    this.isBonus = false,
  });
}
