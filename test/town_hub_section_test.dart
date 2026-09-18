import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towntrek_flutter/core/constants/town_feature_constants.dart';
import 'package:towntrek_flutter/screens/town_feature_selection/widgets/town_hub_section.dart';
import 'package:towntrek_flutter/theme/app_theme.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  testWidgets('explore town starts expanded', (tester) async {
    await tester.pumpWidget(
      wrap(
        TownHubSection(
          title: TownFeatureConstants.exploreSectionTitle,
          description: TownFeatureConstants.exploreSectionDescription,
          accentColor: const Color(TownFeatureConstants.exploreAccent),
          child: const Text('Businesses'),
        ),
      ),
    );

    expect(find.text('Businesses'), findsOneWidget);
    expect(
      find.text(TownFeatureConstants.exploreSectionDescription),
      findsOneWidget,
    );
  });

  testWidgets('around town starts collapsed and expands on tap', (tester) async {
    await tester.pumpWidget(
      wrap(
        TownHubSection(
          title: TownFeatureConstants.aroundTownSectionTitle,
          description: TownFeatureConstants.aroundTownSectionDescription,
          accentColor: const Color(TownFeatureConstants.aroundTownAccent),
          initiallyExpanded: false,
          child: const Text('Listen'),
        ),
      ),
    );

    expect(find.text('Listen'), findsNothing);

    await tester.tap(
      find.byKey(
        TownHubSection.headerKey(TownFeatureConstants.aroundTownSectionTitle),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Listen'), findsOneWidget);
  });
}
