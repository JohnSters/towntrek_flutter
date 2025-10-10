import 'package:flutter/material.dart';
import 'core/core.dart';
import 'screens/landing_page.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    );
  }
}
