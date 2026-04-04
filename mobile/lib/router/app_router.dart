import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/pages_index_screen.dart';
import '../screens/main_shell.dart';
import '../screens/levels_screen.dart';
import '../screens/puzzle_screen.dart';
import '../screens/level_complete_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/pages',
      builder: (context, state) => const PagesIndexScreen(),
    ),
    GoRoute(
      path: '/tiers',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/tier/:tierId',
      builder: (context, state) {
        final tierId = int.parse(state.pathParameters['tierId']!);
        return LevelsScreen(tierId: tierId);
      },
    ),
    GoRoute(
      path: '/puzzle/:levelId',
      builder: (context, state) {
        final levelId = int.parse(state.pathParameters['levelId']!);
        final tierId = int.parse(state.uri.queryParameters['tierId'] ?? '1');
        final chapterId =
            int.parse(state.uri.queryParameters['chapterId'] ?? '1');
        return PuzzleScreen(
          levelId: levelId,
          tierId: tierId,
          chapterId: chapterId,
        );
      },
    ),
    GoRoute(
      path: '/complete',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LevelCompleteScreen(
          stars: extra['stars'] as int,
          xpEarned: extra['xpEarned'] as int,
          mistakes: extra['mistakes'] as int,
          time: extra['time'] as int,
          levelId: extra['levelId'] as int,
          tierId: extra['tierId'] as int,
          chapterId: extra['chapterId'] as int,
        );
      },
    ),
  ],
);
