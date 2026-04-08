import '../../models/models.dart';
import '../../core/core.dart';

/// State classes for Business Card page
sealed class BusinessCardState {}

class BusinessCardLoading extends BusinessCardState {}

class BusinessCardSuccess extends BusinessCardState {
  final List<BusinessDto> businesses;
  final bool hasMorePages;
  final bool isLoadingMore;
  final int totalItemCount;

  BusinessCardSuccess({
    required this.businesses,
    required this.hasMorePages,
    this.isLoadingMore = false,
    required this.totalItemCount,
  });

  BusinessCardSuccess copyWith({
    List<BusinessDto>? businesses,
    bool? hasMorePages,
    bool? isLoadingMore,
    int? totalItemCount,
  }) {
    return BusinessCardSuccess(
      businesses: businesses ?? this.businesses,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalItemCount: totalItemCount ?? this.totalItemCount,
    );
  }
}

class BusinessCardError extends BusinessCardState {
  final AppError error;
  BusinessCardError(this.error);
}

class BusinessCardEmpty extends BusinessCardState {}