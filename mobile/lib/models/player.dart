/// Player avatars — emoji-based presets
class PlayerAvatar {
  final String id;
  final String emoji;
  final String name;

  const PlayerAvatar({
    required this.id,
    required this.emoji,
    required this.name,
  });
}

const List<PlayerAvatar> availableAvatars = [
  PlayerAvatar(id: 'fox', emoji: '\u{1F98A}', name: 'Fox'),
  PlayerAvatar(id: 'cat', emoji: '\u{1F431}', name: 'Cat'),
  PlayerAvatar(id: 'dog', emoji: '\u{1F436}', name: 'Dog'),
  PlayerAvatar(id: 'bear', emoji: '\u{1F43B}', name: 'Bear'),
  PlayerAvatar(id: 'panda', emoji: '\u{1F43C}', name: 'Panda'),
  PlayerAvatar(id: 'lion', emoji: '\u{1F981}', name: 'Lion'),
  PlayerAvatar(id: 'unicorn', emoji: '\u{1F984}', name: 'Unicorn'),
  PlayerAvatar(id: 'owl', emoji: '\u{1F989}', name: 'Owl'),
  PlayerAvatar(id: 'eagle', emoji: '\u{1F985}', name: 'Eagle'),
  PlayerAvatar(id: 'robot', emoji: '\u{1F916}', name: 'Robot'),
  PlayerAvatar(id: 'alien', emoji: '\u{1F47D}', name: 'Alien'),
  PlayerAvatar(id: 'rocket', emoji: '\u{1F680}', name: 'Rocket'),
];

/// Local player stats
class Player {
  final String username;
  final String email;
  final String avatarId;
  final int xp;
  final int coins;
  final int energy;
  final int maxEnergy;
  final int streak;
  final int starsCollected;
  final int levelsCompleted;
  final bool isLoggedIn;

  const Player({
    this.username = '',
    this.email = '',
    this.avatarId = 'fox',
    this.xp = 0,
    this.coins = 100,
    this.energy = 10,
    this.maxEnergy = 10,
    this.streak = 0,
    this.starsCollected = 0,
    this.levelsCompleted = 0,
    this.isLoggedIn = false,
  });

  PlayerAvatar get avatar =>
      availableAvatars.firstWhere((a) => a.id == avatarId,
          orElse: () => availableAvatars.first);

  Player copyWith({
    String? username,
    String? email,
    String? avatarId,
    int? xp,
    int? coins,
    int? energy,
    int? streak,
    int? starsCollected,
    int? levelsCompleted,
    bool? isLoggedIn,
  }) {
    return Player(
      username: username ?? this.username,
      email: email ?? this.email,
      avatarId: avatarId ?? this.avatarId,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy,
      streak: streak ?? this.streak,
      starsCollected: starsCollected ?? this.starsCollected,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

/// Mock friend data
class Friend {
  final String id;
  final String username;
  final String avatarId;
  final int xp;
  final int starsCollected;
  final bool isOnline;

  const Friend({
    required this.id,
    required this.username,
    required this.avatarId,
    required this.xp,
    required this.starsCollected,
    this.isOnline = false,
  });

  PlayerAvatar get avatar =>
      availableAvatars.firstWhere((a) => a.id == avatarId,
          orElse: () => availableAvatars.first);
}

/// Mock leaderboard entry
class LeaderboardEntry {
  final int rank;
  final String username;
  final String avatarId;
  final int xp;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.avatarId,
    required this.xp,
    this.isCurrentUser = false,
  });

  PlayerAvatar get avatar =>
      availableAvatars.firstWhere((a) => a.id == avatarId,
          orElse: () => availableAvatars.first);
}
