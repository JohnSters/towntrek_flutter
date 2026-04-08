import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towntrek_flutter/core/widgets/discovery_vote_rail.dart';

void main() {
  testWidgets('shows score and triggers vote callbacks', (tester) async {
    var upTaps = 0;
    var downTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoveryVoteRail(
            voteScore: 3,
            currentDeviceVote: null,
            onVoteUp: () => upTaps++,
            onVoteDown: () => downTaps++,
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byTooltip('Vote up'));
    await tester.tap(find.byTooltip('Vote down'));

    expect(upTaps, 1);
    expect(downTaps, 1);
  });

  testWidgets('shows active vote affordances and loading indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoveryVoteRail(
            voteScore: -2,
            currentDeviceVote: -1,
            votePending: true,
            onVoteUp: () {},
            onVoteDown: () {},
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byTooltip('Remove downvote'), findsOneWidget);
  });
}
