import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GuestLockOverlay extends StatelessWidget {
  final String title;
  final String subtitle;

  const GuestLockOverlay({
    super.key,
    required this.title,
    this.subtitle = 'Create an account to unlock this feature',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
              ),
              child: const Icon(Icons.lock_outline,
                  size: 36, color: Color(0xFF90A4AE)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50))),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF90A4AE))),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Create Account'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3D5AFE),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account? Login',
                  style: TextStyle(color: Color(0xFF5D7B9A))),
            ),
          ],
        ),
      ),
    );
  }
}
