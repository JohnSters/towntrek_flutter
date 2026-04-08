import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'board_screen.dart';

class GuestBoardScreen extends StatelessWidget {
  const GuestBoardScreen({super.key, required this.town});

  final TownDto town;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: serviceLocator.mobileSessionManager,
      builder: (context, _) {
        if (serviceLocator.mobileSessionManager.isAuthenticated) {
          return BoardScreen(town: town);
        }
        return ParcelBoardScaffold(town: town, authenticatedMode: false);
      },
    );
  }
}
