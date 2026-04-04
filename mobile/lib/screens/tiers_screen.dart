import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';

class TiersScreen extends ConsumerWidget {
  const TiersScreen({super.key});

  static const _tierColors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
  ];

  static const _tierIcons = [
    Icons.calculate_outlined,
    Icons.functions_outlined,
    Icons.architecture_outlined,
    Icons.school_outlined,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiers = ref.watch(tiersProvider);
    final player = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Math Crossword',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('${player.coins}',
                    style: const TextStyle(
                        color: Color(0xFF8B6914),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: Colors.green, size: 20),
                const SizedBox(width: 4),
                Text('${player.energy}/${player.maxEnergy}',
                    style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // XP card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${player.xp} XP',
                          style: const TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text('${player.starsCollected} stars collected',
                          style: const TextStyle(
                              color: Color(0xFF90A4AE), fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Choose a Tier',
                style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: tiers.length,
                itemBuilder: (context, index) {
                  final tier = tiers[index];
                  final color = _tierColors[index % _tierColors.length];
                  final icon = _tierIcons[index % _tierIcons.length];

                  return _TierCard(
                    tier: tier,
                    color: color,
                    icon: icon,
                    onTap: tier.unlocked
                        ? () => context.push('/tier/${tier.id}')
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final dynamic tier;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _TierCard({
    required this.tier,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = onTap == null;

    return Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.white,
        elevation: locked ? 0 : 2,
        shadowColor: color.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: locked
                  ? const Color(0xFFE0E0E0)
                  : color.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tier.name,
                          style: TextStyle(
                              color: color,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(tier.subtitle,
                          style: const TextStyle(
                              color: Color(0xFF90A4AE), fontSize: 14)),
                    ],
                  ),
                ),
                if (locked)
                  const Icon(Icons.lock, color: Color(0xFFBDBDBD))
                else
                  Icon(Icons.chevron_right, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
