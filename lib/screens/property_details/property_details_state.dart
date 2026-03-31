import '../../core/core.dart';
import '../../models/models.dart';

sealed class PropertyDetailsState {}

class PropertyDetailsLoading extends PropertyDetailsState {}

class PropertyDetailsSuccess extends PropertyDetailsState {
  final PropertyListingDetailDto listing;
  PropertyDetailsSuccess(this.listing);
}

class PropertyDetailsError extends PropertyDetailsState {
  final AppError error;
  PropertyDetailsError(this.error);
}
