import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api/api_client.dart';
import '../providers/game_provider.dart';
import '../widgets/game_loader.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final api = ref.read(apiClientProvider);
    if (await api.hasToken()) {
      // Try to restore session
      try {
        final data = await api.getMe();
        final user = data['user'];
        ref.read(playerProvider.notifier).login(
          user['username'] ?? '',
          user['email'] ?? '',
        );
        if (user['avatar'] != null) {
          ref.read(playerProvider.notifier).setAvatar(user['avatar']);
        }
        if (mounted) context.go('/tiers');
        return;
      } catch (_) {
        // Token expired or invalid — go to login
      }
    }

    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF0F4F8),
      body: GameLoader(message: 'Math Crossword'),
    );
  }
}
