import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towntrek_flutter/screens/town_feature_selection/widgets/town_hub_action_tile.dart';
import 'package:towntrek_flutter/theme/app_theme.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  testWidgets('shows title, subtitle, fallback icon and handles tap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        TownHubActionTile(
          title: 'Listen',
          subtitle: 'Song for coolness',
          fallbackIcon: Icons.graphic_eq_rounded,
          accentColor: const Color(0xFFC4782A),
          onTap: () => taps++,
        ),
      ),
    );

    expect(find.text('Listen'), findsOneWidget);
    expect(find.text('Song for coolness'), findsOneWidget);
    expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget);

    await tester.tap(find.text('Listen'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('collapsed tile is dimmer than an expanded tile', (tester) async {
    const accent = Color(0xFF2E7D32);
    await tester.pumpWidget(
      wrap(
        const Column(
          children: [
            TownHubActionTile(
              key: Key('collapsed'),
              title: 'Closed',
              subtitle: 'Dim',
              accentColor: accent,
              tintColor: accent,
              expanded: false,
              onTap: null,
            ),
            TownHubActionTile(
              key: Key('expanded'),
              title: 'Open',
              subtitle: 'Bright',
              accentColor: accent,
              tintColor: accent,
              expanded: true,
              onTap: null,
            ),
          ],
        ),
      ),
    );

    Color fill(Key key) {
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(key),
          matching: find.byType(AnimatedContainer),
        ),
      );
      return (container.decoration! as BoxDecoration).color!;
    }

    expect(fill(const Key('collapsed')), isNot(fill(const Key('expanded'))));
  });
}
