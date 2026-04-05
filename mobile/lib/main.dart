import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';

/// Current locale provider — defaults to English
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

void main() {
  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: kIsWeb,
        builder: (context) => const MathGameApp(),
      ),
    ),
  );
}

class MathGameApp extends ConsumerWidget {
  const MathGameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Math Crossword',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3D5AFE),
          secondary: Color(0xFFFFB74D),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2C3E50),
          elevation: 0,
          centerTitle: true,
        ),
        fontFamily: 'Roboto',
      ),
      routerConfig: appRouter,
    );
  }
}
