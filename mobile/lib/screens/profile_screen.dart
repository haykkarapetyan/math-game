import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../api/api_client.dart';
import '../main.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF5D7B9A)),
            onPressed: () async {
              await ref.read(apiClientProvider).logout();
              ref.read(playerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + name card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () => _showAvatarPicker(context, ref),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F8),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF3D5AFE), width: 3),
                          ),
                          child: Center(
                            child: Text(player.avatar.emoji,
                                style: const TextStyle(fontSize: 40)),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF3D5AFE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    player.username.isEmpty ? 'Player' : player.username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  if (player.email.isNotEmpty)
                    Text(player.email,
                        style: const TextStyle(
                            color: Color(0xFF90A4AE), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.star,
                    color: Colors.amber,
                    value: '${player.xp}',
                    label: 'XP',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.auto_awesome,
                    color: const Color(0xFFFF9800),
                    value: '${player.starsCollected}',
                    label: 'Stars',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.monetization_on,
                    color: const Color(0xFFFFC107),
                    value: '${player.coins}',
                    label: 'Coins',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                    value: '${player.levelsCompleted}',
                    label: 'Levels',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.bolt,
                    color: const Color(0xFF4CAF50),
                    value: '${player.energy}/${player.maxEnergy}',
                    label: 'Energy',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFFF5722),
                    value: '${player.streak}',
                    label: 'Streak',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Language selector
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)?.profile ?? 'Language',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _LanguageChip(
                        label: 'English',
                        locale: const Locale('en'),
                        ref: ref,
                      ),
                      const SizedBox(width: 8),
                      _LanguageChip(
                        label: 'Հայerен',
                        locale: const Locale('hy'),
                        ref: ref,
                      ),
                      const SizedBox(width: 8),
                      _LanguageChip(
                        label: 'Русский',
                        locale: const Locale('ru'),
                        ref: ref,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Achievements placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Achievements',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50))),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _AchievementBadge(
                          emoji: '\u{1F31F}', label: 'First Win', earned: true),
                      _AchievementBadge(
                          emoji: '\u{1F525}', label: '7-Day Streak'),
                      _AchievementBadge(
                          emoji: '\u{1F3C6}', label: 'Top 10'),
                      _AchievementBadge(
                          emoji: '\u{1F9E0}', label: 'Math Genius'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose Avatar',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50))),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: availableAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = availableAvatars[index];
                  final isSelected =
                      ref.read(playerProvider).avatarId == avatar.id;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ref
                          .read(playerProvider.notifier)
                          .setAvatar(avatar.id);
                      ref
                          .read(apiClientProvider)
                          .updateProfile(avatar: avatar.id);
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE8EAF6)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF3D5AFE), width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(avatar.emoji,
                            style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50))),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF90A4AE))),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final bool earned;

  const _AchievementBadge({
    required this.emoji,
    required this.label,
    this.earned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1.0 : 0.35,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF5D7B9A))),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final Locale locale;
  final WidgetRef ref;

  const _LanguageChip({
    required this.label,
    required this.locale,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(localeProvider);
    final isSelected = current.languageCode == locale.languageCode;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(localeProvider.notifier).state = locale;
        ref.read(apiClientProvider).updateProfile(language: locale.languageCode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3D5AFE)
              : const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF5D7B9A),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
