import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../business_category/business_category.dart';
import '../current_events/current_events_screen.dart';
import '../service_category/service_category_page.dart';
import '../town_selection/town_selection_screen.dart';
import 'town_feature_selection_screen.dart';
import 'town_feature_selection_state.dart';

/// ViewModel for navigation logic separation
class TownFeatureViewModel extends ChangeNotifier {
  final TownFeatureState _state;
  TownFeatureState get state => _state;

  TownFeatureViewModel(TownDto town) : _state = TownFeatureLoaded(town);

  Future<void> changeTown(BuildContext context) async {
    final selectedTown = await Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    );

    if (selectedTown != null && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TownFeatureSelectionScreen(town: selectedTown),
        ),
      );
    }
  }

  void navigateToBusinesses(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessCategoryPage(town: town),
      ),
    );
  }

  void navigateToServices(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceCategoryPage(town: town),
      ),
    );
  }

  void navigateToEvents(BuildContext context, TownDto town) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CurrentEventsScreen(
          townId: town.id,
          townName: town.name,
        ),
      ),
    );
  }
}