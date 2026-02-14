import '../../models/models.dart';
import '../../core/core.dart';

// State classes for type-safe state management
sealed class TownSelectionState {}

class TownSelectionLoading extends TownSelectionState {}

class TownSelectionSuccess extends TownSelectionState {
  final List<TownDto> towns;
  final List<TownDto> filteredTowns;

  TownSelectionSuccess({
    required this.towns,
    required this.filteredTowns,
  });
}

class TownSelectionError extends TownSelectionState {
  final AppError error;

  TownSelectionError(this.error);
}

class TownSelectionEmpty extends TownSelectionState {}