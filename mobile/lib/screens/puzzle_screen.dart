import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api/api_client.dart';
import '../providers/api_providers.dart';
import '../providers/game_provider.dart';
import '../widgets/crossword_grid.dart';
import '../widgets/game_loader.dart';
import '../widgets/number_pool.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  final int levelId;
  final int tierId;
  final int chapterId;

  const PuzzleScreen({
    super.key,
    required this.levelId,
    required this.tierId,
    required this.chapterId,
  });

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  Timer? _timer;
  int? _serverPuzzleId; // for API submission

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPuzzle();
    });
  }

  Future<void> _loadPuzzle() async {
    final api = ref.read(apiClientProvider);
    if (await api.hasToken()) {
      // Load from API
      try {
        final apiPuzzle = await ref.read(apiPuzzleProvider(widget.levelId).future);
        if (apiPuzzle != null) {
          _serverPuzzleId = apiPuzzle.id;
          ref.read(puzzleProvider.notifier).loadPuzzleFromData(apiPuzzle.puzzle);
        }
      } catch (_) {
        // Fall back to local generator
        ref.read(puzzleProvider.notifier).loadPuzzle(widget.levelId);
      }
    } else {
      ref.read(puzzleProvider.notifier).loadPuzzle(widget.levelId);
    }
    ref.read(playerProvider.notifier).useEnergy();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(puzzleProvider.notifier).tick();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final puzzleState = ref.watch(puzzleProvider);

    ref.listen(puzzleProvider, (prev, next) {
      if (next != null && next.completed && (prev == null || !prev.completed)) {
        _timer?.cancel();
        _onPuzzleComplete(next);
      }
      if (next != null && next.failed && (prev == null || !prev.failed)) {
        _timer?.cancel();
        _onGameOver();
      }
    });

    if (puzzleState == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F4F8),
        body: GameLoader(message: 'Generating puzzle...'),
      );
    }

    final timeLimit = puzzleState.puzzle.timeLimitSec;
    final elapsed = puzzleState.elapsedSeconds;
    final isOverTime = elapsed > timeLimit;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text('Level ${widget.levelId}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Hearts
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        i < puzzleState.hearts
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 22,
                        color: i < puzzleState.hearts
                            ? const Color(0xFFE53935)
                            : const Color(0xFFBDBDBD),
                      ),
                    ),
                  ),
                ),
                // Timer
                _StatChip(
                  icon: Icons.timer_outlined,
                  label: _formatTime(elapsed),
                  color: isOverTime
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF5D7B9A),
                ),
                // Moves
                _StatChip(
                  icon: Icons.touch_app_outlined,
                  label: '${puzzleState.moves}',
                  color: const Color(0xFF5D7B9A),
                ),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CrosswordGrid(
                  puzzle: puzzleState.puzzle,
                  playerAnswers: puzzleState.playerAnswers,
                  selectedCell: puzzleState.selectedCell,
                  wrongCells: puzzleState.wrongCells,
                  onCellTap: (cellKey) {
                    final parts = cellKey.split(',');
                    final r = int.parse(parts[0]);
                    final c = int.parse(parts[1]);
                    final cell = puzzleState.puzzle.cellAt(r, c);
                    final isBlank = cell != null && cell.isBlank;
                    final isAnswerable = isBlank &&
                        !puzzleState.playerAnswers.containsKey(cellKey);
                    if (isAnswerable) {
                      ref.read(puzzleProvider.notifier).selectCell(cellKey);
                    }
                  },
                  onDrop: (cellKey, poolIndex) {
                    // Direct drag-and-drop: select cell then place number
                    ref.read(puzzleProvider.notifier).selectCell(cellKey);
                    ref.read(puzzleProvider.notifier).selectPoolNumber(poolIndex);
                  },
                ),
              ),
            ),
          ),
          // Bottom panel: number pool + action buttons
          if (!puzzleState.completed && !puzzleState.failed)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Number pool
                      NumberPool(
                        availableNumbers: puzzleState.remainingPool,
                        selectedIndex: puzzleState.selectedPoolIndex,
                        onNumberTap: (poolIndex) {
                          ref
                              .read(puzzleProvider.notifier)
                              .selectPoolNumber(poolIndex);
                        },
                      ),
                      const SizedBox(height: 8),
                      // Action buttons (disabled for guests)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ActionButton(
                            icon: Icons.undo,
                            label: _isGuest(ref)
                                ? 'Undo (Login)'
                                : 'Undo (${puzzleState.maxUndos - puzzleState.undosUsed})',
                            enabled: !_isGuest(ref) && puzzleState.canUndo,
                            onTap: () =>
                                ref.read(puzzleProvider.notifier).undo(),
                          ),
                          const SizedBox(width: 16),
                          _ActionButton(
                            icon: Icons.lightbulb_outline,
                            label: _isGuest(ref)
                                ? 'Hint (Login)'
                                : 'Hint (${puzzleState.maxHints - puzzleState.hintsUsed})',
                            enabled: !_isGuest(ref) && puzzleState.canHint,
                            onTap: () =>
                                ref.read(puzzleProvider.notifier).useHint(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onPuzzleComplete(PuzzleState state) async {
    var xpEarned = _calculateXp(state.stars);
    var stars = state.stars;

    // Submit to API if we have a server puzzle ID
    if (_serverPuzzleId != null) {
      try {
        final api = ref.read(apiClientProvider);
        final cells = state.playerAnswers.entries.map((e) {
          final parts = e.key.split(',');
          return {
            'row': int.parse(parts[0]),
            'col': int.parse(parts[1]),
            'value': e.value,
          };
        }).toList();

        final result = await api.submitPuzzle(
          _serverPuzzleId!,
          cells,
          state.elapsedSeconds * 1000,
          state.wrongMoves,
        );

        // Use server-computed values
        xpEarned = result['xp_earned'] ?? xpEarned;
        stars = result['stars'] ?? stars;

        // Invalidate API caches so levels refresh
        ref.invalidate(apiLevelsProvider(widget.tierId));
        ref.invalidate(apiTiersProvider);
      } catch (_) {
        // Continue with local values if API fails
      }
    }

    // Update local state
    ref.read(tiersProvider.notifier).completeLevel(
          widget.tierId,
          widget.chapterId,
          widget.levelId,
          stars,
        );
    ref.read(playerProvider.notifier).addXp(xpEarned);
    ref.read(playerProvider.notifier).addStars(stars);
    ref.read(playerProvider.notifier).completeLevel();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        context.pushReplacement('/complete', extra: {
          'stars': stars,
          'xpEarned': xpEarned,
          'mistakes': state.wrongMoves,
          'time': state.elapsedSeconds,
          'levelId': widget.levelId,
          'tierId': widget.tierId,
          'chapterId': widget.chapterId,
        });
      }
    });
  }

  void _onGameOver() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Game Over'),
          content: const Text('You ran out of hearts! Try again?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/tier/${widget.tierId}');
              },
              child: const Text('Back to Levels'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(puzzleProvider.notifier).loadPuzzle(widget.levelId);
                _timer?.cancel();
                _startTimer();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    });
  }

  bool _isGuest(WidgetRef ref) {
    final player = ref.read(playerProvider);
    return !player.isLoggedIn || player.username == 'Guest';
  }

  int _calculateXp(int stars) {
    switch (stars) {
      case 3:
        return 100;
      case 2:
        return 50;
      default:
        return 25;
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.35,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0E6FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF7C4DFF), size: 20),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF7C4DFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
