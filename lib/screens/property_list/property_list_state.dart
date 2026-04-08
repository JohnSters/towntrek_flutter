import '../../core/core.dart';
import '../../models/models.dart';

sealed class PropertyListState {}

class PropertyListLoading extends PropertyListState {}

class PropertyListSuccess extends PropertyListState {
  final List<PropertyListingCardDto> items;
  final int totalCount;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoadingMore;

  PropertyListSuccess({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.hasNextPage,
    this.isLoadingMore = false,
  });
}

class PropertyListError extends PropertyListState {
  final AppError error;

  PropertyListError(this.error);
}
