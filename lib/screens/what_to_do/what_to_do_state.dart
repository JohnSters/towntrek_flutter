import '../../core/core.dart';
import '../../models/models.dart';

sealed class WhatToDoState {}

class WhatToDoLoading extends WhatToDoState {}

class WhatToDoError extends WhatToDoState {
  final AppError error;

  WhatToDoError(this.error);
}

class WhatToDoSuccess extends WhatToDoState {
  final TownDto town;
  final int totalCount;
  final List<DiscoveryCategoryDto> categories;
  final List<TownDiscoveryDto> featured;
  final List<TownDiscoveryDto> items;
  /// `null` means “All categories”.
  final int? selectedCategoryId;
  final bool hasNextPage;
  final int page;
  final bool loadingMore;

  WhatToDoSuccess({
    required this.town,
    required this.totalCount,
    required this.categories,
    required this.featured,
    required this.items,
    required this.selectedCategoryId,
    required this.hasNextPage,
    required this.page,
    this.loadingMore = false,
  });

  WhatToDoSuccess copyWith({
    int? totalCount,
    List<DiscoveryCategoryDto>? categories,
    List<TownDiscoveryDto>? featured,
    List<TownDiscoveryDto>? items,
    int? selectedCategoryId,
    bool clearSelectedCategory = false,
    bool? hasNextPage,
    int? page,
    bool? loadingMore,
  }) {
    return WhatToDoSuccess(
      town: town,
      totalCount: totalCount ?? this.totalCount,
      categories: categories ?? this.categories,
      featured: featured ?? this.featured,
      items: items ?? this.items,
      selectedCategoryId:
          clearSelectedCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      hasNextPage: hasNextPage ?? this.hasNextPage,
      page: page ?? this.page,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}
