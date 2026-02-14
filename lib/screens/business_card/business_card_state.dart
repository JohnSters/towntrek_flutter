import '../../models/models.dart';
import '../../core/core.dart';

/// State classes for Business Card page
sealed class BusinessCardState {}

class BusinessCardLoading extends BusinessCardState {}

class BusinessCardSuccess extends BusinessCardState {
  final List<BusinessDto> businesses;
  final bool hasMorePages;
  final bool isLoadingMore;

  BusinessCardSuccess({
    required this.businesses,
    required this.hasMorePages,
    this.isLoadingMore = false,
  });

  BusinessCardSuccess copyWith({
    List<BusinessDto>? businesses,
    bool? hasMorePages,
    bool? isLoadingMore,
  }) {
    return BusinessCardSuccess(
      businesses: businesses ?? this.businesses,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class BusinessCardError extends BusinessCardState {
  final AppError error;
  BusinessCardError(this.error);
}

class BusinessCardEmpty extends BusinessCardState {}