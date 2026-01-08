import '../../models/models.dart';

/// State classes for Service List page
/// Following the established pattern with sealed classes for type-safe state management

sealed class ServiceListState {}

/// Loading state for initial service list load
class ServiceListLoading extends ServiceListState {}

/// Success state with loaded services and pagination info
class ServiceListSuccess extends ServiceListState {
  final List<ServiceDto> services;
  final bool hasNextPage;
  final bool isLoadingMore;
  final int currentPage;

  ServiceListSuccess({
    required this.services,
    required this.hasNextPage,
    this.isLoadingMore = false,
    this.currentPage = 1,
  });

  ServiceListSuccess copyWith({
    List<ServiceDto>? services,
    bool? hasNextPage,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return ServiceListSuccess(
      services: services ?? this.services,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Error state for service list loading failure
class ServiceListError extends ServiceListState {
  final String title;
  final String message;

  ServiceListError({
    required this.title,
    required this.message,
  });
}

/// Loading more state for pagination
class ServiceListLoadingMore extends ServiceListState {
  final List<ServiceDto> services;
  final int currentPage;

  ServiceListLoadingMore({
    required this.services,
    required this.currentPage,
  });
}