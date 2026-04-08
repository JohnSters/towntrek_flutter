import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
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

  runApp(const TownTrekApp());
}

class TownTrekApp extends StatelessWidget {
  const TownTrekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TownTrek',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LandingPage(),
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
