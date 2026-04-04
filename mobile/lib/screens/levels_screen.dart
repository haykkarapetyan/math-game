import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';

class LevelsScreen extends ConsumerWidget {
  final int tierId;
  const LevelsScreen({super.key, required this.tierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiers = ref.watch(tiersProvider);
    final tier = tiers.firstWhere((t) => t.id == tierId);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(tier.name),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tier.chapters.length,
        itemBuilder: (context, chapterIndex) {
          final chapter = tier.chapters[chapterIndex];
          final locked = !chapter.unlocked;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Chapter ${chapterIndex + 1}: ${chapter.name}',
                      style: TextStyle(
                        color: locked
                            ? const Color(0xFFBDBDBD)
                            : const Color(0xFF2C3E50),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (locked) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.lock,
                          size: 16, color: Color(0xFFBDBDBD)),
                    ],
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: chapter.levels.length,
                itemBuilder: (context, levelIndex) {
                  final level = chapter.levels[levelIndex];
                  return _LevelButton(
                    level: level,
                    locked: locked || !level.unlocked,
                    onTap: (!locked && level.unlocked)
                        ? () => context.push(
                              '/puzzle/${level.id}?tierId=${tier.id}&chapterId=${chapter.id}',
                            )
                        : null,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final dynamic level;
  final bool locked;
  final VoidCallback? onTap;

  const _LevelButton({
    required this.level,
    required this.locked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = level.completed as bool;
    final stars = level.stars as int;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: locked
              ? const Color(0xFFE8E8E8)
              : completed
                  ? const Color(0xFFE8F5E9)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: locked
                ? const Color(0xFFD0D0D0)
                : completed
                    ? const Color(0xFF81C784)
                    : const Color(0xFF90CAF9),
            width: 1.5,
          ),
          boxShadow: locked
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (locked)
              const Icon(Icons.lock, size: 18, color: Color(0xFFBDBDBD))
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
                    color:
                        i < stars ? Colors.amber : const Color(0xFFBDBDBD),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
