import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towntrek_flutter/models/town_admin_public_dto.dart';
import 'package:towntrek_flutter/screens/town_feature_selection/widgets/town_admin_banner.dart';
import 'package:towntrek_flutter/theme/app_theme.dart';

void main() {
  const anna = PublicTownAdminProfileDto(
    id: 1,
    displayName: 'Anna Admin',
    title: 'Town Admin',
    email: 'anna@test.local',
  );
  const zane = PublicTownAdminProfileDto(
    id: 2,
    displayName: 'Zane Admin',
    title: 'Town Admin',
  );

  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  testWidgets('single admin keeps the name row and opens details', (
    tester,
  ) async {
    var opened = 0;
    await tester.pumpWidget(
      wrap(
        TownAdminBanner(profile: anna, onOpenDetail: () => opened++),
      ),
    );

    expect(find.byKey(TownAdminBanner.switchButtonKey), findsNothing);
    expect(find.text('Anna Admin'), findsOneWidget);

    await tester.tap(find.text('Anna Admin'));
    await tester.pump();
    expect(opened, 1);
  });

  testWidgets('multiple admins use separate switch and details buttons', (
    tester,
  ) async {
    var selected = anna;
    var opened = 0;

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return TownAdminBanner(
              profile: selected,
              profiles: const [anna, zane],
              onSelect: (next) => setState(() => selected = next),
              onOpenDetail: () => opened++,
            );
          },
        ),
      ),
    );

    expect(find.byKey(TownAdminBanner.switchButtonKey), findsOneWidget);
    expect(find.byKey(TownAdminBanner.detailsButtonKey), findsOneWidget);

    await tester.tap(find.byKey(TownAdminBanner.detailsButtonKey));
    await tester.pump();
    expect(opened, 1);

    await tester.tap(find.byKey(TownAdminBanner.switchButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zane Admin').last);
    await tester.pumpAndSettle();

    expect(selected.id, zane.id);
    expect(opened, 1);
  });
}
