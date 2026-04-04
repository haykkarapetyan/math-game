import 'dart:math';
import 'package:flutter/material.dart';

/// Animated math-themed loading screen
class GameLoader extends StatefulWidget {
  final String? message;

  const GameLoader({super.key, this.message});

  @override
  State<GameLoader> createState() => _GameLoaderState();
}

class _GameLoaderState extends State<GameLoader> with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late AnimationController _symbolController;
  late Animation<double> _pulseAnimation;

  static const _symbols = ['+', '-', '\u00D7', '\u00F7', '=', '?'];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _symbolController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating math symbols ring
            SizedBox(
              width: 140,
              height: 140,
              child: AnimatedBuilder(
                animation: _spinController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Orbiting symbols
                      for (var i = 0; i < _symbols.length; i++)
                        _buildOrbitingSymbol(i),
                      // Center pulsing icon
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D5AFE),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF3D5AFE).withValues(alpha: 0.3),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.calculate_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Loading dots
            _LoadingDots(),
            if (widget.message != null) ...[
              const SizedBox(height: 16),
              Text(
                widget.message!,
                style: const TextStyle(
                  color: Color(0xFF5D7B9A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrbitingSymbol(int index) {
    final angle =
        (2 * pi * index / _symbols.length) + (_spinController.value * 2 * pi);
    final radius = 55.0;
    final dx = cos(angle) * radius;
    final dy = sin(angle) * radius;

    // Fade based on position (back = faded, front = bright)
    final opacity = 0.4 + 0.6 * ((sin(angle) + 1) / 2);

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Opacity(
        opacity: opacity,
        child: Text(
          _symbols[index],
          style: TextStyle(
            color: const Color(0xFF3D5AFE),
            fontSize: 20 + (sin(angle) + 1) * 3, // size varies with depth
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

/// Animated loading dots (. .. ...)
class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final progress = (_controller.value - delay).clamp(0.0, 0.6) / 0.6;
            final y = -8.0 * sin(progress * pi);

            return Transform.translate(
              offset: Offset(0, y),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    const Color(0xFFBBDEFB),
                    const Color(0xFF3D5AFE),
                    progress,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
