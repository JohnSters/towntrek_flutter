import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towntrek_flutter/core/constants/landing_page_constants.dart';
import 'package:towntrek_flutter/core/constants/request_town_constants.dart';
import 'package:towntrek_flutter/screens/landing_page/widgets/town_availability_fab.dart';

void main() {
  const bounds = Size(400, 800);

  void setSurface(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget wrapFab({required VoidCallback onPressed, Size size = bounds}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TownAvailabilityFab(onPressed: onPressed, bounds: size),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('shows a map icon with town availability tooltip', (
    tester,
  ) async {
    setSurface(tester, bounds);
    await tester.pumpWidget(wrapFab(onPressed: () {}));

    expect(find.byIcon(Icons.map_rounded), findsOneWidget);
    expect(find.text(RequestTownConstants.landingCta), findsNothing);
    expect(find.byTooltip(RequestTownConstants.landingCta), findsOneWidget);
  });

  testWidgets('tap triggers onPressed', (tester) async {
    var taps = 0;
    setSurface(tester, bounds);
    await tester.pumpWidget(wrapFab(onPressed: () => taps++));

    await tester.tap(find.byKey(TownAvailabilityFab.buttonKey));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('starts in the bottom-right and can be dragged', (tester) async {
    setSurface(tester, bounds);
    await tester.pumpWidget(wrapFab(onPressed: () {}));

    final start = tester.getTopLeft(find.byKey(TownAvailabilityFab.buttonKey));
    expect(
      start.dx,
      closeTo(
        bounds.width -
            LandingScreenConstants.townAvailabilityFabSize -
            LandingScreenConstants.townAvailabilityFabMargin,
        1,
      ),
    );
    expect(
      start.dy,
      closeTo(
        bounds.height -
            LandingScreenConstants.townAvailabilityFabSize -
            LandingScreenConstants.townAvailabilityFabMargin,
        1,
      ),
    );

    await tester.drag(
      find.byKey(TownAvailabilityFab.buttonKey),
      const Offset(-80, -120),
    );
    await tester.pumpAndSettle();

    final moved = tester.getTopLeft(find.byKey(TownAvailabilityFab.buttonKey));
    expect(moved.dx, lessThan(start.dx - 40));
    expect(moved.dy, lessThan(start.dy - 40));
  });
}
