import '../../models/models.dart';
import '../../core/core.dart';

/// State classes for Creative Space detail page
sealed class CreativeSpaceDetailState {}

class CreativeSpaceDetailLoading extends CreativeSpaceDetailState {}

class CreativeSpaceDetailSuccess extends CreativeSpaceDetailState {
  final CreativeSpaceDetailDto creativeSpace;

  CreativeSpaceDetailSuccess({required this.creativeSpace});
}

class CreativeSpaceDetailError extends CreativeSpaceDetailState {
  final AppError error;

  CreativeSpaceDetailError(this.error);
}
