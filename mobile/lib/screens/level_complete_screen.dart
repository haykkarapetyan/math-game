import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LevelCompleteScreen extends StatefulWidget {
  final int stars;
  final int xpEarned;
  final int mistakes;
  final int time;
  final int levelId;
  final int tierId;
  final int chapterId;

  const LevelCompleteScreen({
    super.key,
    required this.stars,
    required this.xpEarned,
    required this.mistakes,
    required this.time,
    required this.levelId,
    required this.tierId,
    required this.chapterId,
  });

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _starsController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _starsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _starsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Level Complete!',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _starsController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final starDelay = i * 0.3;
                        final progress = (_starsController.value - starDelay)
                            .clamp(0.0, 0.4) /
                            0.4;
                        final earned = i < widget.stars;

                        return Transform.scale(
                          scale: earned ? (0.5 + progress * 0.5) : 0.8,
                          child: Opacity(
                            opacity: earned ? progress : 0.3,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                earned ? Icons.star : Icons.star_border,
                                size: 64,
                                color: earned
                                    ? Colors.amber
                                    : const Color(0xFFBDBDBD),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 48),
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
                      _StatRow(
                        icon: Icons.bolt,
                        label: 'XP Earned',
                        value: '+${widget.xpEarned}',
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(height: 16),
                      _StatRow(
                        icon: Icons.close,
                        label: 'Wrong Moves',
                        value: '${widget.mistakes}',
                        color: widget.mistakes == 0
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFE65100),
                      ),
                      const SizedBox(height: 16),
                      _StatRow(
                        icon: Icons.timer_outlined,
                        label: 'Time',
                        value:
                            '${widget.time ~/ 60}:${(widget.time % 60).toString().padLeft(2, '0')}',
                        color: const Color(0xFF5D7B9A),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.go('/tier/${widget.tierId}'),
                      icon: const Icon(Icons.list),
                      label: const Text('Levels'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5D7B9A),
                        side: const BorderSide(color: Color(0xFFBDBDBD)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: () {
                        context.pushReplacement(
                          '/puzzle/${widget.levelId + 1}?tierId=${widget.tierId}&chapterId=${widget.chapterId}',
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF3D5AFE),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF5D7B9A), fontSize: 16)),
          ],
        ),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
