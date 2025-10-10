import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'theme/app_theme.dart';

void main() {
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
