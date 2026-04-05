import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_providers.dart';
import '../providers/game_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockLeaderboard = ref.watch(leaderboardProvider);
    final player = ref.watch(playerProvider);
    final apiGlobal = ref.watch(apiLeaderboardProvider('global'));
    final apiFriends = ref.watch(apiLeaderboardProvider('friends'));

    final globalEntries = apiGlobal.when(
      data: (d) => d.isNotEmpty ? d : mockLeaderboard,
      loading: () => mockLeaderboard,
      error: (_, _) => mockLeaderboard,
    );
    final friendEntries = apiFriends.when(
      data: (d) => d.isNotEmpty ? d : mockLeaderboard,
      loading: () => mockLeaderboard,
      error: (_, _) => mockLeaderboard,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3D5AFE),
          unselectedLabelColor: const Color(0xFF90A4AE),
          indicatorColor: const Color(0xFF3D5AFE),
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Friends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LeaderboardList(
            entries: globalEntries,
            currentPlayerXp: player.xp,
            currentPlayerAvatar: player.avatarId,
            currentPlayerName: player.username,
          ),
          _LeaderboardList(
            entries: friendEntries,
            currentPlayerXp: player.xp,
            currentPlayerAvatar: player.avatarId,
            currentPlayerName: player.username,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List entries;
  final int currentPlayerXp;
  final String currentPlayerAvatar;
  final String currentPlayerName;

  const _LeaderboardList({
    required this.entries,
    required this.currentPlayerXp,
    required this.currentPlayerAvatar,
    required this.currentPlayerName,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top 3 podium
        if (entries.length >= 3)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _PodiumCard(entry: entries[1], height: 90, medal: '\u{1F948}'),
                const SizedBox(width: 8),
                _PodiumCard(entry: entries[0], height: 110, medal: '\u{1F947}'),
                const SizedBox(width: 8),
                _PodiumCard(entry: entries[2], height: 70, medal: '\u{1F949}'),
              ],
            ),
          ),
        // Rest of the list
        for (var i = 3; i < entries.length; i++)
          _RankTile(entry: entries[i]),
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final dynamic entry;
  final double height;
  final String medal;

  const _PodiumCard({
    required this.entry,
    required this.height,
    required this.medal,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = entry.isCurrentUser as bool;

    return Column(
      children: [
        Text(medal, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(entry.avatar.emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          entry.username,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isCurrentUser
                ? const Color(0xFF3D5AFE)
                : const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 2),
        Text('${entry.xp} XP',
            style: const TextStyle(fontSize: 11, color: Color(0xFF90A4AE))),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isCurrentUser
                  ? [
                      const Color(0xFF3D5AFE).withValues(alpha: 0.3),
                      const Color(0xFF3D5AFE).withValues(alpha: 0.1),
                    ]
                  : [
                      const Color(0xFFFFD54F).withValues(alpha: 0.3),
                      const Color(0xFFFFD54F).withValues(alpha: 0.1),
                    ],
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D7B9A)),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankTile extends StatelessWidget {
  final dynamic entry;

  const _RankTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = entry.isCurrentUser as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFFE8EAF6)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isCurrentUser
            ? Border.all(color: const Color(0xFF3D5AFE), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCurrentUser
                    ? const Color(0xFF3D5AFE)
                    : const Color(0xFF5D7B9A),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(entry.avatar.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.username,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isCurrentUser
                    ? const Color(0xFF3D5AFE)
                    : const Color(0xFF2C3E50),
              ),
            ),
          ),
          Text(
            '${entry.xp} XP',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF90A4AE)),
          ),
        ],
      ),
    );
  }
}
