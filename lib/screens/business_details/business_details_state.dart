import '../../models/models.dart';
import '../../core/core.dart';

/// State classes for Business Details page
sealed class BusinessDetailsState {}

class BusinessDetailsLoading extends BusinessDetailsState {}

class BusinessDetailsSuccess extends BusinessDetailsState {
  final BusinessDetailDto business;
  BusinessDetailsSuccess(this.business);
}

class BusinessDetailsError extends BusinessDetailsState {
  final AppError error;
  BusinessDetailsError(this.error);
}