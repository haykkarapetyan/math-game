import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/api_providers.dart';
import '../providers/game_provider.dart';
import '../widgets/game_loader.dart';

class LevelsScreen extends ConsumerWidget {
  final int tierId;
  const LevelsScreen({super.key, required this.tierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final apiLevels = ref.watch(apiLevelsProvider(tierId));

    // Try API first, fall back to mock tiers
    return apiLevels.when(
      data: (levels) {
        if (levels.isNotEmpty) {
          return _buildScaffold(context, ref, levels, tierId);
        }
        return _buildFromMock(context, ref);
      },
      loading: () {
        // Show mock data while loading
        if (player.isLoggedIn) {
          return const Scaffold(
            backgroundColor: Color(0xFFF0F4F8),
            body: GameLoader(message: 'Loading levels...'),
          );
        }
        return _buildFromMock(context, ref);
      },
      error: (_, _) => _buildFromMock(context, ref),
    );
  }

  Widget _buildFromMock(BuildContext context, WidgetRef ref) {
    final tiers = ref.watch(tiersProvider);
    final tier = tiers.firstWhere((t) => t.id == tierId, orElse: () => tiers.first);

    // Flatten all chapter levels into one list
    final allLevels = tier.chapters.expand((c) => c.levels).toList();
    return _buildScaffold(context, ref, allLevels, tierId);
  }

  Widget _buildScaffold(BuildContext context, WidgetRef ref, List levels, int tierId) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text('Tier $tierId'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final completed = level.completed;
          final unlocked = level.unlocked;
          final stars = level.stars;
          final isBonus = level.isBonus;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: unlocked
                ? () => context.push(
                      '/puzzle/${level.id}?tierId=$tierId&chapterId=1&bonus=${isBonus ? 1 : 0}',
                    )
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: !unlocked
                    ? const Color(0xFFE8E8E8)
                    : isBonus
                        ? const Color(0xFFFFF8E1)
                        : completed
                            ? const Color(0xFFE8F5E9)
                            : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !unlocked
                      ? const Color(0xFFD0D0D0)
                      : isBonus
                          ? const Color(0xFFFFB300)
                          : completed
                              ? const Color(0xFF81C784)
                              : const Color(0xFF90CAF9),
                  width: isBonus ? 2.5 : 1.5,
                ),
                boxShadow: !unlocked
                    ? null
                    : [
                        BoxShadow(
                          color: isBonus
                              ? Colors.amber.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: isBonus ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!unlocked)
                    const Icon(Icons.lock,
                        size: 18, color: Color(0xFFBDBDBD))
                  else if (isBonus)
                    const Icon(Icons.star,
                        size: 20, color: Color(0xFFFFB300))
                  else
                    Text(
                      '${level.number}',
                      style: TextStyle(
                        color: completed
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF2C3E50),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (completed) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Icon(
                          i < stars ? Icons.star : Icons.star_border,
                          size: 12,
                          color: i < stars
                              ? Colors.amber
                              : const Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
