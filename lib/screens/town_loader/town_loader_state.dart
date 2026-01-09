import '../../models/models.dart';
import '../../core/core.dart';

// State classes for type-safe state management
sealed class TownLoaderState {}

class TownLoaderLoadingLocation extends TownLoaderState {}

class TownLoaderLocationSuccess extends TownLoaderState {
  final TownDto town;

  TownLoaderLocationSuccess(this.town);
}

class TownLoaderLocationError extends TownLoaderState {
  final AppError error;
  final String? locationFailureMessage;

  TownLoaderLocationError(this.error, [this.locationFailureMessage]);
}

class TownLoaderSelectTown extends TownLoaderState {
  final String? locationFailureMessage;

  TownLoaderSelectTown([this.locationFailureMessage]);
}