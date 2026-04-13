import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'leaderboard_screen.dart';
import 'my_activity_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';

enum ParcelMemberHubAction { leaderboard, progress, activity, profile }

void openParcelMemberHubAction(
  BuildContext context, {
  required TownDto town,
  required ParcelMemberHubAction action,
}) {
  switch (action) {
    case ParcelMemberHubAction.leaderboard:
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => LeaderboardScreen(town: town)));
      break;
    case ParcelMemberHubAction.progress:
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ProgressScreen()));
      break;
    case ParcelMemberHubAction.activity:
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const MyActivityScreen()));
      break;
    case ParcelMemberHubAction.profile:
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
      break;
  }
}
