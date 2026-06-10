import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/core.dart';
import 'core/config/http_overrides.dart';
import 'screens/landing_page.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolve best dev base URL early (before ApiClient/DI init).
  await ApiConfig.initialize();

  // Setup HTTP overrides for local development if not in production
  if (ApiConfig.environment != AppEnvironment.production) {
    HttpOverrides.global = LocalDevHttpOverrides();
  }

  // Initialize service locator and dependencies
  serviceLocator.initialize();
  await serviceLocator.mobileSessionManager.initialize();

  runApp(const TownTrekApp());
}

class TownTrekApp extends StatefulWidget {
  const TownTrekApp({super.key});

  @override
  State<TownTrekApp> createState() => _TownTrekAppState();
}

class _TownTrekAppState extends State<TownTrekApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Proactively refresh a stale session so the next action doesn't fail
      // with a surprise 401. No-op when no device is connected.
      final sessionManager = serviceLocator.mobileSessionManager;
      if (sessionManager.isAuthenticated) {
        unawaited(sessionManager.ensureAuthenticated());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: AppScaffoldMessenger.key,
      title: 'TownTrek',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LandingScreen(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final surface = theme.colorScheme.surface;
        final overlayStyle = isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: surface,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: surface,
                systemNavigationBarIconBrightness: Brightness.dark,
              );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
