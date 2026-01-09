import '../../models/models.dart';

// State classes for type-safe state management
sealed class TownFeatureState {}

class TownFeatureLoaded extends TownFeatureState {
  final TownDto town;

  TownFeatureLoaded(this.town);
}