import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';

class PagesIndexScreen extends ConsumerWidget {
  const PagesIndexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = [
      _PageItem('Splash', '/', Icons.rocket_launch, const Color(0xFF3D5AFE)),
      _PageItem('Login', '/login', Icons.login, const Color(0xFF2196F3)),
      _PageItem('Register', '/register', Icons.person_add, const Color(0xFF2196F3)),
      _PageItem('Home (Tiers)', '/tiers', Icons.home, const Color(0xFF4CAF50)),
      _PageItem('Levels (Tier 1)', '/tier/1', Icons.grid_view, const Color(0xFF4CAF50)),
      _PageItem('Puzzle (Level 1)', '/puzzle/1?tierId=1&chapterId=1', Icons.extension, const Color(0xFFFF9800)),
      _PageItem('Level Complete', null, Icons.star, const Color(0xFFFFD54F), subtitle: 'Play a level first'),
      _PageItem('Leaderboard', '/tiers', Icons.leaderboard, const Color(0xFF9C27B0), subtitle: 'Tab 2 in Home'),
      _PageItem('Friends', '/tiers', Icons.people, const Color(0xFF00BCD4), subtitle: 'Tab 3 in Home'),
      _PageItem('Profile', '/tiers', Icons.person, const Color(0xFFE91E63), subtitle: 'Tab 4 in Home'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('All Pages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: page.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(page.icon, color: page.color),
              ),
              title: Text(page.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50))),
              subtitle: page.subtitle != null
                  ? Text(page.subtitle!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF90A4AE)))
                  : null,
              trailing: page.route != null
                  ? const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD))
                  : const Icon(Icons.lock_outline,
                      color: Color(0xFFBDBDBD), size: 18),
              onTap: page.route != null
                  ? () {
                      // Ensure logged in as guest for game pages
                      final player = ref.read(playerProvider);
                      if (!player.isLoggedIn) {
                        ref.read(playerProvider.notifier).login('Guest', 'guest@mathgame.app');
                      }
                      context.push(page.route!);
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _PageItem {
  final String name;
  final String? route;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _PageItem(this.name, this.route, this.icon, this.color, {this.subtitle});
}
